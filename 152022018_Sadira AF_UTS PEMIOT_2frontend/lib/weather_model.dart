// lib/weather_model.dart

class Weather {
  final int suhumax;
  final int suhumin;
  final double suhurata;
  final List<MaxHumid> nilaiSuhuMaxHumidMax;
  final List<MonthYear> monthYearMax;

  Weather({
    required this.suhumax,
    required this.suhumin,
    required this.suhurata,
    required this.nilaiSuhuMaxHumidMax,
    required this.monthYearMax,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    var listMaxHumid = json['nilai_suhu_max_humid_max'] as List;
    var listMonthYear = json['month_year_max'] as List;

    return Weather(
      suhumax: json['suhumax'],
      suhumin: json['suhumin'],
      suhurata: json['suhurata'],
      nilaiSuhuMaxHumidMax: listMaxHumid.map((i) => MaxHumid.fromJson(i)).toList(),
      monthYearMax: listMonthYear.map((i) => MonthYear.fromJson(i)).toList(),
    );
  }
}

class MaxHumid {
  final int id;
  final int suhu;
  final int humid;
  final int kecerahan;
  final String timestamp;

  MaxHumid({
    required this.id,
    required this.suhu,
    required this.humid,
    required this.kecerahan,
    required this.timestamp,
  });

  factory MaxHumid.fromJson(Map<String, dynamic> json) {
    return MaxHumid(
      id: json['id'],
      suhu: json['suhu'],
      humid: json['humid'],
      kecerahan: json['kecerahan'],
      timestamp: json['timestamp'],
    );
  }
}

class MonthYear {
  final String monthYear;

  MonthYear({
    required this.monthYear,
  });

  factory MonthYear.fromJson(Map<String, dynamic> json) {
    return MonthYear(
      monthYear: json['month_year'],
    );
  }
}
