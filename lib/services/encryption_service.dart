import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Encryption Service for local data encryption
class EncryptionService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  encrypt.Encrypter? _encrypter;
  encrypt.Key? _key;

  /// Initialize encryption service
  Future<void> initialize() async {
    // Try to get existing key from secure storage
    final keyString = await _secureStorage.read(key: 'encryption_key');
    
    if (keyString != null) {
      _key = encrypt.Key.fromBase64(keyString);
    } else {
      // Generate new key
      _key = encrypt.Key.fromSecureRandom(32);
      await _secureStorage.write(key: 'encryption_key', value: _key!.base64);
    }
    
    _encrypter = encrypt.Encrypter(encrypt.AES(_key!));
  }

  /// Encrypt string data
  String encryptString(String plaintext) {
    if (_encrypter == null || _key == null) {
      throw Exception('Encryption service not initialized');
    }

    final iv = encrypt.IV.fromSecureRandom(16);
    final encrypted = _encrypter!.encrypt(plaintext, iv: iv);
    
    // Combine IV and encrypted data
    final combined = '${iv.base64}:${encrypted.base64}';
    return base64Encode(utf8.encode(combined));
  }

  /// Decrypt string data
  String decryptString(String ciphertext) {
    if (_encrypter == null || _key == null) {
      throw Exception('Encryption service not initialized');
    }

    try {
      final decoded = utf8.decode(base64Decode(ciphertext));
      final parts = decoded.split(':');
      if (parts.length != 2) {
        throw Exception('Invalid ciphertext format');
      }

      final iv = encrypt.IV.fromBase64(parts[0]);
      final encrypted = encrypt.Encrypted.fromBase64(parts[1]);
      
      return _encrypter!.decrypt(encrypted, iv: iv);
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }

  /// Hash data (one-way)
  String hashData(String data) {
    final bytes = utf8.encode(data);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }
}
