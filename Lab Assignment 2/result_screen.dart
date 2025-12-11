import 'package:flutter/material.dart';
import 'history_screen.dart';

class ResultScreen extends StatefulWidget {
  final int guessedNumber;
  final String status;
  final bool isCorrect;
  final VoidCallback onPlayAgain;

  ResultScreen({
    required this.guessedNumber,
    required this.status,
    required this.isCorrect,
    required this.onPlayAgain,
  });

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    )..forward();

    _animation = CurvedAnimation(parent: _animationController, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Result', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.deepPurple,
        automaticallyImplyLeading: false,
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
          child: ScaleTransition(
            scale: _animation,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.isCorrect ? 'Congratulations!' : 'Almost There!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: widget.isCorrect ? Colors.green.shade700 : Colors.deepPurple,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Your guess was:',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    Text(
                      '${widget.guessedNumber}',
                      style: TextStyle(
                        fontSize: 50,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      widget.status,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                        color: widget.isCorrect ? Colors.green.shade600 : Colors.orange.shade800,
                      ),
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: widget.onPlayAgain,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.isCorrect ? Colors.green : Colors.deepPurple,
                      ),
                      child: Text('Play Again'),
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HistoryScreen()),
                        );
                      },
                      child: Text('View History'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
