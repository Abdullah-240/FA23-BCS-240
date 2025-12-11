import 'dart:convert';

class BmiRecord {
  final String name;
  final double bmi;
  final String category;
  final DateTime date;

  BmiRecord({
    required this.name,
    required this.bmi,
    required this.category,
    required this.date,
  });

  // Methods for JSON serialization, useful for storing in shared_preferences
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'bmi': bmi,
      'category': category,
      'date': date.toIso8601String(),
    };
  }

  factory BmiRecord.fromMap(Map<String, dynamic> map) {
    return BmiRecord(
      name: map['name'],
      bmi: map['bmi'],
      category: map['category'],
      date: DateTime.parse(map['date']),
    );
  }

  String toJson() => json.encode(toMap());

  factory BmiRecord.fromJson(String source) => BmiRecord.fromMap(json.decode(source));
}
