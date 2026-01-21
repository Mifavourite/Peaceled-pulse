import 'package:bcrypt/bcrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../services/database_service.dart';

/// Authentication Service with bcrypt password hashing (SHA-256 on web)
class AuthService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final DatabaseService _databaseService = DatabaseService();
  
  static const String _sessionKey = 'user_session';
  static const String _userIdKey = 'user_id';

  /// Initialize database
  Future<void> initialize() async {
    await _databaseService.initialize();
  }

  /// Hash password (uses SHA-256 on web, bcrypt on native)
  String _hashPassword(String password) {
    if (kIsWeb) {
      // Use SHA-256 for web (bcrypt doesn't work on web)
      final bytes = utf8.encode(password);
      final digest = sha256.convert(bytes);
      return digest.toString();
    } else {
      // Use bcrypt for native platforms
      final salt = BCrypt.gensalt();
      return BCrypt.hashpw(password, salt);
    }
  }

  /// Verify password (uses SHA-256 on web, bcrypt on native)
  bool _verifyPassword(String password, String hashedPassword) {
    if (kIsWeb) {
      // Use SHA-256 for web
      final bytes = utf8.encode(password);
      final digest = sha256.convert(bytes);
      return digest.toString() == hashedPassword;
    } else {
      // Use bcrypt for native platforms
      return BCrypt.checkpw(password, hashedPassword);
    }
  }

  /// Register a new user with password hashing
  Future<bool> register(String username, String password) async {
    try {
      print('Attempting to register user: $username');
      
      // Hash password
      final hashedPassword = _hashPassword(password);
      print('Password hashed successfully');

      // Store user in encrypted database
      final userId = await _databaseService.createUser(username, hashedPassword);
      print('User ID returned: $userId');
      
      if (userId != null) {
        return true;
      }
      return false;
    } catch (e) {
      print('Error in register: $e');
      return false;
    }
  }

  /// Login user with password verification
  Future<bool> login(String username, String password) async {
    try {
      print('Attempting to login user: $username');
      // Get user from encrypted database
      final user = await _databaseService.getUserByUsername(username);
      print('User retrieved: ${user != null}');
      
      if (user == null) {
        print('User not found');
        return false;
      }

      // Verify password
      print('Verifying password');
      final isValid = _verifyPassword(password, user['password'] as String);
      print('Password valid: $isValid');
      
      if (isValid) {
        // Store session
        await _secureStorage.write(key: _sessionKey, value: 'authenticated');
        await _secureStorage.write(key: _userIdKey, value: user['id'].toString());
        print('Login successful, session stored');
        return true;
      }
      
      return false;
    } catch (e) {
      print('Error in login: $e');
      return false;
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final session = await _secureStorage.read(key: _sessionKey);
    return session == 'authenticated';
  }

  /// Get current user ID
  Future<int?> getCurrentUserId() async {
    final userIdStr = await _secureStorage.read(key: _userIdKey);
    if (userIdStr == null) return null;
    return int.tryParse(userIdStr);
  }

  /// Logout user
  Future<void> logout() async {
    await _secureStorage.delete(key: _sessionKey);
    await _secureStorage.delete(key: _userIdKey);
  }

  /// Change password
  Future<bool> changePassword(String username, String oldPassword, String newPassword) async {
    try {
      // Verify old password
      final isValid = await login(username, oldPassword);
      if (!isValid) {
        return false;
      }

      // Hash new password
      final hashedPassword = _hashPassword(newPassword);

      // Update in database
      return await _databaseService.updateUserPassword(username, hashedPassword);
    } catch (e) {
      return false;
    }
  }
}
