#include <DHT.h>               // Library untuk sensor DHT
#include <PubSubClient.h>      // Library untuk protokol MQTT
#include <WiFi.h>              // Library untuk koneksi WiFi

#define DHTPIN 12              // Pin GPIO yang digunakan untuk sensor DHT
#define DHTTYPE DHT22          // Tipe sensor DHT yang digunakan adalah DHT22
#define GREEN_LED 5            // Pin GPIO untuk LED hijau
#define YELLOW_LED 18          // Pin GPIO untuk LED kuning
#define RED_LED 19             // Pin GPIO untuk LED merah
#define BUZZER 14              // Pin GPIO untuk buzzer
#define RELAY 27               // Pin GPIO untuk relay pompa

DHT dht(DHTPIN, DHTTYPE);      // Inisialisasi sensor DHT pada pin DHTPIN dengan tipe DHTTYPE

// Variabel status untuk buzzer dan pompa
String buzzerStatus;
String pumpStatus;

// Konfigurasi WiFi dan MQTT
const char* ssid = "Wokwi-GUEST";  // SSID WiFi (nama jaringan)
const char* password = "";         // Password WiFi
const char* mqtt_server = "broker.hivemq.com";  // Server MQTT yang akan digunakan

WiFiClient espClient;               // Objek untuk koneksi WiFi
PubSubClient client(espClient);     // Objek untuk koneksi MQTT menggunakan WiFi

void setup() {
  Serial.begin(115200);          // Memulai Serial Monitor dengan baud rate 115200

  // Setup mode pin
  pinMode(GREEN_LED, OUTPUT);    // Mengatur pin LED hijau sebagai OUTPUT
  pinMode(YELLOW_LED, OUTPUT);   // Mengatur pin LED kuning sebagai OUTPUT
  pinMode(RED_LED, OUTPUT);      // Mengatur pin LED merah sebagai OUTPUT
  pinMode(BUZZER, OUTPUT);       // Mengatur pin buzzer sebagai OUTPUT
  pinMode(RELAY, OUTPUT);        // Mengatur pin relay pompa sebagai OUTPUT

  // Inisialisasi sensor DHT
  dht.begin();

  // Setup WiFi
  setup_wifi();

  // Setup MQTT
  client.setServer(mqtt_server, 1883);  // Mengatur server MQTT pada port 1883
}

void setup_wifi() {
  delay(10);
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);

  // Memulai koneksi WiFi
  WiFi.begin(ssid, password);

  // Loop hingga terhubung ke WiFi
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");  // Menampilkan titik-titik selama proses koneksi
  }

  Serial.println("");
  Serial.println("WiFi connected"); // Menampilkan bahwa WiFi sudah terhubung
}

void reconnect() {
  // Loop hingga terhubung ke MQTT server
  while (!client.connected()) {
    Serial.print("Attempting MQTT connection...");
    // Mencoba terhubung ke server MQTT dengan client ID "152022018_pemiot"
    if (client.connect("152022018_pemiot")) {
      Serial.println("connected");
    } else {
      Serial.print("failed, rc=");
      Serial.print(client.state());
      Serial.println(" try again in 5 seconds");
      delay(5000); // Tunggu 5 detik sebelum mencoba lagi
    }
  }
}

void loop() {
  // Mengecek koneksi ke server MQTT
  if (!client.connected()) {
    reconnect();
  }
  client.loop();

  // Membaca suhu dan kelembaban dari sensor DHT
  float h = dht.readHumidity();
  float t = dht.readTemperature();

  // Cek apakah sensor berhasil membaca data
  if (isnan(h) || isnan(t)) {
    Serial.println("Failed to read from DHT sensor!");
    return;
  }

  // Menampilkan suhu dan kelembaban di Serial Monitor
  Serial.print("Temperature: ");
  Serial.print(t);
  Serial.print(" °C  Humidity: ");
  Serial.print(h);
  Serial.println(" %");

  // Logika untuk LED dan buzzer berdasarkan suhu
  if (t > 35) {                      // Jika suhu di atas 35°C
    digitalWrite(RED_LED, HIGH);      // Nyalakan LED merah
    digitalWrite(YELLOW_LED, LOW);
    digitalWrite(GREEN_LED, LOW);
    digitalWrite(BUZZER, HIGH);       // Nyalakan buzzer
    buzzerStatus = "ON";
    client.publish("152022018_pemiot/buzzer", "Buzzer Menyala");  // Kirim status buzzer menyala
    delay(1000);                      // Tunggu 1 detik
    digitalWrite(BUZZER, LOW);        // Matikan buzzer
  } else if (t >= 30 && t <= 35) {    // Jika suhu antara 30°C - 35°C
    digitalWrite(YELLOW_LED, HIGH);   // Nyalakan LED kuning
    digitalWrite(RED_LED, LOW);
    digitalWrite(GREEN_LED, LOW);
    digitalWrite(BUZZER, LOW);        // Matikan buzzer
    buzzerStatus = "OFF";
    client.publish("152022018_pemiot/buzzer", "Buzzer Mati");  
  } else {                            // Jika suhu di bawah 30°C
    digitalWrite(GREEN_LED, HIGH);    // Nyalakan LED hijau
    digitalWrite(RED_LED, LOW);
    digitalWrite(YELLOW_LED, LOW);
    digitalWrite(BUZZER, LOW);        // Matikan buzzer
    buzzerStatus = "OFF";
    client.publish("152022018_pemiot/buzzer", "Buzzer Mati");  
  }

  // Logika pompa menyala jika suhu > 35 dan kelembaban < 30
  if(t > 35 && h < 30) {
    digitalWrite(RELAY, HIGH);
    pumpStatus = "ON";
    client.publish("152022018_pemiot/pompa", "Pompa Menyala");  
  } else {
    digitalWrite(RELAY, LOW);
    pumpStatus = "OFF";
    client.publish("152022018_pemiot/pompa", "Pompa Mati");  
  }

  // Mempersiapkan dan mengirim pesan MQTT
  char temperatureString[8];
  char humidityString[8];
  dtostrf(t, 1, 2, temperatureString); // Mengonversi nilai suhu menjadi string
  dtostrf(h, 1, 2, humidityString);    // Mengonversi nilai kelembaban menjadi string

  String payload = String("{\"temperature\": \"") + temperatureString + "\",\"humidity\": \"" + humidityString + "\",\"Pompa\": \"" + pumpStatus + "\",\"Buzzer\": \"" + buzzerStatus + "\"}";

  // Publish data suhu dan kelembaban ke topik MQTT
  client.publish("152022018_pemiot/temperature", temperatureString); // Kirim suhu
  client.publish("152022018_pemiot/humidity", humidityString);       // Kirim kelembaban
  client.publish("152022018_pemiot/data", payload.c_str());          // Kirim data lengkap dalam format JSON

  delay(5000);  // Tunggu 5 detik sebelum pembacaan berikutnya
}