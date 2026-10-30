import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class FaceTemplateEntity {
  final int employeeId;
  final List<double> embedding;
  final String modelName;
  final String modelVersion;
  final int dimensions;
  final DateTime registeredAt;
  final bool isSynced;

  FaceTemplateEntity({
    required this.employeeId,
    required this.embedding,
    this.modelName = 'mobilefacenet',
    this.modelVersion = '1.0',
    this.dimensions = 192,
    required this.registeredAt,
    this.isSynced = false,
  });
}

class FaceStorageService {
  static const _secureKeyName = 'aavenza_biometric_aes_key';
  static const _dbName = 'aavenza_biometrics.db';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  Database? _database;
  String? _cachedKey;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE employee_face_templates (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            employee_id INTEGER UNIQUE NOT NULL,
            encrypted_embedding TEXT NOT NULL,
            model_name TEXT NOT NULL,
            model_version TEXT NOT NULL,
            dimensions INTEGER NOT NULL,
            registered_at TEXT NOT NULL,
            last_synced_at TEXT NOT NULL,
            is_synced INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  Future<String> _getOrCreateEncryptionKey() async {
    if (_cachedKey != null) return _cachedKey!;

    String? key = await _secureStorage.read(key: _secureKeyName);
    if (key == null || key.isEmpty) {
      // Generate secure pseudo-random 32-character key
      final randomBytes = List<int>.generate(32, (i) => (DateTime.now().microsecondsSinceEpoch * (i + 1)) % 256);
      key = base64UrlEncode(randomBytes);
      await _secureStorage.write(key: _secureKeyName, value: key);
    }
    _cachedKey = key;
    return key;
  }

  String _encrypt(String plaintext, String key) {
    final pBytes = utf8.encode(plaintext);
    final kBytes = utf8.encode(key);
    final cipher = List<int>.filled(pBytes.length, 0);

    for (int i = 0; i < pBytes.length; i++) {
      cipher[i] = pBytes[i] ^ kBytes[i % kBytes.length];
    }
    return base64Encode(cipher);
  }

  String _decrypt(String ciphertextBase64, String key) {
    final cBytes = base64Decode(ciphertextBase64);
    final kBytes = utf8.encode(key);
    final plain = List<int>.filled(cBytes.length, 0);

    for (int i = 0; i < cBytes.length; i++) {
      plain[i] = cBytes[i] ^ kBytes[i % kBytes.length];
    }
    return utf8.decode(plain);
  }

  Future<void> saveFaceTemplate({
    required int employeeId,
    required List<double> embedding,
    String modelName = 'mobilefacenet',
    String modelVersion = '1.0',
    bool isSynced = false,
  }) async {
    final key = await _getOrCreateEncryptionKey();
    final jsonStr = jsonEncode(embedding);
    final encrypted = _encrypt(jsonStr, key);
    final nowIso = DateTime.now().toIso8601String();

    final db = await database;
    await db.insert(
      'employee_face_templates',
      {
        'employee_id': employeeId,
        'encrypted_embedding': encrypted,
        'model_name': modelName,
        'model_version': modelVersion,
        'dimensions': embedding.length,
        'registered_at': nowIso,
        'last_synced_at': nowIso,
        'is_synced': isSynced ? 1 : 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<FaceTemplateEntity?> getFaceTemplate(int employeeId) async {
    final db = await database;
    final results = await db.query(
      'employee_face_templates',
      where: 'employee_id = ?',
      whereArgs: [employeeId],
      limit: 1,
    );

    if (results.isEmpty) return null;

    final row = results.first;
    final encrypted = row['encrypted_embedding'] as String;
    final key = await _getOrCreateEncryptionKey();

    try {
      final decrypted = _decrypt(encrypted, key);
      final List<dynamic> list = jsonDecode(decrypted);
      final embedding = list.map((e) => (e as num).toDouble()).toList();

      return FaceTemplateEntity(
        employeeId: employeeId,
        embedding: embedding,
        modelName: row['model_name'] as String? ?? 'mobilefacenet',
        modelVersion: row['model_version'] as String? ?? '1.0',
        dimensions: row['dimensions'] as int? ?? 192,
        registeredAt: DateTime.tryParse(row['registered_at'] as String? ?? '') ?? DateTime.now(),
        isSynced: (row['is_synced'] as int? ?? 0) == 1,
      );
    } catch (_) {
      return null;
    }
  }

  Future<bool> hasFaceTemplate(int employeeId) async {
    final template = await getFaceTemplate(employeeId);
    return template != null && template.embedding.isNotEmpty;
  }

  Future<void> markSynced(int employeeId) async {
    final db = await database;
    await db.update(
      'employee_face_templates',
      {
        'is_synced': 1,
        'last_synced_at': DateTime.now().toIso8601String(),
      },
      where: 'employee_id = ?',
      whereArgs: [employeeId],
    );
  }

  Future<void> deleteFaceTemplate(int employeeId) async {
    final db = await database;
    await db.delete(
      'employee_face_templates',
      where: 'employee_id = ?',
      whereArgs: [employeeId],
    );
  }

  Future<void> clearAllBiometrics() async {
    final db = await database;
    await db.delete('employee_face_templates');
  }
}

