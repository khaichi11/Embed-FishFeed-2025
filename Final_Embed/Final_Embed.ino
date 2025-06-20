#include <WiFi.h>
#include <Firebase_ESP_Client.h>
#include <Wire.h>
#include <ESP32Servo.h>
#include "RTClib.h"
#include <driver/adc.h>
#include "esp_sleep.h"          
#include <time.h>


static int lastFedMinute = -1;


#define WIFI_SSID       "WIFI"
#define WIFI_PASSWORD   "PASSWORD"

#define API_KEY         "API_KEY"
#define DATABASE_URL    "DB_URL"

#define USER_EMAIL      "EMAIL"
#define USER_PASSWORD   "PASSWORD"

#define DEVICE_ID       "FF-2024"



#define BATT_DIV_PIN    32    
#define TURBIDITY_PIN   34    
#define TRIG_PIN        5     
#define ECHO_PIN        18    
#define SERVO_PIN       13    


#define V0              3.0f
#define V100            1.5f
#define NTU100          100.0f


const uint64_t SLEEP_US = 5000ULL * 1000ULL;


const char* ntpServer      = "pool.ntp.org";
const long  gmtOffset      = 7 * 3600;     
const int   daylightOffset = 0;


RTC_DS3231     rtc;
FirebaseAuth   auth;
FirebaseConfig config;
FirebaseData   fbdo;
Servo          feederServo;



void clearOscFlag() {
  Wire.beginTransmission(0x68);
  Wire.write(0x0F);    
  Wire.write(0x00);    
  Wire.endTransmission();
}



void syncDS3231toNTP() {
  configTime(gmtOffset, daylightOffset, ntpServer);
  Serial.print("Menunggu NTP");
  while (time(nullptr) < 1609459200) { 
    delay(500);
    Serial.print('.');
  }
  Serial.println();

  struct tm tm;
  if (!getLocalTime(&tm)) {
    Serial.println("Gagal ambil waktu NTP");
    return;
  }
  Serial.printf("NTP time: %04d-%02d-%02d %02d:%02d:%02d\n",
                tm.tm_year + 1900, tm.tm_mon + 1, tm.tm_mday,
                tm.tm_hour, tm.tm_min, tm.tm_sec);


  rtc.adjust(DateTime(
    tm.tm_year + 1900, tm.tm_mon + 1, tm.tm_mday,
    tm.tm_hour, tm.tm_min, tm.tm_sec
  ));

  DateTime t2 = rtc.now();
  Serial.printf("RTC after set: %04d-%02d-%02d %02d:%02d:%02d\n",
                t2.year(), t2.month(), t2.day(),
                t2.hour(), t2.minute(), t2.second());

  clearOscFlag();
}


void ensureRtcValid() {
  DateTime t = rtc.now();
  if (t.year() < 2023 || abs(t.second() - (int)time(nullptr) % 60) > 5) {
    Serial.println("RTC aneh, re-sync NTP");
    syncDS3231toNTP();
  }
}


long readUltrasonicCm() {
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(5);
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);
  long dur = pulseIn(ECHO_PIN, HIGH, 30000);
  return (dur > 0) ? (long)((dur / 58.2f) + 0.5f) : -1;
}


void sendSensorData() {

  int raw      = analogRead(TURBIDITY_PIN);
  float volt   = raw * (3.3f / 4095.0f);
  float ntu    = NTU100 / (V0 - V100) * (V0 - volt);
  ntu          = max(0.0f, ntu);


  long dist    = readUltrasonicCm();


  int rawB     = analogRead(BATT_DIV_PIN);
  float Vbat   = rawB * (3.3f / 4095.0f) * 2.0f;
  int pctBatt  = map((int)(Vbat * 1000), 3300, 4200, 0, 100);
  pctBatt      = constrain(pctBatt, 0, 100);


  DateTime now;
  now = rtc.now();
  char ts[25];
  sprintf(ts, "%04d-%02d-%02dT%02d:%02d:%02d",
          now.year(), now.month(), now.day(), now.hour(), now.minute(), now.second());


  FirebaseJson j;
  j.set("turbidity_raw", raw);
  j.set("turbidity_volt", volt);
  j.set("turbidity", ntu);
  j.set("distance_cm", dist);
  j.set("battery_voltage", Vbat);
  j.set("battery_percent", pctBatt);
  j.set("timestamp", ts);


  String path = "/devices/" + String(DEVICE_ID) + "/sensors";
  if (!Firebase.RTDB.setJSON(&fbdo, path.c_str(), &j)) {
    delay(100);
    Firebase.RTDB.setJSON(&fbdo, path.c_str(), &j);
  }
  Serial.printf("Sent: ntu=%.1f dist=%ld bat=%.2fV %d%% @%s\n",
                ntu, dist, Vbat, pctBatt, ts);
}


void checkForCommands() {
  String base       = "/commands/" + String(DEVICE_ID) + "/current_command";
  String statusPath = base + "/status";


  if (!Firebase.RTDB.getString(&fbdo, statusPath)) {
    if (fbdo.errorReason() == "path not exist") {
      FirebaseJson init;
      init.set("type", "none");
      init.set("status", "done");
      Firebase.RTDB.setJSON(&fbdo, base.c_str(), &init);
    }
    return;
  }


  if (fbdo.stringData() == "pending") {
    if (Firebase.RTDB.getString(&fbdo, (base + "/type").c_str())
        && fbdo.stringData() == "feed") {
      feederServo.write(360);
      delay(1000);
      feederServo.write(0);
      Firebase.RTDB.setString(&fbdo, statusPath.c_str(), "done");
      Serial.println(">> Feeding done");
    }
  }
}


void checkScheduleAndFeed() {
  String schedPath = "/schedules/" + String(DEVICE_ID);


  if (!Firebase.RTDB.getJSON(&fbdo, schedPath.c_str())) {
    Serial.printf("❌ Gagal baca schedule: %s\n", fbdo.errorReason().c_str());
    return;
  }

  FirebaseJson &root = fbdo.jsonObject();
  FirebaseJsonData jd;


  if (!root.get(jd, "active") || !jd.boolValue) return;


  if (!root.get(jd, "entries")) {
    Serial.println("⚠️ Tidak ada child 'entries'");
    return;
  }
  FirebaseJson entries;
  jd.getJSON(entries);


  DateTime now = rtc.now();
  int nowH = now.hour(), nowM = now.minute();
  char todayBuf[11];
  sprintf(todayBuf, "%04d-%02d-%02d", now.year(), now.month(), now.day());
  String today(todayBuf);


  size_t count = entries.iteratorBegin();
  for (size_t i = 0; i < count; i++) {
    FirebaseJson::IteratorValue iv = entries.valueAt(i);
    String key    = iv.key;  
    FirebaseJson entry(iv.value);


    entry.get(jd, "enabled");
    if (!jd.boolValue) continue;


    entry.get(jd, "time");
    String t = jd.stringValue; t.trim();
    int hh = 0, mm = 0;
    bool pm = t.endsWith("PM"), am = t.endsWith("AM");
    if (pm || am) {
      String tm = t.substring(0, t.length() - 2); tm.trim();
      int c = tm.indexOf(':');
      hh = tm.substring(0, c).toInt();
      mm = tm.substring(c + 1).toInt();
      if (pm && hh != 12) hh += 12;
      if (am && hh == 12) hh = 0;
    } else {
      int c1 = t.indexOf(':'), c2 = t.indexOf(':', c1 + 1);
      hh = t.substring(0, c1).toInt();
      mm = (c2 > 0) ? t.substring(c1 + 1, c2).toInt() : t.substring(c1 + 1).toInt();
    }


    entry.get(jd, "last_run");
    String lastRun = jd.stringValue;


    if (hh == nowH && mm == nowM && lastRun != today) {
      Serial.printf(">> Scheduled feed @ %02d:%02d (entry %s)\n",
                    hh, mm, key.c_str());
      feederServo.write(180);
      delay(1000);
      feederServo.write(0);


      String lrPath = schedPath + "/entries/" + key + "/last_run";
      Firebase.RTDB.setString(&fbdo, lrPath.c_str(), today);

      entries.iteratorEnd();
      return;
    }
  }
  entries.iteratorEnd();
}


void setup() {
  Serial.begin(115200);


  Wire.begin(21, 22);
  if (!rtc.begin()) {
    Serial.println("RTC tidak terdeteksi!");
    while (1);
  }
  clearOscFlag();


  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print('.');
    delay(500);
  }
  Serial.println("\nWiFi terhubung");


  syncDS3231toNTP();


  config.api_key      = API_KEY;
  config.database_url = DATABASE_URL;
  auth.user.email     = USER_EMAIL;
  auth.user.password  = USER_PASSWORD;
  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);


  feederServo.attach(SERVO_PIN);
  feederServo.write(0);
  analogSetWidth(12);
  analogSetPinAttenuation(TURBIDITY_PIN, ADC_11db);

  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT_PULLDOWN);


  String statPath = "/devices/" + String(DEVICE_ID) + "/status/online";
  Firebase.RTDB.setBool(&fbdo, statPath.c_str(), true);
}


void loop() {
  ensureRtcValid();       
  checkScheduleAndFeed(); 
  sendSensorData();        
  checkForCommands();      


  Serial.printf("Deep sleep %llu ms...\n", SLEEP_US / 1000);
  esp_sleep_enable_timer_wakeup(SLEEP_US);
  esp_deep_sleep_start();
}
