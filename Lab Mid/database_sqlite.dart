import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart'
    hide databaseFactory; // hide to allow conditional factories
import 'package:path/path.dart';
// dart:io not used on web fallback; keep code cross-platform.
// For desktop support (Windows/Linux/Mac) you can use sqflite_common_ffi when
// running on native desktop. For web, sqflite isn't supported so we fall back
// to an in-memory list (non-persistent) to keep the UI functional.
// Note: add `sqflite_common_ffi` to pubspec if you want real desktop DB.
// import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/patient.dart';

class DatabaseService extends ChangeNotifier {
  Database? _database;
  List<Patient> _patients = [];
  bool _isLoading = false;

  List<Patient> get patients => _patients;
  bool get isLoading => _isLoading;

  Future<Database> get database async {
    if (_database != null) return _database!;
    if (kIsWeb) {
      // Web: use in-memory fallback. We'll still return a dummy database by
      // throwing so callers that expect DB won't use it; but our methods will
      // avoid calling the DB when kIsWeb.
      throw UnsupportedError(
        'Database not supported on web; use in-memory methods',
      );
    }

    // For native platforms use sqflite as normal. If you need desktop sqlite
    // support, consider initializing sqflite_common_ffi here.
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'doctor_patient_records.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE patients(
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        dateOfBirth TEXT,
        phoneNumber TEXT,
        email TEXT,
        address TEXT,
        medicalHistory TEXT,
        allergies TEXT,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  Future<void> loadPatients() async {
    _isLoading = true;
    notifyListeners();
    try {
      if (kIsWeb) {
        // On web we don't have persistent DB here; keep current _patients
        // (in-memory). If you want persistence on web, integrate localStorage
        // or shared_preferences web implementation.
        // For now, no-op — the in-memory list is the source of truth.
      } else {
        final db = await database;
        final List<Map<String, dynamic>> maps = await db.query(
          'patients',
          orderBy: 'createdAt DESC',
        );

        _patients = List.generate(maps.length, (i) {
          return Patient.fromMap(maps[i]);
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading patients: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addPatient(Patient patient) async {
    try {
      if (kIsWeb) {
        // In-memory add
        _patients.insert(0, patient);
        notifyListeners();
        return true;
      }

      final db = await database;
      await db.insert(
        'patients',
        patient.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await loadPatients(); // Refresh the list
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error adding patient: $e');
      }
      return false;
    }
  }

  Future<bool> updatePatient(Patient patient) async {
    try {
      if (kIsWeb) {
        final index = _patients.indexWhere((p) => p.id == patient.id);
        if (index != -1) {
          _patients[index] = patient;
          notifyListeners();
          return true;
        }
        return false;
      }

      final db = await database;
      await db.update(
        'patients',
        patient.toMap(),
        where: 'id = ?',
        whereArgs: [patient.id],
      );
      await loadPatients(); // Refresh the list
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error updating patient: $e');
      }
      return false;
    }
  }

  Future<bool> deletePatient(int id) async {
    try {
      if (kIsWeb) {
        _patients.removeWhere((p) => p.id == id);
        notifyListeners();
        return true;
      }

      final db = await database;
      await db.delete('patients', where: 'id = ?', whereArgs: [id]);
      await loadPatients(); // Refresh the list
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error deleting patient: $e');
      }
      return false;
    }
  }

  Future<Patient?> getPatientById(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'patients',
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isNotEmpty) {
        return Patient.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting patient: $e');
      }
      return null;
    }
  }

  Future<List<Patient>> searchPatients(String query) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        'patients',
        where: 'name LIKE ? OR phoneNumber LIKE ? OR email LIKE ?',
        whereArgs: ['%$query%', '%$query%', '%$query%'],
        orderBy: 'name ASC',
      );

      return List.generate(maps.length, (i) {
        return Patient.fromMap(maps[i]);
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error searching patients: $e');
      }
      return [];
    }
  }

  @override
  void dispose() {
    _database?.close();
    super.dispose();
  }
}
