class GameModel {
  final int? id;
  final int guess;
  final String status;
  final DateTime timestamp;

  GameModel({
    this.id,
    required this.guess,
    required this.status,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'guess': guess,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
