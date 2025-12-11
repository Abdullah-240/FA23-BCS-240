import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';
import '../providers/weather_provider.dart';

class ForecastScreen extends StatelessWidget {
  String _getWeatherAnimation(String? icon) {
    if (icon == null) return 'assets/sunny.json'; // Default animation

    if (icon.contains('n')) {
      return 'assets/Weather-night.json';
    }

    switch (icon.substring(0, 2)) {
      case '01':
        return 'assets/sunny.json';
      case '02':
        return 'assets/Weather-partly cloudy.json';
      case '03':
      case '04':
        return 'assets/Weather-partly cloudy.json';
      case '09':
        return 'assets/Weather-partly shower.json';
      case '10':
        return 'assets/Weather-partly shower.json';
      case '11':
        return 'assets/Weather-storm.json';
      case '13':
        return 'assets/Weather-snow.json';
      case '50':
        return 'assets/Fog  Smoke.json';
      default:
        return 'assets/sunny.json';
    }
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<WeatherProvider>(context);
    final isNight = weatherProvider.weather?.icon?.contains('n') ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text('Forecast'),
        backgroundColor: isNight ? Colors.black : Colors.blue.shade700,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: isNight
                ? [Colors.black, Colors.grey.shade800]
                : [Colors.blue.shade300, Colors.blue.shade900],
          ),
        ),
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: [
            Text(
              'Hourly Forecast',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 16),
            Container(
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: weatherProvider.hourlyForecast.length,
                itemBuilder: (context, index) {
                  final forecast = weatherProvider.hourlyForecast[index];
                  return Card(
                    color: Colors.white.withOpacity(0.2),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(DateFormat.j().format(forecast.dateTime), style: TextStyle(color: Colors.white)),
                          Lottie.asset(
                            _getWeatherAnimation(forecast.icon),
                            width: 50,
                            height: 50,
                          ),
                          Text('${forecast.temp.round()}°C', style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 32),
            Text(
              'Next 5 Days',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: weatherProvider.dailyForecast.length,
              itemBuilder: (context, index) {
                final forecast = weatherProvider.dailyForecast[index];
                return Card(
                  color: Colors.white.withOpacity(0.2),
                  child: ListTile(
                    leading: Lottie.asset(
                      _getWeatherAnimation(forecast.icon),
                      width: 50,
                      height: 50,
                    ),
                    title: Text(DateFormat.EEEE().format(forecast.dateTime), style: TextStyle(color: Colors.white)),
                    subtitle: Text(forecast.description, style: TextStyle(color: Colors.white70)),
                    trailing: Text('${forecast.temp.round()}°C', style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
