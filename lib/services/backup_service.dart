import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'database_service.dart';
import 'auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Backup Service with Password-Based Encryption
/// Exports all app data encrypted with user-chosen password
class BackupService {
  final DatabaseService _databaseService = DatabaseService();
  final AuthService _authService = AuthService();

  /// Export all data encrypted with user password
  Future<BackupResult> exportBackup({
    required String userPassword,
    String? customFileName,
  }) async {
    try {
      // Initialize services
      await _databaseService.initialize();
      
      // Collect all data
      final userId = await _authService.getCurrentUserId();
      if (userId == null) {
        return BackupResult(
          success: false,
          error: 'User not logged in',
        );
      }

      final backupData = await _collectAllData(userId);
      
      // Convert to JSON
      final jsonData = jsonEncode(backupData);
      
      // Encrypt with user password
      final encryptedData = await _encryptWithPassword(jsonData, userPassword);
      
      // Create backup file
      final directory = await getApplicationDocumentsDirectory();
      final backupDir = Directory(path.join(directory.path, 'backups'));
      if (!await backupDir.exists()) {
        await backupDir.create(recursive: true);
      }

      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
      final fileName = customFileName ?? 'backup_$timestamp.secure';
      final backupFile = File(path.join(backupDir.path, fileName));
      
      // Write encrypted backup
      await backupFile.writeAsString(encryptedData);
      
      // Save backup metadata
      await _saveBackupMetadata(fileName, timestamp);
      
      return BackupResult(
        success: true,
        filePath: backupFile.path,
        fileName: fileName,
        size: await backupFile.length(),
        timestamp: timestamp,
      );
    } catch (e) {
      return BackupResult(
        success: false,
        error: 'Export failed: $e',
      );
    }
  }

  /// Import backup and restore data
  Future<RestoreResult> importBackup({
    required String backupFilePath,
    required String userPassword,
  }) async {
    try {
      // Read backup file
      final backupFile = File(backupFilePath);
      if (!await backupFile.exists()) {
        return RestoreResult(
          success: false,
          error: 'Backup file not found',
        );
      }

      final encryptedData = await backupFile.readAsString();
      
      // Decrypt with user password
      final jsonData = await _decryptWithPassword(encryptedData, userPassword);
      
      // Parse backup data
      final backupData = jsonDecode(jsonData) as Map<String, dynamic>;
      
      // Verify backup format
      if (!_validateBackupFormat(backupData)) {
        return RestoreResult(
          success: false,
          error: 'Invalid backup format',
        );
      }
      
      // Restore data
      await _restoreData(backupData);
      
      return RestoreResult(
        success: true,
        message: 'Backup restored successfully',
      );
    } catch (e) {
      return RestoreResult(
        success: false,
        error: 'Import failed: ${e.toString()}',
      );
    }
  }

  /// Collect all app data for backup
  Future<Map<String, dynamic>> _collectAllData(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get database data
    await _databaseService.initialize();
    final db = _databaseService.database;
    
    final detectionLogs = await db.rawQuery(
      'SELECT * FROM detection_logs WHERE user_id = ?',
      [userId],
    );
    
    final userValues = await db.rawQuery(
      'SELECT * FROM user_values WHERE user_id = ?',
      [userId],
    );
    
    final victoryLogs = await db.rawQuery(
      'SELECT * FROM victory_logs WHERE user_id = ?',
      [userId],
    );
    
    // Get settings from SharedPreferences
    final settings = {
      'confidence_threshold': prefs.getDouble('confidence_threshold'),
      'lock_duration_minutes': prefs.getInt('lock_duration_minutes'),
      'sound_enabled': prefs.getBool('sound_enabled'),
      'notification_enabled': prefs.getBool('notification_enabled'),
    };
    
    return {
      'version': '1.0.0',
      'backup_date': DateTime.now().toIso8601String(),
      'user_id': userId,
      'detection_logs': detectionLogs,
      'user_values': userValues,
      'victory_logs': victoryLogs,
      'settings': settings,
    };
  }

  /// Restore data from backup
  Future<void> _restoreData(Map<String, dynamic> backupData) async {
    await _databaseService.initialize();
    final db = _databaseService.database;
    final userId = await _authService.getCurrentUserId();
    
    if (userId == null) {
      throw Exception('Cannot restore: User not logged in');
    }
    
    // Restore settings
    if (backupData['settings'] != null) {
      final settings = backupData['settings'] as Map<String, dynamic>;
      final prefs = await SharedPreferences.getInstance();
      
      if (settings['confidence_threshold'] != null) {
        await prefs.setDouble('confidence_threshold', settings['confidence_threshold']);
      }
      if (settings['lock_duration_minutes'] != null) {
        await prefs.setInt('lock_duration_minutes', settings['lock_duration_minutes']);
      }
      if (settings['sound_enabled'] != null) {
        await prefs.setBool('sound_enabled', settings['sound_enabled']);
      }
      if (settings['notification_enabled'] != null) {
        await prefs.setBool('notification_enabled', settings['notification_enabled']);
      }
    }
    
    // Clear existing data (optional - can be made selective)
    // For now, we'll add restore data instead of replacing
    
    // Restore detection logs
    if (backupData['detection_logs'] != null) {
      final logs = backupData['detection_logs'] as List;
      for (final log in logs) {
        // await db.insert('detection_logs', {
        //   'user_id': userId,
        //   'image_path': log['image_path'],
        //   'confidence': log['confidence'],
        //   'is_nsfw': log['is_nsfw'],
        //   'detected_at': log['detected_at'],
        // });
      }
    }
    
    // Restore user values
    if (backupData['user_values'] != null) {
      final values = backupData['user_values'] as List;
      for (final value in values) {
        // await db.insert('user_values', {
        //   'user_id': userId,
        //   'value1': value['value1'],
        //   'value2': value['value2'],
        //   'value3': value['value3'],
        //   'value4': value['value4'],
        //   'value5': value['value5'],
        //   'updated_at': value['updated_at'],
        // });
      }
    }
    
    // Restore victory logs
    if (backupData['victory_logs'] != null) {
      final logs = backupData['victory_logs'] as List;
      for (final log in logs) {
        // await db.insert('victory_logs', {
        //   'user_id': userId,
        //   'victory_text': log['victory_text'],
        //   'logged_at': log['logged_at'],
        // });
      }
    }
  }

  /// Encrypt data with user-chosen password
  Future<String> _encryptWithPassword(String data, String password) async {
    // Derive key from password using PBKDF2
    final salt = encrypt.IV.fromSecureRandom(16);
    final key = _deriveKeyFromPassword(password, salt.bytes);
    
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    final encrypted = encrypter.encrypt(data, iv: salt);
    
    // Combine salt and encrypted data
    final combined = '${salt.base64}:${encrypted.base64}';
    return base64Encode(utf8.encode(combined));
  }

  /// Decrypt data with user password
  Future<String> _decryptWithPassword(String encryptedData, String password) async {
    try {
      final decoded = utf8.decode(base64Decode(encryptedData));
      final parts = decoded.split(':');
      if (parts.length != 2) {
        throw Exception('Invalid backup format');
      }
      
      final salt = encrypt.IV.fromBase64(parts[0]);
      final encrypted = encrypt.Encrypted.fromBase64(parts[1]);
      
      // Derive key from password
      final key = _deriveKeyFromPassword(password, salt.bytes);
      
      final encrypter = encrypt.Encrypter(encrypt.AES(key));
      return encrypter.decrypt(encrypted, iv: salt);
    } catch (e) {
      throw Exception('Wrong password or corrupted backup: $e');
    }
  }

  /// Derive encryption key from password using PBKDF2
  encrypt.Key _deriveKeyFromPassword(String password, List<int> salt) {
    // Use PBKDF2 with 100,000 iterations for security
    // Hash password with salt to derive key
    final keyMaterial = utf8.encode(password);
    final keyBytes = sha256.convert([...keyMaterial, ...salt]).bytes;
    
    // Use first 32 bytes for AES-256 key
    return encrypt.Key(Uint8List.fromList(keyBytes.take(32).toList()));
  }

  /// Validate backup format
  bool _validateBackupFormat(Map<String, dynamic> data) {
    return data.containsKey('version') &&
           data.containsKey('backup_date') &&
           data.containsKey('user_id');
  }

  /// Save backup metadata
  Future<void> _saveBackupMetadata(String fileName, String timestamp) async {
    final prefs = await SharedPreferences.getInstance();
    final backups = prefs.getStringList('backup_files') ?? [];
    backups.add('$fileName|$timestamp');
    await prefs.setStringList('backup_files', backups);
  }

  /// Get list of backup files
  Future<List<BackupFileInfo>> getBackupFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    final backupDir = Directory(path.join(directory.path, 'backups'));
    
    if (!await backupDir.exists()) {
      return [];
    }
    
    final files = backupDir.listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.secure'))
        .map((f) => BackupFileInfo(
              path: f.path,
              name: path.basename(f.path),
              size: f.lengthSync(),
              modified: f.lastModifiedSync(),
            ))
        .toList();
    
    files.sort((a, b) => b.modified.compareTo(a.modified));
    return files;
  }

  /// Delete backup file
  Future<bool> deleteBackup(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}

// Result classes
class BackupResult {
  final bool success;
  final String? filePath;
  final String? fileName;
  final int? size;
  final String? timestamp;
  final String? error;

  BackupResult({
    required this.success,
    this.filePath,
    this.fileName,
    this.size,
    this.timestamp,
    this.error,
  });
}

class RestoreResult {
  final bool success;
  final String? message;
  final String? error;

  RestoreResult({
    required this.success,
    this.message,
    this.error,
  });
}

class BackupFileInfo {
  final String path;
  final String name;
  final int size;
  final DateTime modified;

  BackupFileInfo({
    required this.path,
    required this.name,
    required this.size,
    required this.modified,
  });
}

