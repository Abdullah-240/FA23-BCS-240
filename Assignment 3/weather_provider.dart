import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../models/forecast_model.dart';
import '../services/api_services.dart';
import '../services/location_service.dart';
import 'package:geocoding/geocoding.dart';

class WeatherProvider with ChangeNotifier {
  Weather? _weather;
  List<Forecast> _hourlyForecast = [];
  List<Forecast> _dailyForecast = [];
  bool _isLoading = false;

  Weather? get weather => _weather;
  List<Forecast> get hourlyForecast => _hourlyForecast;
  List<Forecast> get dailyForecast => _dailyForecast;
  bool get isLoading => _isLoading;

  final ApiService _apiService = ApiService();
  final LocationService _locationService = LocationService();

  Future<void> fetchWeather() async {
    _isLoading = true;
    notifyListeners();

    try {
      final position = await _locationService.getCurrentLocation();

      if (position != null) {
        List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
        String city = placemarks.first.locality ?? "Karachi";
        await fetchWeatherByCity(city);
      } else {
        await fetchWeatherByCity("Karachi");
      }
    } catch (e) {
      print(e);
      await fetchWeatherByCity("Karachi");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchWeatherByCity(String cityName) async {
    _isLoading = true;
    notifyListeners();

    try {
      _weather = await _apiService.fetchWeatherByCity(cityName);
      final forecasts = await _apiService.fetchForecast(cityName);
      _processForecasts(forecasts);
    } catch (e) {
      print(e);
    }

    _isLoading = false;
    notifyListeners();
  }

  void _processForecasts(List<Forecast> forecasts) {
    _hourlyForecast = forecasts.take(8).toList(); // Next 24 hours (8 * 3-hour intervals)

    _dailyForecast = [];
    Map<int, Forecast> dailyData = {};

    for (var forecast in forecasts) {
      int day = forecast.dateTime.day;
      if (!dailyData.containsKey(day)) {
        dailyData[day] = forecast;
      }
    }

    _dailyForecast = dailyData.values.toList();
  }
}
