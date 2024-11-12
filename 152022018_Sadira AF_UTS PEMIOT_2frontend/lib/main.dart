import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'weather_model.dart'; // Import model yang sudah dibuat

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cuaca App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CuacaScreen(),
    );
  }
}

class CuacaScreen extends StatefulWidget {
  @override
  _CuacaScreenState createState() => _CuacaScreenState();
}

class _CuacaScreenState extends State<CuacaScreen> {
  late Future<Weather> weather;

  @override
  void initState() {
    super.initState();
    weather = fetchWeather();
  }

  Future<Weather> fetchWeather() async {
    final response = await http.get(Uri.parse('http://192.168.1.54/PEMIOT/UTS/utspemiot.php')); // Ganti dengan URL backend Anda

    if (response.statusCode == 200) {
      print(response.body); // Menampilkan data JSON di konsol
      return Weather.fromJson(json.decode(response.body));
    } else {
      throw Exception('Gagal memuat data cuaca');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('152022018_Sadira_UTS PEMIOT'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.purple],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue[50]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FutureBuilder<Weather>(
          future: weather,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              var data = snapshot.data!;
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWeatherCard(data),
                    SizedBox(height: 20),
                    Text('Data Suhu Max dan Humid Max:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                    SizedBox(height: 10),
                    _buildHumidityList(data.nilaiSuhuMaxHumidMax),
                    SizedBox(height: 20),
                    Text('Bulan dan Tahun Max:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                    SizedBox(height: 10),
                    _buildMonthYearList(data.monthYearMax),
                  ],
                ),
              );
            } else {
              return Center(child: Text('Data tidak ditemukan.'));
            }
          },
        ),
      ),
    );
  }

  Widget _buildWeatherCard(Weather data) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlueAccent, Colors.blue[200]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.thermostat, color: Colors.white, size: 30),
                SizedBox(width: 8),
                Text('Data Suhu', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
            Divider(color: Colors.white),
            Text('Suhu Max: ${data.suhumax}°C', style: TextStyle(fontSize: 18, color: Colors.white)),
            Text('Suhu Min: ${data.suhumin}°C', style: TextStyle(fontSize: 18, color: Colors.white)),
            Text('Suhu Rata-Rata: ${data.suhurata}°C', style: TextStyle(fontSize: 18, color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildHumidityList(List<MaxHumid> list) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) {
        var maxHumid = list[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8.0),
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Icon(Icons.wb_sunny, color: Colors.blueAccent),
            title: Text('ID: ${maxHumid.id} - Suhu: ${maxHumid.suhu}°C', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              'Humid: ${maxHumid.humid}% | Kecerahan: ${maxHumid.kecerahan} Lux\nTimestamp: ${maxHumid.timestamp}',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMonthYearList(List<MonthYear> list) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: list.length,
      itemBuilder: (context, index) {
        var monthYear = list[index];
        return Card(
          margin: EdgeInsets.symmetric(vertical: 8.0),
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Icon(Icons.calendar_today, color: Colors.blueAccent),
            title: Text('Month-Year: ${monthYear.monthYear}', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        );
      },
    );
  }
}