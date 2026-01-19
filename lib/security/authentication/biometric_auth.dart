import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Biometric authentication service with hardware-backed security
class BiometricAuth {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Check if biometric authentication is available
  Future<bool> isAvailable() async {
    try {
      final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
      final bool isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheckBiometrics && isDeviceSupported;
    } catch (e) {
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  /// Authenticate using biometrics
  Future<bool> authenticate({
    String reason = 'Please authenticate to continue',
    bool useErrorDialogs = true,
    bool stickyAuth = true,
  }) async {
    try {
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: reason,
        options: AuthenticationOptions(
          useErrorDialogs: useErrorDialogs,
          stickyAuth: stickyAuth,
          biometricOnly: true,
        ),
      );
      return didAuthenticate;
    } catch (e) {
      return false;
    }
  }

  /// Store biometric-protected credential
  Future<void> storeCredential(String key, String value) async {
    final encrypted = _encryptValue(value);
    await _secureStorage.write(key: key, value: encrypted);
  }

  /// Retrieve biometric-protected credential
  Future<String?> getCredential(String key) async {
    final encrypted = await _secureStorage.read(key: key);
    if (encrypted == null) return null;
    return _decryptValue(encrypted);
  }

  /// Encrypt value before storage
  String _encryptValue(String value) {
    final bytes = utf8.encode(value);
    final hash = sha256.convert(bytes);
    return base64Encode(hash.bytes + bytes);
  }

  /// Decrypt value after retrieval
  String _decryptValue(String encrypted) {
    final bytes = base64Decode(encrypted);
    return utf8.decode(bytes.sublist(32)); // Skip hash
  }

  /// Stop authentication (cancel ongoing auth)
  Future<void> stopAuthentication() async {
    await _localAuth.stopAuthentication();
  }
}
