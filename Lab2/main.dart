import 'package:flutter/material.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatefulWidget {
  const CalculatorApp({super.key});

  @override
  State<CalculatorApp> createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calculator',
      debugShowCheckedModeBanner: false,
      theme: isDark ? ThemeData.dark() : ThemeData.light(),
      home: CalculatorScreen(
        onThemeToggle: () {
          setState(() {
            isDark = !isDark;
          });
        },
      ),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  final VoidCallback onThemeToggle;
  const CalculatorScreen({super.key, required this.onThemeToggle});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  String _output = "0";
  String _input = "";
  String _expression = "";
  double num1 = 0;
  double num2 = 0;
  String operand = "";

  void buttonPressed(String buttonText) {
    if (buttonText == "C") {
      _input = "";
      _expression = "";
      num1 = 0;
      num2 = 0;
      operand = "";
      _output = "0";
    } else if (["+", "-", "×", "÷"].contains(buttonText)) {
      if (_input.isNotEmpty) {
        num1 = double.parse(_input);
        operand = buttonText;
        _expression = "$_input $operand ";
        _input = "";
      }
    } else if (buttonText == "=") {
      if (_input.isNotEmpty && operand.isNotEmpty) {
        num2 = double.parse(_input);

        if (operand == "+") {
          _output = (num1 + num2).toString();
        } else if (operand == "-") {
          _output = (num1 - num2).toString();
        } else if (operand == "×") {
          _output = (num1 * num2).toString();
        } else if (operand == "÷") {
          _output = (num2 != 0) ? (num1 / num2).toString() : "Error";
        }
        _expression = "$num1 $operand $num2 =";
        _input = _output;
        operand = "";
      }
    } else {
      _input += buttonText;
      _output = _input;
      _expression = _expression.isEmpty ? _input : _expression + buttonText;
    }

    setState(() {});
  }

  Widget buildButton(String text) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(6),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => buttonPressed(text),
          child: Text(
            text,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget buildButtonRow(List<String> texts) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: texts.map((t) => buildButton(t)).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Calculator"),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.onThemeToggle,
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔹 Display (upper big area)
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: Colors.black12,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    _expression,
                    style: const TextStyle(fontSize: 24, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _output,
                    style: const TextStyle(
                        fontSize: 50, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),

          // 🔹 Keyboard (fixed at bottom)
          Expanded(
            flex: 2,
            child: Column(
              children: [
                buildButtonRow(["7", "8", "9", "÷"]),
                buildButtonRow(["4", "5", "6", "×"]),
                buildButtonRow(["1", "2", "3", "-"]),
                buildButtonRow(["C", "0", "=", "+"]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
