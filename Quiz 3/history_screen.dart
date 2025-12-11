import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/bmi_record.dart';
import '../services/history_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final HistoryService _historyService = HistoryService();
  late Future<List<BmiRecord>> _history;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    setState(() {
      _history = _historyService.getHistory();
    });
  }

  void _clearHistory() async {
    await _historyService.clearHistory();
    _loadHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: _clearHistory,
          ),
        ],
      ),
      body: FutureBuilder<List<BmiRecord>>(
        future: _history,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load history.'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No history yet.',
                style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
              ),
            );
          }

          final records = snapshot.data!;

          return ListView.builder(
            itemCount: records.length,
            itemBuilder: (context, index) {
              final record = records[index];
              return ListTile(
                title: Text('${record.name} - BMI: ${record.bmi.toStringAsFixed(1)}'),
                subtitle: Text('${record.category} on ${DateFormat.yMMMd().format(record.date)}'),
                trailing: _getCategoryIcon(context, record.category),
              );
            },
          );
        },
      ),
    );
  }

  Widget _getCategoryIcon(BuildContext context, String category) {
    final colorScheme = Theme.of(context).colorScheme;
    switch (category) {
      case 'Underweight':
        return Icon(Icons.trending_down, color: colorScheme.primary);
      case 'Normal':
        return Icon(Icons.check_circle_outline, color: Colors.green);
      case 'Overweight':
        return Icon(Icons.trending_up, color: Colors.orange);
      case 'Obese':
        return Icon(Icons.warning_amber_rounded, color: colorScheme.error);
      default:
        return const Icon(Icons.help_outline, color: Colors.grey);
    }
  }
}
