import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../main.dart';
import 'result_screen.dart';
import 'history_screen.dart';
import '../widgets/input_field.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  bool _isMetric = true;
  bool _isMale = true;

  void _calculateBMI() {
    final String name = _nameController.text.trim();
    final String hText = _heightController.text.trim();
    final String wText = _weightController.text.trim();
    String? errorMessage;

    if (name.isEmpty) {
      errorMessage = 'Please enter your name.';
    } else if (hText.isEmpty || wText.isEmpty) {
      errorMessage = 'Please enter both height and weight.';
    } else {
      final double? height = double.tryParse(hText);
      final double? weight = double.tryParse(wText);

      if (height == null || height <= 0) {
        errorMessage = 'Height must be a positive number (in ${_isMetric ? 'cm' : 'in'}).';
      } else if (weight == null || weight <= 0) {
        errorMessage = 'Weight must be a positive number (in ${_isMetric ? 'kg' : 'lbs'}).';
      }
    }

    if (errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final double height = double.tryParse(hText)!;
    final double weight = double.tryParse(wText)!;

    double heightM;
    double weightKg;

    if (_isMetric) {
      heightM = height / 100.0;
      weightKg = weight;
    } else {
      heightM = (height * 2.54) / 100.0;
      weightKg = weight * 0.453592;
    }

    final double bmi = weightKg / (heightM * heightM);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(bmi: bmi, name: name),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    return (await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exit App?'),
            content: const Text('Are you sure you want to leave?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => exit(0),
                child: const Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('BMI Calculator'),
          centerTitle: true,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HistoryScreen()),
                );
              },
            ),
            IconButton(
              icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
              onPressed: () {
                MyApp.of(context).changeTheme(
                  isDarkMode ? ThemeMode.light : ThemeMode.dark,
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                InputField(
                  controller: _nameController,
                  label: 'Your Name',
                  hint: 'e.g. John Doe',
                  keyboardType: TextInputType.name,
                ).animate().fade().slideY(duration: 500.ms),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ToggleButtons(
                        isSelected: [_isMale, !_isMale],
                        onPressed: (index) {
                          setState(() {
                            _isMale = index == 0;
                          });
                        },
                        borderRadius: BorderRadius.circular(8.0),
                        constraints: const BoxConstraints(minHeight: 40.0),
                        children: const [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text('Male'),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text('Female'),
                          ),
                        ],
                      ).animate().fade(delay: 200.ms).slideY(duration: 500.ms),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ToggleButtons(
                        isSelected: [_isMetric, !_isMetric],
                        onPressed: (index) {
                          setState(() {
                            _isMetric = index == 0;
                          });
                        },
                        borderRadius: BorderRadius.circular(8.0),
                        constraints: const BoxConstraints(minHeight: 40.0),
                        children: const [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text('Metric'),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text('Imperial'),
                          ),
                        ],
                      ).animate().fade(delay: 400.ms).slideY(duration: 500.ms),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                InputField(
                  controller: _heightController,
                  label: _isMetric ? 'Height (cm)' : 'Height (in)',
                  hint: _isMetric ? 'e.g. 170' : 'e.g. 67',
                  keyboardType: TextInputType.number,
                ).animate().fade(delay: 600.ms).slideY(duration: 500.ms),
                const SizedBox(height: 16),
                InputField(
                  controller: _weightController,
                  label: _isMetric ? 'Weight (kg)' : 'Weight (lbs)',
                  hint: _isMetric ? 'e.g. 65' : 'e.g. 143',
                  keyboardType: TextInputType.number,
                ).animate().fade(delay: 800.ms).slideY(duration: 500.ms),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _calculateBMI,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: colorScheme.primary,
                    foregroundColor: colorScheme.onPrimary,
                  ),
                  child: const Text('Calculate BMI', style: TextStyle(fontSize: 16)),
                ).animate().fade(delay: 1000.ms).slideY(duration: 500.ms),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    _nameController.clear();
                    _heightController.clear();
                    _weightController.clear();
                  },
                  child: const Text('Reset'),
                ).animate().fade(delay: 1200.ms).slideY(duration: 500.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
