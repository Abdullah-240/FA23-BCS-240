
import 'package:weather_app/models/weather_model.dart';

class Forecast {
  final DateTime dateTime;
  final double temp;
  final String description;
  final String icon;

  Forecast({
    required this.dateTime,
    required this.temp,
    required this.description,
    required this.icon,
  });

  factory Forecast.fromJson(Map<String, dynamic> json) {
    return Forecast(
      dateTime: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      temp: json['main']['temp'].toDouble(),
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
    );
  }
}
