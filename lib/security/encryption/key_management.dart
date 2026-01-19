import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

/// Key Management Service for secure key storage and rotation
class KeyManagementService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _keyVersionPrefix = 'key_version_';
  static const String _currentVersionKey = 'current_key_version';

  /// Generate and store a new encryption key
  Future<String> generateNewKey({int? version}) async {
    final keyVersion = version ?? await _getNextVersion();
    final key = encrypt.Key.fromSecureRandom(32);
    final keyString = key.base64;

    await _secureStorage.write(
      key: '$_keyVersionPrefix$keyVersion',
      value: keyString,
    );

    await _secureStorage.write(
      key: _currentVersionKey,
      value: keyVersion.toString(),
    );

    return keyString;
  }

  /// Get current encryption key
  Future<encrypt.Key?> getCurrentKey() async {
    final versionStr = await _secureStorage.read(key: _currentVersionKey);
    if (versionStr == null) return null;

    final version = int.parse(versionStr);
    return await getKeyByVersion(version);
  }

  /// Get key by version
  Future<encrypt.Key?> getKeyByVersion(int version) async {
    final keyString = await _secureStorage.read(
      key: '$_keyVersionPrefix$version',
    );
    if (keyString == null) return null;
    return encrypt.Key.fromBase64(keyString);
  }

  /// Rotate encryption key (create new version, keep old for decryption)
  Future<int> rotateKey() async {
    final currentVersion = await getCurrentVersion();
    final newVersion = currentVersion + 1;
    await generateNewKey(version: newVersion);
    return newVersion;
  }

  /// Get current key version
  Future<int> getCurrentVersion() async {
    final versionStr = await _secureStorage.read(key: _currentVersionKey);
    if (versionStr == null) {
      // Initialize with version 1
      await generateNewKey(version: 1);
      return 1;
    }
    return int.parse(versionStr);
  }

  /// Delete old key versions (after migration)
  Future<void> deleteOldVersions({int keepLastN = 2}) async {
    final currentVersion = await getCurrentVersion();
    for (int i = 1; i <= currentVersion - keepLastN; i++) {
      await _secureStorage.delete(key: '$_keyVersionPrefix$i');
    }
  }

  /// Export key (for backup - should be encrypted)
  Future<Map<String, dynamic>> exportKey(int version) async {
    final key = await getKeyByVersion(version);
    if (key == null) {
      throw Exception('Key version not found');
    }

    // In production, this should be encrypted with a master key
    return {
      'version': version,
      'key': key.base64,
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Import key (from backup)
  Future<void> importKey(Map<String, dynamic> keyData) async {
    final version = keyData['version'] as int;
    final keyString = keyData['key'] as String;

    await _secureStorage.write(
      key: '$_keyVersionPrefix$version',
      value: keyString,
    );
  }

  /// Derive key from master password
  Future<String> deriveKeyFromMaster(String masterPassword, String salt) async {
    // Using HMAC-SHA512 for key derivation
    final hmac = Hmac(sha512, utf8.encode(salt));
    var derivedKey = utf8.encode(masterPassword);
    
    // Simple key derivation (in production, use proper PBKDF2)
    for (int i = 0; i < 200000; i++) {
      derivedKey = hmac.convert(derivedKey).bytes;
    }

    return base64Encode(derivedKey.take(32).toList());
  }

  Future<int> _getNextVersion() async {
    final currentVersion = await getCurrentVersion();
    return currentVersion + 1;
  }
}
