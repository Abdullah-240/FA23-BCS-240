import 'dart:math';
import 'package:flutter/material.dart';
import '../db/db_helper.dart';
import '../models/game_model.dart';
import 'result_screen.dart';
import 'history_screen.dart';

enum Difficulty { Easy, Medium, Hard }

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final Random _random = Random();
  late int _targetNumber;
  final DBHelper _dbHelper = DBHelper();

  late AnimationController _animationController;
  late Animation<double> _animation;

  Difficulty _difficulty = Difficulty.Medium;
  int _maxNumber = 100;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    // Set initial difficulty without triggering a full rebuild animation
    _updateDifficultyValues(_difficulty);
    _generateRandomNumber();
    _animationController.forward();
  }

  void _setDifficulty(Difficulty newDifficulty) {
    setState(() {
      _updateDifficultyValues(newDifficulty);
      _generateRandomNumber();
      _controller.clear();
      _animationController.reset();
      _animationController.forward();
    });
  }

  void _updateDifficultyValues(Difficulty newDifficulty) {
    _difficulty = newDifficulty;
    switch (newDifficulty) {
      case Difficulty.Easy:
        _maxNumber = 50;
        break;
      case Difficulty.Medium:
        _maxNumber = 100;
        break;
      case Difficulty.Hard:
        _maxNumber = 200;
        break;
    }
  }

  void _generateRandomNumber() {
    _targetNumber = _random.nextInt(_maxNumber) + 1;
  }

  void _guess() {
    final String input = _controller.text;
    if (input.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a number'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    final int? guessedNumber = int.tryParse(input);
    if (guessedNumber == null || guessedNumber < 1 || guessedNumber > _maxNumber) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a valid number between 1 and $_maxNumber'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    String status;
    bool isCorrect = false;
    if (guessedNumber == _targetNumber) {
      status = 'Correct Guess!';
      isCorrect = true;
    } else if (guessedNumber > _targetNumber) {
      status = 'Too High';
    } else {
      status = 'Too Low';
    }

    final GameModel gameModel = GameModel(
      guess: guessedNumber,
      status: status,
      timestamp: DateTime.now(),
    );

    _dbHelper.insertGuess(gameModel);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResultScreen(
          guessedNumber: guessedNumber,
          status: status,
          isCorrect: isCorrect,
          onPlayAgain: () {
            _generateRandomNumber();
            _controller.clear();
            _animationController.reset();
            _animationController.forward();
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Number Guessing Game', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: Icon(Icons.history, size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade50, Colors.deepPurple.shade200],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: FadeTransition(
              opacity: _animation,
              child: Column(
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'I have a secret number between 1 and $_maxNumber.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: Colors.deepPurple,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Can you guess it?',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16, color: Colors.black54),
                          ),
                          SizedBox(height: 30),
                          TextField(
                            controller: _controller,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            decoration: InputDecoration(
                              hintText: '?',
                              hintStyle: TextStyle(color: Colors.grey),
                            ),
                          ),
                          SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: _guess,
                            child: Text('Submit Guess'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  Text(
                    'Select Difficulty',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                  ),
                  SizedBox(height: 10),
                  SegmentedButton<Difficulty>(
                    segments: const <ButtonSegment<Difficulty>>[
                      ButtonSegment<Difficulty>(value: Difficulty.Easy, label: Text('Easy'), icon: Icon(Icons.mood)),
                      ButtonSegment<Difficulty>(value: Difficulty.Medium, label: Text('Medium'), icon: Icon(Icons.balance)),
                      ButtonSegment<Difficulty>(value: Difficulty.Hard, label: Text('Hard'), icon: Icon(Icons.whatshot)),
                    ],
                    selected: {_difficulty},
                    onSelectionChanged: (Set<Difficulty> newSelection) {
                       _setDifficulty(newSelection.first);
                    },
                    style: SegmentedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.5),
                      foregroundColor: Colors.deepPurple,
                      selectedForegroundColor: Colors.white,
                      selectedBackgroundColor: Colors.deepPurple,
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
