import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../models/bmi_record.dart';
import '../services/history_service.dart';

class ResultScreen extends StatefulWidget {
  final double bmi;
  final String name;
  const ResultScreen({super.key, required this.bmi, required this.name});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final HistoryService _historyService = HistoryService();

  @override
  void initState() {
    super.initState();
    _saveResult();
  }

  void _saveResult() async {
    final record = BmiRecord(
      name: widget.name,
      bmi: widget.bmi,
      category: _category(widget.bmi),
      date: DateTime.now(),
    );
    await _historyService.saveRecord(record);
  }

  String _category(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  Color _categoryColor(BuildContext context, String cat) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (cat) {
      case 'Underweight':
        return colorScheme.primary;
      case 'Normal':
        return Colors.green;
      case 'Overweight':
        return Colors.orange;
      case 'Obese':
        return colorScheme.error;
      default:
        return Colors.grey;
    }
  }

  List<String> _getTips(String cat) {
    switch (cat) {
      case 'Underweight':
        return [
          'Eat more frequently. Eat five to six smaller meals during the day.',
          'Choose nutrient-rich foods, including whole grains, fruits, vegetables, and lean protein.',
          'Try smoothies and shakes for extra calories and nutrients.',
        ];
      case 'Normal':
        return [
          'Maintain a balanced diet with a variety of nutrient-rich foods.',
          'Stay active with at least 30 minutes of moderate exercise most days.',
          'Ensure you get 7-9 hours of quality sleep per night.',
        ];
      case 'Overweight':
        return [
          'Focus on portion control and be mindful of serving sizes.',
          'Increase physical activity to at least 150 minutes per week.',
          'Limit processed foods, sugary drinks, and unhealthy fats.',
        ];
      case 'Obese':
        return [
          'Consult a healthcare professional for a personalized health plan.',
          'Focus on long-term lifestyle changes, not quick fixes.',
          'Incorporate regular, enjoyable physical activity into your daily routine.',
        ];
      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final String cat = _category(widget.bmi);
    final Color catColor = _categoryColor(context, cat);
    final List<String> tips = _getTips(cat);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('Result for ${widget.name}'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              Share.share(
                'My BMI is ${widget.bmi.toStringAsFixed(1)} ($cat). What is yours? Check out this awesome BMI Calculator!',
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 250,
              child: SfRadialGauge(
                axes: <RadialAxis>[
                  RadialAxis(
                    minimum: 10,
                    maximum: 40,
                    ranges: <GaugeRange>[
                      GaugeRange(startValue: 10, endValue: 18.5, color: _categoryColor(context, 'Underweight')),
                      GaugeRange(startValue: 18.5, endValue: 25, color: _categoryColor(context, 'Normal')),
                      GaugeRange(startValue: 25, endValue: 30, color: _categoryColor(context, 'Overweight')),
                      GaugeRange(startValue: 30, endValue: 40, color: _categoryColor(context, 'Obese')),
                    ],
                    pointers: <GaugePointer>[
                      NeedlePointer(value: widget.bmi, enableAnimation: true)
                    ],
                    annotations: <GaugeAnnotation>[
                      GaugeAnnotation(
                        widget: Text(
                          widget.bmi.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: catColor,
                          ),
                        ),
                        angle: 90,
                        positionFactor: 0.5,
                      )
                    ],
                  )
                ],
              ),
            ).animate().fade(duration: 600.ms).scale(),
            const SizedBox(height: 12),
            Chip(
              label: Text(cat, style: TextStyle(fontSize: 18, color: colorScheme.onPrimary)),
              backgroundColor: catColor,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ).animate().fade(delay: 200.ms).slideY(),
            const SizedBox(height: 20),
            Text(
              _interpretation(cat),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ).animate().fade(delay: 400.ms).slideY(),
            const SizedBox(height: 32),
            if (tips.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Health Tips',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ).animate().fade(delay: 600.ms).slideX(),
                  const SizedBox(height: 12),
                  ...tips.asMap().entries.map((entry) {
                    int idx = entry.key;
                    String tip = entry.value;
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          child: Text('${idx + 1}'),
                        ),
                        title: Text(tip),
                      ),
                    ).animate().fade(delay: (800 + idx * 200).ms).slideY();
                  }),
                ],
              ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back'),
            ).animate().fade(delay: 1400.ms).slideY(),
          ],
        ),
      ),
    );
  }

  String _interpretation(String cat) {
    switch (cat) {
      case 'Underweight':
        return 'You are underweight. Consider a balanced diet and strength training.';
      case 'Normal':
        return 'Great! Your BMI is in the normal range. Keep it up.';
      case 'Overweight':
        return 'You are overweight. Consider exercise and a calorie-controlled diet.';
      case 'Obese':
        return 'Your BMI falls in the obese range. Please consult a healthcare professional.';
      default:
        return '';
    }
  }
}
