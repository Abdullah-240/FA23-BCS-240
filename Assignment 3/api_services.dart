import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../models/forecast_model.dart';

class ApiService {
  static const String apiKey = "437c1970ae5bcad29158ab279c3934c5";

  Future<Weather> fetchWeatherByCity(String cityName) async {
    final url = Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?q=$cityName&units=metric&appid=$apiKey");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather');
    }
  }

  Future<List<String>> fetchCitySuggestions(String query) async {
    if (query.isEmpty) {
      return [];
    }
    final url = Uri.parse(
        "https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=3");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map<String>((json) => json['display_name'] as String).toSet().toList();
    } else {
      throw Exception('Failed to load city suggestions');
    }
  }

  Future<List<Forecast>> fetchForecast(String cityName) async {
    final url = Uri.parse(
        "https://api.openweathermap.org/data/2.5/forecast?q=$cityName&units=metric&appid=$apiKey");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['list'];
      return data.map((json) => Forecast.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load forecast');
    }
  }

  Future<Weather> fetchWeatherByCoords(double lat, double lon) async {
    final url = Uri.parse(
        "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&units=metric&appid=$apiKey");
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return Weather.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load weather');
    }
  }
}
