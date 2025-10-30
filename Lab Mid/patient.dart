class Patient {
  final int id;
  final String name;
  final String dateOfBirth;
  final String phoneNumber;
  final String email;
  final String address;
  final String medicalHistory;
  final String allergies;
  final DateTime createdAt;

  Patient({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    required this.phoneNumber,
    required this.email,
    required this.address,
    required this.medicalHistory,
    required this.allergies,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dateOfBirth': dateOfBirth,
      'phoneNumber': phoneNumber,
      'email': email,
      'address': address,
      'medicalHistory': medicalHistory,
      'allergies': allergies,
      // Keep createdAt as DateTime so Firestore stores it as a Timestamp when using cloud_firestore.
      // If you need ISO strings instead, change this to createdAt.toIso8601String().
      'createdAt': createdAt,
    };
  }

  factory Patient.fromMap(Map<String, dynamic> map) {
    // Helper to convert various input types to String safely
    String _asString(dynamic v) => v == null ? '' : v.toString();

    // Parse id (int or numeric string)
    int _parseId(dynamic rawId) {
      if (rawId is int) return rawId;
      if (rawId is double) return rawId.toInt();
      if (rawId is String) return int.tryParse(rawId) ?? 0;
      return 0;
    }

    // Parse createdAt from DateTime, ISO string, or timestamp-like objects (with toDate())
    DateTime _parseCreatedAt(dynamic raw) {
      if (raw == null) return DateTime.now();
      if (raw is DateTime) return raw;
      if (raw is String) return DateTime.tryParse(raw) ?? DateTime.now();
      // Try to call toDate() for Firestore Timestamp without importing cloud_firestore
      try {
        final dynamic maybe = raw;
        final dynamic date = maybe.toDate();
        if (date is DateTime) return date;
      } catch (_) {
        // fallthrough
      }
      return DateTime.now();
    }

    return Patient(
      id: _parseId(map['id']),
      name: _asString(map['name']),
      dateOfBirth: _asString(map['dateOfBirth']),
      phoneNumber: _asString(map['phoneNumber']),
      email: _asString(map['email']),
      address: _asString(map['address']),
      medicalHistory: _asString(map['medicalHistory']),
      allergies: _asString(map['allergies']),
      createdAt: _parseCreatedAt(map['createdAt']),
    );
  }

  Patient copyWith({
    int? id,
    String? name,
    String? dateOfBirth,
    String? phoneNumber,
    String? email,
    String? address,
    String? medicalHistory,
    String? allergies,
    DateTime? createdAt,
  }) {
    return Patient(
      id: id ?? this.id,
      name: name ?? this.name,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      address: address ?? this.address,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      allergies: allergies ?? this.allergies,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Patient{id: $id, name: $name, dateOfBirth: $dateOfBirth, phoneNumber: $phoneNumber, email: $email, address: $address, medicalHistory: $medicalHistory, allergies: $allergies, createdAt: $createdAt}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Patient &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          dateOfBirth == other.dateOfBirth &&
          phoneNumber == other.phoneNumber &&
          email == other.email &&
          address == other.address &&
          medicalHistory == other.medicalHistory &&
          allergies == other.allergies &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      dateOfBirth.hashCode ^
      phoneNumber.hashCode ^
      email.hashCode ^
      address.hashCode ^
      medicalHistory.hashCode ^
      allergies.hashCode ^
      createdAt.hashCode;
}
