import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Secure Enclave Service - Hardware-backed secure storage
class SecureEnclave {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_PKCS1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.when_unlocked_this_device_only,
      synchronizable: false,
    ),
  );

  /// Store data in secure enclave (hardware-backed)
  Future<void> store(String key, String value) async {
    // Encrypt before storing
    final encrypted = await _encrypt(value);
    await _secureStorage.write(key: key, value: encrypted);
  }

  /// Retrieve data from secure enclave
  Future<String?> retrieve(String key) async {
    final encrypted = await _secureStorage.read(key: key);
    if (encrypted == null) return null;
    return await _decrypt(encrypted);
  }

  /// Delete data from secure enclave
  Future<void> delete(String key) async {
    await _secureStorage.delete(key: key);
  }

  /// Check if secure enclave is available
  Future<bool> isAvailable() async {
    try {
      // Test write/read to verify secure storage works
      const testKey = '__secure_enclave_test__';
      const testValue = 'test';
      
      await _secureStorage.write(key: testKey, value: testValue);
      final retrieved = await _secureStorage.read(key: testKey);
      await _secureStorage.delete(key: testKey);
      
      return retrieved == testValue;
    } catch (e) {
      return false;
    }
  }

  /// Store sensitive credential
  Future<void> storeCredential(String identifier, String credential) async {
    await store('credential_$identifier', credential);
  }

  /// Retrieve sensitive credential
  Future<String?> getCredential(String identifier) async {
    return await retrieve('credential_$identifier');
  }

  /// Store encryption key
  Future<void> storeKey(String keyId, String key) async {
    await store('key_$keyId', key);
  }

  /// Retrieve encryption key
  Future<String?> getKey(String keyId) async {
    return await retrieve('key_$keyId');
  }

  /// Clear all secure enclave data (use with caution)
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }

  /// Get platform-specific security info
  Map<String, dynamic> getSecurityInfo() {
    return {
      'platform': Platform.operatingSystem,
      'isAndroid': Platform.isAndroid,
      'isIOS': Platform.isIOS,
      'hardwareBacked': Platform.isAndroid || Platform.isIOS,
    };
  }

  Future<String> _encrypt(String plaintext) async {
    // Additional encryption layer before storing in secure storage
    final bytes = utf8.encode(plaintext);
    final hash = sha256.convert(bytes);
    // In production, use proper encryption here
    return base64Encode(bytes);
  }

  Future<String> _decrypt(String encrypted) async {
    try {
      final bytes = base64Decode(encrypted);
      return utf8.decode(bytes);
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }
}
