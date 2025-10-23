import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const DiceApp());
}

class DiceApp extends StatefulWidget {
  const DiceApp({super.key});

  @override
  State<DiceApp> createState() => _DiceAppState();
}

class _DiceAppState extends State<DiceApp> with SingleTickerProviderStateMixin {
  int diceNumber = 1;
  int? guessedNumber;
  bool isRolling = false;
  ThemeMode _themeMode = ThemeMode.system;

  late AnimationController _controller;
  late Animation<double> _rotationX;
  late Animation<double> _rotationY;

  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );

    _rotationX = Tween<double>(begin: 0, end: 4 * pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _rotationY = Tween<double>(begin: 0, end: 6 * pi).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  void playSound() async {
    try {
      await player.play(AssetSource('roll.mp3'));
    } catch (e) {
      debugPrint("Error playing sound: $e");
    }
  }

  void rollDice() async {
    if (isRolling) return;

    playSound();
    setState(() => isRolling = true);
    _controller.forward(from: 0);

    await Future.delayed(const Duration(milliseconds: 600));
    int newNumber = Random().nextInt(6) + 1;

    setState(() {
      diceNumber = newNumber;
      isRolling = false;
    });

    await Future.delayed(const Duration(milliseconds: 200));

    // This is the popup logic you requested. It checks if the guess matches.
    if (guessedNumber != null) {
      if (guessedNumber == diceNumber) {
        _showPopup("🎯 Correct Guess!", Colors.green);
      } else {
        _showPopup("❌ Wrong Guess! The roll was $diceNumber.", Colors.red);
      }
      setState(() {
        guessedNumber = null;
      });
    }
  }

  void _toggleThemeMode() {
    setState(() {
      if (_themeMode == ThemeMode.system) {
        _themeMode = ThemeMode.light;
      } else if (_themeMode == ThemeMode.light) {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.system;
      }
    });
  }

  IconData _getThemeIcon() {
    switch (_themeMode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      default:
        return Icons.brightness_auto;
    }
  }

  void _showPopup(String message, Color color) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK", style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }

  void resetDice() {
    setState(() {
      diceNumber = 1;
      guessedNumber = null;
      isRolling = false;
      _controller.reset();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDark = _themeMode == ThemeMode.dark || (_themeMode == ThemeMode.system && brightness == Brightness.dark);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.transparent, // Required for gradient
      ),
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.transparent, // Required for gradient
      ),
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent, // Make AppBar transparent
          elevation: 0,
          title: const Text("🎲 3D Dice Roller"),
          centerTitle: true,
          actions: [
            IconButton(
              icon: Icon(_getThemeIcon()),
              onPressed: _toggleThemeMode,
              tooltip: "Toggle Theme",
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: resetDice,
              tooltip: "Reset",
            ),
          ],
        ),
        // Extend the body behind the app bar for a seamless gradient
        extendBodyBehindAppBar: true,
        body: Container(
          // NEW: Added BoxDecoration for the gradient background
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF141E30), const Color(0xFF243B55)] // Dark Gradient
                  : [const Color(0xFFE0EAFC), const Color(0xFFCFDEF3)], // Light Gradient
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.only(left: 20, right: 20, top: 100), // Adjusted padding for AppBar
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                flex: 5,
                child: Center(
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..setEntry(3, 2, 0.001)
                          ..rotateX(_rotationX.value)
                          ..rotateY(_rotationY.value),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: isDark ? Colors.white54 : Colors.black26,
                                width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? Colors.white10
                                    : Colors.black26,
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                            // Add a subtle background to the dice container for better visibility
                            color: isDark ? Colors.black.withOpacity(0.2) : Colors.white.withOpacity(0.2),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: Image.asset(
                              'assets/dice$diceNumber.png',
                              height: 220,
                              width: 220,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Rolled: $diceNumber",
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 25),

              // NEW: "Guess a Number" Title added here
              const Text(
                "Guess a Number",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 15),

              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: List.generate(6, (index) {
                  int number = index + 1;
                  bool isSelected = guessedNumber == number;
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected
                          ? Colors.blueAccent
                          : (isDark ? Colors.white.withOpacity(0.1) : Colors.white.withOpacity(0.4)),
                      foregroundColor: isSelected ? Colors.white : (isDark ? Colors.white : Colors.black),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        guessedNumber = number;
                      });
                    },
                    child: Text(
                      "$number",
                      style: const TextStyle(fontSize: 20),
                    ),
                  );
                }),
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: isRolling ? null : rollDice,
                icon: const Icon(Icons.casino),
                label: Text(isRolling ? "Rolling..." : "Roll Dice"),
                style: ElevatedButton.styleFrom(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  backgroundColor:
                  isDark ? Colors.tealAccent[400] : Colors.green,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  textStyle: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}