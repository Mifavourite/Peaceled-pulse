import 'dart:math';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Multi-Factor Authentication Service
class MFAService {
  /// Generate TOTP (Time-based One-Time Password)
  String generateTOTP(String secret, {int timeStep = 30}) {
    final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final timeCounter = currentTime ~/ timeStep;
    return _generateOTP(secret, timeCounter);
  }

  /// Verify TOTP
  bool verifyTOTP(String secret, String code, {int timeStep = 30}) {
    final currentTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final timeCounter = currentTime ~/ timeStep;

    // Check current, previous, and next time windows for clock skew tolerance
    for (int i = -1; i <= 1; i++) {
      final expectedCode = _generateOTP(secret, timeCounter + i);
      if (expectedCode == code) {
        return true;
      }
    }
    return false;
  }

  /// Generate HOTP (HMAC-based One-Time Password)
  String generateHOTP(String secret, int counter) {
    return _generateOTP(secret, counter);
  }

  /// Generate recovery codes
  List<String> generateRecoveryCodes({int count = 10}) {
    final random = Random.secure();
    final codes = <String>[];
    for (int i = 0; i < count; i++) {
      final code = List.generate(8, (_) => random.nextInt(10)).join();
      codes.add('${code.substring(0, 4)}-${code.substring(4)}');
    }
    return codes;
  }

  /// Generate secure secret for TOTP/HOTP
  String generateSecret({int length = 32}) {
    final random = Random.secure();
    final bytes = List<int>.generate(length, (_) => random.nextInt(256));
    return base32Encode(bytes);
  }

  String _generateOTP(String secret, int counter) {
    final key = base32Decode(secret);
    final counterBytes = _intToBytes(counter);
    final hmac = Hmac(sha1, key);
    final digest = hmac.convert(counterBytes).bytes;

    final offset = digest[digest.length - 1] & 0x0F;
    final binary = ((digest[offset] & 0x7F) << 24) |
        ((digest[offset + 1] & 0xFF) << 16) |
        ((digest[offset + 2] & 0xFF) << 8) |
        (digest[offset + 3] & 0xFF);

    final otp = binary % 1000000;
    return otp.toString().padLeft(6, '0');
  }

  List<int> _intToBytes(int value) {
    final bytes = <int>[];
    for (int i = 7; i >= 0; i--) {
      bytes.add((value >> (i * 8)) & 0xFF);
    }
    return bytes;
  }

  List<int> base32Decode(String input) {
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    input = input.toUpperCase();
    final bytes = <int>[];
    int buffer = 0;
    int bitsLeft = 0;

    for (int i = 0; i < input.length; i++) {
      final char = input[i];
      if (char == '=') break;
      final value = alphabet.indexOf(char);
      if (value == -1) continue;

      buffer = (buffer << 5) | value;
      bitsLeft += 5;

      if (bitsLeft >= 8) {
        bytes.add((buffer >> (bitsLeft - 8)) & 0xFF);
        bitsLeft -= 8;
      }
    }
    return bytes;
  }

  String base32Encode(List<int> bytes) {
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    final buffer = StringBuffer();
    int bits = 0;
    int value = 0;

    for (int byte in bytes) {
      value = (value << 8) | byte;
      bits += 8;

      while (bits >= 5) {
        buffer.write(alphabet[(value >> (bits - 5)) & 0x1F]);
        bits -= 5;
      }
    }

    if (bits > 0) {
      buffer.write(alphabet[(value << (5 - bits)) & 0x1F]);
    }

    return buffer.toString();
  }
}
