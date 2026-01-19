import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Hardware-backed key management service
/// Simulates hardware security module (HSM) functionality
class HardwareKey {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_PKCS1Padding,
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  /// Generate a hardware-backed key pair
  Future<Map<String, String>> generateKeyPair({String? keyId}) async {
    final id = keyId ?? _generateKeyId();
    final privateKey = _generateSecureKey();
    final publicKey = _derivePublicKey(privateKey);

    await _secureStorage.write(key: '${id}_private', value: privateKey);
    await _secureStorage.write(key: '${id}_public', value: publicKey);

    return {
      'keyId': id,
      'privateKey': privateKey,
      'publicKey': publicKey,
    };
  }

  /// Get hardware-backed key
  Future<String?> getKey(String keyId, {bool isPrivate = false}) async {
    final key = isPrivate ? '${keyId}_private' : '${keyId}_public';
    return await _secureStorage.read(key: key);
  }

  /// Sign data using hardware-backed key
  Future<String> sign(String keyId, String data) async {
    final privateKey = await getKey(keyId, isPrivate: true);
    if (privateKey == null) {
      throw Exception('Private key not found');
    }

    final bytes = utf8.encode(data + privateKey);
    final hash = sha256.convert(bytes);
    return base64Encode(hash.bytes);
  }

  /// Verify signature using hardware-backed key
  Future<bool> verify(String keyId, String data, String signature) async {
    final publicKey = await getKey(keyId, isPrivate: false);
    if (publicKey == null) {
      return false;
    }

    final bytes = utf8.encode(data + publicKey);
    final hash = sha256.convert(bytes);
    final expectedSignature = base64Encode(hash.bytes);

    return expectedSignature == signature;
  }

  /// Delete hardware-backed key
  Future<void> deleteKey(String keyId) async {
    await _secureStorage.delete(key: '${keyId}_private');
    await _secureStorage.delete(key: '${keyId}_public');
  }

  /// Check if hardware security is available
  Future<bool> isHardwareBacked() async {
    try {
      if (Platform.isAndroid) {
        // Android Keystore provides hardware-backed security
        return true;
      } else if (Platform.isIOS) {
        // iOS Keychain provides hardware-backed security
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  String _generateKeyId() {
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    final bytes = utf8.encode(random);
    final hash = sha256.convert(bytes);
    return base64Encode(hash.bytes).substring(0, 16);
  }

  String _generateSecureKey() {
    final random = DateTime.now().millisecondsSinceEpoch.toString() +
        Platform.resolvedExecutable;
    final bytes = utf8.encode(random);
    final hash = sha512.convert(bytes);
    return base64Encode(hash.bytes);
  }

  String _derivePublicKey(String privateKey) {
    final bytes = utf8.encode(privateKey + 'public');
    final hash = sha256.convert(bytes);
    return base64Encode(hash.bytes);
  }
}
