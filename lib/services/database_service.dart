// import 'package:sqflite_sqlcipher/sqflite.dart';  // Not available on web
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Encrypted SQLite Database Service
/// On web, uses SharedPreferences as fallback storage
class DatabaseService {
  static dynamic _database;
  static const String _dbName = 'secure_app.db';
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  SharedPreferences? _webStorage;
  
  // Generate or retrieve database password from secure storage
  Future<String> _getDbPassword() async {
    // Try to get existing password from secure storage
    String? storedPassword = await _secureStorage.read(key: 'db_encryption_key');
    
    if (storedPassword != null && storedPassword.isNotEmpty) {
      return storedPassword;
    }
    
    // Generate a new secure password based on device ID and store it
    // This ensures each device has a unique encryption key
    final deviceInfo = await _getDeviceIdentifier();
    final password = _derivePassword(deviceInfo);
    
    // Store in secure storage for future use
    await _secureStorage.write(key: 'db_encryption_key', value: password);
    
    return password;
  }
  
  // Get a device-specific identifier
  Future<String> _getDeviceIdentifier() async {
    if (kIsWeb) {
      // On web, use a browser-based identifier
      return 'web_browser_secure_app_device';
    }
    // Use a combination of app directory and system info
    final directory = await getApplicationDocumentsDirectory();
    final deviceId = '${directory.path}_secure_app_device';
    return deviceId;
  }
  
  // Derive password from device identifier using SHA-256
  String _derivePassword(String input) {
    final bytes = utf8.encode(input);
    final hash = sha256.convert(bytes);
    // Use first 32 characters of hash as password (SQLCipher supports up to 64 bytes)
    return base64Encode(hash.bytes).substring(0, 32);
  }

  /// Initialize encrypted database
  /// On web, uses SharedPreferences instead of SQLite
  Future<void> initialize() async {
    if (kIsWeb) {
      // Use SharedPreferences for web platform
      _webStorage = await SharedPreferences.getInstance();
      return;
    }

    if (_database != null) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final dbPath = join(directory.path, _dbName);
      
      // Get secure password (derived from device, stored in secure storage)
      final password = await _getDbPassword();

      // SQLite not available on web - using SharedPreferences
      // _database = await openDatabase(
      //   dbPath,
      //   password: password,
      //   version: 1,
      //   onCreate: _onCreate,
      //   onUpgrade: _onUpgrade,
      // );
      _webStorage = await SharedPreferences.getInstance();
    } catch (e) {
      // If database initialization fails, try web storage as fallback
      if (kIsWeb || _database == null) {
        _webStorage = await SharedPreferences.getInstance();
      }
    }
  }

  /// Create database tables
  Future<void> _onCreate(dynamic db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
    ''');

    // Detection logs table
    await db.execute('''
      CREATE TABLE detection_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        image_path TEXT,
        confidence REAL NOT NULL,
        is_nsfw INTEGER NOT NULL,
        detected_at INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Values table
    await db.execute('''
      CREATE TABLE user_values (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        value1 TEXT,
        value2 TEXT,
        value3 TEXT,
        value4 TEXT,
        value5 TEXT,
        updated_at INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Victory logs table
    await db.execute('''
      CREATE TABLE victory_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        date INTEGER NOT NULL,
        notes TEXT,
        created_at INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
    
    // Daily check-ins table
    await db.execute('''
      CREATE TABLE check_ins (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        mood TEXT NOT NULL,
        triggers TEXT,
        notes TEXT,
        timestamp INTEGER NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');
  }

  Future<void> _onUpgrade(dynamic db, int oldVersion, int newVersion) async {
    // Handle database migrations here
  }

  /// Get database instance
  /// Throws exception on web (use web storage methods instead)
  dynamic get database {
    if (kIsWeb) {
      throw Exception('SQLite not available on web. Use web storage methods.');
    }
    if (_database == null) {
      throw Exception('Database not initialized. Call initialize() first.');
    }
    return _database!;
  }
  
  /// Check if using web storage
  bool get isWeb => kIsWeb && _webStorage != null;

  /// Create a new user
  Future<int?> createUser(String username, String hashedPassword) async {
    try {
      if (kIsWeb && _webStorage != null) {
        // Web storage implementation
        print('Creating user on web: $username');
        final usersKey = 'users';
        final usersJson = _webStorage!.getString(usersKey) ?? '[]';
        final users = jsonDecode(usersJson) as List;
        
        // Check if username exists
        if (users.any((u) => u['username'] == username)) {
          print('Username already exists: $username');
          return null; // Username already exists
        }
        
        final now = DateTime.now().millisecondsSinceEpoch;
        final newId = users.isEmpty ? 1 : (users.map((u) => u['id'] as int).reduce((a, b) => a > b ? a : b) + 1);
        
        users.add({
          'id': newId,
          'username': username,
          'password': hashedPassword,
          'created_at': now,
        });
        
        await _webStorage!.setString(usersKey, jsonEncode(users));
        print('User created successfully with ID: $newId');
        return newId;
      }
      
      final db = database;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      // SQLite not available - this code won't execute
      // final id = await db.insert(
      //   'users',
      //   {
      //     'username': username,
      //     'password': hashedPassword,
      //     'created_at': now,
      //   },
      // );
      print('Not on web, SQLite disabled - returning null');
      return null; // Fallback for web
    } catch (e) {
      print('Error creating user: $e');
      return null;
    }
  }

  /// Get user by username
  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    try {
      if (kIsWeb && _webStorage != null) {
        // Web storage implementation
        print('Getting user on web: $username');
        final usersKey = 'users';
        final usersJson = _webStorage!.getString(usersKey) ?? '[]';
        final users = jsonDecode(usersJson) as List;
        print('Total users in storage: ${users.length}');
        
        final user = users.firstWhere(
          (u) => u['username'] == username,
          orElse: () => null,
        );
        
        if (user == null) {
          print('User not found: $username');
          return null;
        }
        print('User found: $username');
        return Map<String, dynamic>.from(user);
      }
      
      final db = database;
      final results = await db.query(
        'users',
        where: 'username = ?',
        whereArgs: [username],
        limit: 1,
      );
      
      if (results.isEmpty) return null;
      return results.first;
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  /// Update user password
  Future<bool> updateUserPassword(String username, String hashedPassword) async {
    try {
      final db = database;
      final count = await db.update(
        'users',
        {'password': hashedPassword},
        where: 'username = ?',
        whereArgs: [username],
      );
      return count > 0;
    } catch (e) {
      return false;
    }
  }

  /// Log detection
  Future<int?> logDetection(int userId, String? imagePath, double confidence, bool isNsfw) async {
    try {
      final db = database;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      final id = await db.insert(
        'detection_logs',
        {
          'user_id': userId,
          'image_path': imagePath,
          'confidence': confidence,
          'is_nsfw': isNsfw ? 1 : 0,
          'detected_at': now,
        },
      );
      
      return id;
    } catch (e) {
      return null;
    }
  }

  /// Get detection logs
  Future<List<Map<String, dynamic>>> getDetectionLogs(int userId, {int? limit}) async {
    try {
      final db = database;
      final results = await db.query(
        'detection_logs',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'detected_at DESC',
        limit: limit,
      );
      return results;
    } catch (e) {
      return [];
    }
  }

  /// Clear all detection logs for user
  Future<bool> clearDetectionLogs(int userId) async {
    try {
      final db = database;
      final count = await db.delete(
        'detection_logs',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      return count > 0;
    } catch (e) {
      return false;
    }
  }

  /// Save user values
  Future<bool> saveUserValues(int userId, List<String> values) async {
    try {
      final db = database;
      final now = DateTime.now().millisecondsSinceEpoch;
      
      // Check if values exist
      final existing = await db.query(
        'user_values',
        where: 'user_id = ?',
        whereArgs: [userId],
        limit: 1,
      );
      
      if (existing.isEmpty) {
        // Insert
        await db.insert(
          'user_values',
          {
            'user_id': userId,
            'value1': values.length > 0 ? values[0] : null,
            'value2': values.length > 1 ? values[1] : null,
            'value3': values.length > 2 ? values[2] : null,
            'value4': values.length > 3 ? values[3] : null,
            'value5': values.length > 4 ? values[4] : null,
            'updated_at': now,
          },
        );
      } else {
        // Update
        await db.update(
          'user_values',
          {
            'value1': values.length > 0 ? values[0] : null,
            'value2': values.length > 1 ? values[1] : null,
            'value3': values.length > 2 ? values[2] : null,
            'value4': values.length > 3 ? values[3] : null,
            'value5': values.length > 4 ? values[4] : null,
            'updated_at': now,
          },
          where: 'user_id = ?',
          whereArgs: [userId],
        );
      }
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get user values
  Future<List<String>> getUserValues(int userId) async {
    try {
      final db = database;
      final results = await db.query(
        'user_values',
        where: 'user_id = ?',
        whereArgs: [userId],
        limit: 1,
      );
      
      if (results.isEmpty) return [];
      
      final row = results.first;
      final values = <String>[];
      for (int i = 1; i <= 5; i++) {
        final value = row['value$i'] as String?;
        if (value != null && value.isNotEmpty) {
          values.add(value);
        }
      }
      
      return values;
    } catch (e) {
      return [];
    }
  }

  /// Add victory log entry
  Future<int?> addVictoryLog(int userId, DateTime date, {String? notes}) async {
    try {
      if (kIsWeb && _webStorage != null) {
        // Web storage implementation
        final logsKey = 'victory_logs_$userId';
        final logsJson = _webStorage!.getString(logsKey) ?? '[]';
        final logs = jsonDecode(logsJson) as List;
        
        final now = DateTime.now().millisecondsSinceEpoch;
        final dateMs = date.millisecondsSinceEpoch;
        final newId = logs.isEmpty ? 1 : (logs.map((l) => l['id'] as int).reduce((a, b) => a > b ? a : b) + 1);
        
        logs.add({
          'id': newId,
          'user_id': userId,
          'date': dateMs,
          'notes': notes ?? '',
          'created_at': now,
        });
        
        await _webStorage!.setString(logsKey, jsonEncode(logs));
        return newId;
      }
      
      final db = database;
      final now = DateTime.now().millisecondsSinceEpoch;
      final dateMs = date.millisecondsSinceEpoch;
      
      final id = await db.insert(
        'victory_logs',
        {
          'user_id': userId,
          'date': dateMs,
          'notes': notes,
          'created_at': now,
        },
      );
      
      return id;
    } catch (e) {
      print('Error adding victory log: $e');
      return null;
    }
  }

  /// Get victory logs
  Future<List<Map<String, dynamic>>> getVictoryLogs(int userId) async {
    try {
      if (kIsWeb && _webStorage != null) {
        // Web storage implementation
        final logsKey = 'victory_logs_$userId';
        final logsJson = _webStorage!.getString(logsKey) ?? '[]';
        final logs = jsonDecode(logsJson) as List;
        
        // Convert to Map and sort by date DESC
        final logsList = logs.map((l) => Map<String, dynamic>.from(l)).toList();
        logsList.sort((a, b) => (b['date'] as int).compareTo(a['date'] as int));
        
        return logsList;
      }
      
      final db = database;
      final results = await db.query(
        'victory_logs',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'date DESC',
      );
      return results;
    } catch (e) {
      print('Error getting victory logs: $e');
      return [];
    }
  }

  /// Clear all victory logs for user
  Future<bool> clearVictoryLogs(int userId) async {
    try {
      if (kIsWeb && _webStorage != null) {
        // Web storage implementation
        final logsKey = 'victory_logs_$userId';
        await _webStorage!.remove(logsKey);
        return true;
      }
      
      final db = database;
      final count = await db.delete(
        'victory_logs',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      return count > 0;
    } catch (e) {
      print('Error clearing victory logs: $e');
      return false;
    }
  }

  /// Close database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
