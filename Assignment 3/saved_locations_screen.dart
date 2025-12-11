import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/saved_locations_provider.dart';
import '../providers/weather_provider.dart';

class SavedLocationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Locations'),
      ),
      body: Consumer<SavedLocationsProvider>(
        builder: (context, provider, child) {
          if (provider.savedLocations.isEmpty) {
            return Center(
              child: Text('You have no saved locations yet.'),
            );
          }
          return ListView.builder(
            itemCount: provider.savedLocations.length,
            itemBuilder: (context, index) {
              final location = provider.savedLocations[index];
              return ListTile(
                title: Text(location),
                onTap: () {
                  Provider.of<WeatherProvider>(context, listen: false)
                      .fetchWeatherByCity(location);
                  Navigator.pop(context);
                },
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    provider.removeLocation(location);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
