import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.health_and_safety_outlined,
                size: 120,
                color: colorScheme.primary,
              ).animate().fade(delay: 200.ms).scale(duration: 600.ms),
              const SizedBox(height: 24),
              const Text(
                'Welcome to BMI Calculator',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ).animate().fade(delay: 400.ms).slideY(),
              const SizedBox(height: 12),
              const Text(
                'Track your Body Mass Index and stay healthy!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ).animate().fade(delay: 600.ms).slideY(),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                ),
                child: const Text('Get Started', style: TextStyle(fontSize: 16)),
              ).animate().fade(delay: 800.ms).slideY(),
            ],
          ),
        ),
      ),
    );
  }
}
