#include <WiFi.h>
#include <FirebaseESP32.h>
#include <addons/TokenHelper.h>
#include <addons/RTDBHelper.h>
#include "EmonLib.h"
#include <EEPROM.h>

// Firebase Configuration
#define WIFI_SSID "Autobonics_4G"
#define WIFI_PASSWORD "autobonics@27"
#define API_KEY "AIzaSyBMe4q-SD-8oP1DPBiSF7NxVaBytNhaIJM"
#define DATABASE_URL "https://ai-based-smart-energy-meter-default-rtdb.firebaseio.com"
#define USER_EMAIL "device1@gmail.com"
#define USER_PASSWORD "12345678"

// Firebase objects
FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;
FirebaseData stream; // Firebase stream object for listening to data changes

String uid;
String path;

// Relay pin
#define RELAY_PIN 14

// Constants for calibration
const float vCalibration = 70;  // Voltage calibration factor
const float currCalibration = 0.68;  // Current calibration factor

// EnergyMonitor instance
EnergyMonitor emon;  // Create an instance of EnergyMonitor

// Variables for energy calculation
float kWh = 0.0;  // Variable to store energy consumed in kWh
float cost = 0.0;  // Variable to store cost of energy consumed
const float ratePerkWh = 6.5;  // Cost rate per kWh
unsigned long lastMillis = millis();  // Variable to store last time in milliseconds

// EEPROM addresses for each variable
const int addrKWh = 12;  // EEPROM address for kWh
const int addrCost = 16;  // EEPROM address for cost

// Function prototypes
void sendEnergyDataToFirebase();
void readEnergyDataFromEEPROM();
void saveEnergyDataToEEPROM();
void resetEEPROM();
void streamCallback(StreamData data);
void streamTimeoutCallback(bool timeout);

void streamCallback(StreamData data) {
  Serial.println("NEW DATA!");

  String p = data.dataPath();
  Serial.println(p);
  printResult(data);  // see addons/RTDBHelper.h

  FirebaseJson json = data.jsonObject();
  FirebaseJsonData state;
  FirebaseJsonData reset;


  // Check if the "data" field contains a boolean value
  json.get(state, "state");
  json.get(reset, "reset");

  if (state.success) {
    bool relayValue = state.to<bool>();
    if (relayValue) {
      digitalWrite(RELAY_PIN, HIGH); // Turn relay ON
      Serial.println("Relay ON");
    } else {
      digitalWrite(RELAY_PIN, LOW); // Turn relay OFF
      Serial.println("Relay OFF");
    }
  }

  // Handle reset command
  
  if (reset.success) {
    bool resetValue = reset.to<bool>();
    Serial.println("Do you wanna reset?");
    Serial.println(resetValue);
    if (resetValue) {
      Serial.println("Reset Initiated");
      resetEEPROM();
    }else{
      Serial.println("It's false , can't be resetted");
    }
  }
}

void streamTimeoutCallback(bool timeout) {
  if (timeout) {
    Serial.println("Stream timed out, resuming...\n");
  }

  if (!stream.httpConnected()) {
    Serial.printf("error code: %d, reason: %s\n\n", stream.httpCode(), stream.errorReason().c_str());
  }
}

void setup() {
  // Start serial communication
  Serial.begin(115200);

  // Initialize relay pin
  pinMode(RELAY_PIN, OUTPUT);
  digitalWrite(RELAY_PIN, LOW); // Ensure relay is OFF initially

  // Initialize Wi-Fi
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Connecting to Wi-Fi");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(300);
  }
  Serial.println();
  Serial.print("Connected with IP: ");
  Serial.println(WiFi.localIP());
  Serial.println();

  // Initialize Firebase
  config.api_key = API_KEY;
  auth.user.email = USER_EMAIL;  //device3@gmail.com
  auth.user.password = USER_PASSWORD;  //12345678
  config.database_url = DATABASE_URL;
  config.token_status_callback = tokenStatusCallback;

  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);

  // Get the Firebase User UID
  Serial.println("Getting User UID");
  while ((auth.token.uid) == "") {
    Serial.print('.');
    delay(1000);
  }
  uid = auth.token.uid.c_str();
  path = "devices/" + uid + "/reading";

  // Stream setup to listen for Firebase changes
  if (!Firebase.beginStream(stream, "devices/" + uid + "/data")) {
    Serial.printf("Stream begin error, %s\n\n", stream.errorReason().c_str());
  }
  Firebase.setStreamCallback(stream, streamCallback, streamTimeoutCallback);

  // Initialize EEPROM
  EEPROM.begin(32);

  // Read stored data from EEPROM
  readEnergyDataFromEEPROM();

  // Setup voltage and current inputs
  emon.voltage(35, vCalibration, 1.7);  // Configure voltage measurement: input pin, calibration, phase shift
  emon.current(34, currCalibration);  // Configure current measurement: input pin, calibration
}

void loop() {
  emon.calcVI(20, 2000);  // Calculate voltage and current
  float Vrms = emon.Vrms;
  float Irms = emon.Irms;
  float apparentPower = emon.apparentPower;

  if (Vrms < 30.0) {
    Vrms = 0.0;
    apparentPower = 0.0;
  }

  // Calculate energy consumed in kWh
  unsigned long currentMillis = millis();
  kWh += apparentPower * (currentMillis - lastMillis) / 3600000000.0;
  lastMillis = currentMillis;

  // Calculate the cost based on the rate per kWh
  cost = kWh * ratePerkWh;

  // Save the latest values to EEPROM
  saveEnergyDataToEEPROM();

  // Send data to Firebase
  sendEnergyDataToFirebase();

  delay(2000);
}

void sendEnergyDataToFirebase() {
  if (Firebase.ready()) {
    FirebaseJson json;
    json.set("voltage", emon.Vrms);
    json.set("current", emon.Irms);
    json.set("power", emon.apparentPower);
    json.set("energy", kWh);
    json.set("cost", cost);
    json.set(F("timestamp/.sv"), F("timestamp"));

    if (Firebase.setJSON(fbdo, path.c_str(), json)) {
      Serial.println("Data sent to Firebase");
    } else {
      Serial.println("Failed to send data to Firebase");
      Serial.println(fbdo.errorReason());
    }
  }
}

void readEnergyDataFromEEPROM() {
  EEPROM.get(addrKWh, kWh);
  EEPROM.get(addrCost, cost);
  if (isnan(kWh)) {
    kWh = 0.0;
    saveEnergyDataToEEPROM();
  }
  if (isnan(cost)) {
    cost = 0.0;
    saveEnergyDataToEEPROM();
  }
}

void saveEnergyDataToEEPROM() {
  EEPROM.put(addrKWh, kWh);
  EEPROM.put(addrCost, cost);
  EEPROM.commit();
}

void resetEEPROM() {
  kWh = 0.0;
  cost = 0.0;
  saveEnergyDataToEEPROM();
  Serial.println("EEPROM reset");
}