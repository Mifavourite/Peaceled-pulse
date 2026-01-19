import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

/// End-to-End Encryption Service
class E2EEService {
  late encrypt.Encrypter _encrypter;
  encrypt.Key? _key;

  /// Initialize with key or generate new one
  void initialize({String? keyString}) {
    if (keyString != null) {
      _key = encrypt.Key.fromBase64(keyString);
    } else {
      _key = encrypt.Key.fromSecureRandom(32);
    }
    final iv = encrypt.IV.fromSecureRandom(16);
    _encrypter = encrypt.Encrypter(encrypt.AES(_key!));
  }

  /// Encrypt data
  String encryptData(String plaintext) {
    if (_key == null) {
      throw Exception('E2EE not initialized. Call initialize() first.');
    }

    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypted = _encrypter.encrypt(plaintext, iv: iv);
    
    // Combine IV and encrypted data
    final combined = '${iv.base64}:${encrypted.base64}';
    return base64Encode(utf8.encode(combined));
  }

  /// Decrypt data
  String decryptData(String ciphertext) {
    if (_key == null) {
      throw Exception('E2EE not initialized. Call initialize() first.');
    }

    try {
      final decoded = utf8.decode(base64Decode(ciphertext));
      final parts = decoded.split(':');
      if (parts.length != 2) {
        throw Exception('Invalid ciphertext format');
      }

      final iv = encrypt.IV.fromBase64(parts[0]);
      final encrypted = encrypt.Encrypted.fromBase64(parts[1]);
      
      return _encrypter.decrypt(encrypted, iv: iv);
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }

  /// Get current key (for key exchange)
  String? getKeyBase64() {
    return _key?.base64;
  }

  /// Derive key from password using PBKDF2
  String deriveKeyFromPassword(String password, String salt) {
    // Using HMAC-SHA256 for key derivation
    final hmac = Hmac(sha256, utf8.encode(salt));
    var derivedKey = utf8.encode(password);
    
    // Simple key derivation (in production, use proper PBKDF2)
    for (int i = 0; i < 100000; i++) {
      derivedKey = hmac.convert(derivedKey).bytes;
    }
    
    return base64Encode(derivedKey.take(32).toList());
  }

  /// Generate secure random salt
  String generateSalt({int length = 32}) {
    final random = Random.secure();
    final bytes = List<int>.generate(length, (_) => random.nextInt(256));
    return base64Encode(bytes);
  }

  /// Encrypt file (for large data)
  Future<String> encryptFile(List<int> fileBytes) async {
    if (_key == null) {
      throw Exception('E2EE not initialized. Call initialize() first.');
    }

    final plaintext = utf8.decode(fileBytes);
    return encryptData(plaintext);
  }

  /// Decrypt file
  Future<List<int>> decryptFile(String encryptedData) async {
    if (_key == null) {
      throw Exception('E2EE not initialized. Call initialize() first.');
    }

    final decrypted = decryptData(encryptedData);
    return utf8.encode(decrypted);
  }
}
