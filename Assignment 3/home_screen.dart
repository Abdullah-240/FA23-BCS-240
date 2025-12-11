import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../providers/weather_provider.dart';
import '../providers/saved_locations_provider.dart';
import '../services/api_services.dart';
import 'forecast_screen.dart';
import 'map_screen.dart';
import 'saved_locations_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController? _typeAheadController;
  final ApiService _apiService = ApiService();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<WeatherProvider>(context, listen: false);
      provider.fetchWeather();

      _timer = Timer.periodic(const Duration(minutes: 15), (timer) {
        // Only fetch weather if a city is already selected
        if (provider.weather != null) {
          provider.fetchWeatherByCity(provider.weather!.cityName);
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _getWeatherAnimation(String? icon) {
    if (icon == null || icon.length < 2) return 'assets/sunny.json';
    final isNight = icon.contains('n');

    if (isNight) {
      return 'assets/Weather-night.json';
    }

    final code = icon.substring(0, 2);
    switch (code) {
      case '01':
        return 'assets/sunny.json';
      case '02':
      case '03':
      case '04':
        return 'assets/Weather-partly cloudy.json';
      case '09':
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
    final savedLocationsProvider = Provider.of<SavedLocationsProvider>(context);
    final isNight = weatherProvider.weather?.icon?.contains('n') ?? false;

    return Scaffold(
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Material(
                  color: Colors.transparent,
                  child: TypeAheadField<String>(
                    suggestionsCallback: (pattern) async {
                      if (pattern.trim().isEmpty) return <String>[];
                      try {
                        return await _apiService.fetchCitySuggestions(pattern);
                      } catch (e) {
                        return <String>[];
                      }
                    },
                    builder: (context, controller, focusNode) {
                      _typeAheadController = controller;
                      return TextField(
                        controller: controller,
                        focusNode: focusNode,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Enter city name',
                          hintStyle: TextStyle(color: Colors.white70),
                          prefixIcon: IconButton(
                            icon: Icon(Icons.location_on, color: Colors.white),
                            onPressed: () async {
                              final String? selectedCity = await Navigator.push<String>(
                                context,
                                MaterialPageRoute(builder: (context) => MapScreen()),
                              );
                              if (selectedCity != null && selectedCity.isNotEmpty) {
                                weatherProvider.fetchWeatherByCity(selectedCity);
                              }
                            },
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.search, color: Colors.white),
                            onPressed: () {
                              final text = _typeAheadController?.text.trim() ?? '';
                              if (text.isNotEmpty) {
                                weatherProvider.fetchWeatherByCity(text);
                              }
                            },
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.white),
                          ),
                        ),
                      );
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        title: Text(suggestion, style: TextStyle(color: Colors.black)),
                      );
                    },
                    onSelected: (suggestion) {
                      _typeAheadController?.text = suggestion;
                      weatherProvider.fetchWeatherByCity(suggestion);
                    },
                    loadingBuilder: (context) => Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Center(
                          child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator())),
                    ),
                    emptyBuilder: (context) => Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text('No results', style: TextStyle(color: Colors.black)),
                    ),
                    errorBuilder: (context, error) => Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text('Error', style: TextStyle(color: Colors.black)),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                Expanded(
                  child: Center(
                    child: weatherProvider.isLoading && weatherProvider.weather == null
                        ? Lottie.asset('assets/Loader.json', width: 120, height: 120)
                        : weatherProvider.weather == null
                        ? Text(
                      'Could not fetch weather data.',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    )
                        : SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                weatherProvider.weather!.cityName,
                                style: TextStyle(
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              IconButton(
                                icon: Icon(
                                  savedLocationsProvider.savedLocations
                                      .contains(weatherProvider.weather!.cityName)
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.yellow,
                                ),
                                onPressed: () {
                                  final location = weatherProvider.weather!.cityName;
                                  if (savedLocationsProvider.savedLocations.contains(location)) {
                                    savedLocationsProvider.removeLocation(location);
                                  } else {
                                    savedLocationsProvider.addLocation(location);
                                  }
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: 200,
                            height: 200,
                            child: Builder(builder: (context) {
                              final anim = _getWeatherAnimation(
                                  weatherProvider.weather!.icon);
                              try {
                                return Lottie.asset(anim);
                              } catch (e) {
                                return Center(
                                  child: Text(
                                    'Icon not available',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                );
                              }
                            }),
                          ),
                          Text(
                            '${weatherProvider.weather!.temp.round()}°C',
                            style: TextStyle(
                              fontSize: 60,
                              fontWeight: FontWeight.w200,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            weatherProvider.weather!.description,
                            style: TextStyle(
                              fontSize: 24,
                              fontStyle: FontStyle.italic,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildWeatherDetail(
                                'Humidity',
                                '${weatherProvider.weather!.humidity}%',
                              ),
                              _buildWeatherDetail(
                                'Wind',
                                '${weatherProvider.weather!.windSpeed} km/h',
                              ),
                              _buildWeatherDetail(
                                'Pressure',
                                '${weatherProvider.weather!.pressure} hPa',
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => ForecastScreen()),
                                  );
                                },
                                child: Text('View Forecast'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => SavedLocationsScreen()),
                                  );
                                },
                                child: Text('Saved Locations'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherDetail(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
