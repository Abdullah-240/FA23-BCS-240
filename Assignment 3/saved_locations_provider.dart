import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedLocationsProvider with ChangeNotifier {
  List<String> _savedLocations = [];

  List<String> get savedLocations => _savedLocations;

  SavedLocationsProvider() {
    loadSavedLocations();
  }

  Future<void> loadSavedLocations() async {
    final prefs = await SharedPreferences.getInstance();
    _savedLocations = prefs.getStringList('savedLocations') ?? [];
    notifyListeners();
  }

  Future<void> addLocation(String location) async {
    if (!_savedLocations.contains(location)) {
      _savedLocations.add(location);
      notifyListeners(); // Update UI immediately
      await _saveLocationsToPrefs(); // Save in the background
    }
  }

  Future<void> removeLocation(String location) async {
    _savedLocations.remove(location);
    notifyListeners(); // Update UI immediately
    await _saveLocationsToPrefs(); // Save in the background
  }

  Future<void> _saveLocationsToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('savedLocations', _savedLocations);
  }
}
