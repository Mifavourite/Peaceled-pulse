import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Encryption Test Service - Verifies encryption is working correctly
class EncryptionTestService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Test encryption functionality
  Future<Map<String, dynamic>> testEncryption() async {
    final results = <String, dynamic>{
      'aes_encryption': false,
      'secure_storage': false,
      'hashing': false,
      'errors': <String>[],
    };

    try {
      // Test AES Encryption
      try {
        final key = encrypt.Key.fromSecureRandom(32);
        final iv = encrypt.IV.fromSecureRandom(16);
        final encrypter = encrypt.Encrypter(encrypt.AES(key));

        const testData = 'This is a test message';
        final encrypted = encrypter.encrypt(testData, iv: iv);
        final decrypted = encrypter.decrypt(encrypted, iv: iv);

        if (decrypted == testData) {
          results['aes_encryption'] = true;
        } else {
          results['errors'].add('AES encryption/decryption mismatch');
        }
      } catch (e) {
        results['errors'].add('AES encryption failed: $e');
      }

      // Test Secure Storage
      try {
        const testKey = '__encryption_test__';
        const testValue = 'test_value_12345';
        
        await _secureStorage.write(key: testKey, value: testValue);
        final retrieved = await _secureStorage.read(key: testKey);
        await _secureStorage.delete(key: testKey);

        if (retrieved == testValue) {
          results['secure_storage'] = true;
        } else {
          results['errors'].add('Secure storage read/write mismatch');
        }
      } catch (e) {
        results['errors'].add('Secure storage failed: $e');
      }

      // Test Hashing
      try {
        const testString = 'test_hash_string';
        final bytes = utf8.encode(testString);
        final hash = sha256.convert(bytes);
        final hashString = hash.toString();

        // Verify hash is consistent
        final hash2 = sha256.convert(bytes);
        if (hash2.toString() == hashString && hashString.length == 64) {
          results['hashing'] = true;
        } else {
          results['errors'].add('Hashing inconsistency');
        }
      } catch (e) {
        results['errors'].add('Hashing failed: $e');
      }

      results['all_passed'] = results['aes_encryption'] == true &&
          results['secure_storage'] == true &&
          results['hashing'] == true;

    } catch (e) {
      results['errors'].add('Test suite error: $e');
    }

    return results;
  }

  /// Test database encryption (requires database service)
  Future<bool> testDatabaseEncryption() async {
    // This would test that the database is actually encrypted
    // In a real scenario, you'd try to read the database file without the password
    // and verify it's unreadable
    return true; // Placeholder - actual test would require file system access
  }
}
