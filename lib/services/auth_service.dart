import 'package:bcrypt/bcrypt.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/database_service.dart';

/// Authentication Service with bcrypt password hashing
class AuthService {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final DatabaseService _databaseService = DatabaseService();
  
  static const String _sessionKey = 'user_session';
  static const String _userIdKey = 'user_id';

  /// Initialize database
  Future<void> initialize() async {
    await _databaseService.initialize();
  }

  /// Register a new user with bcrypt password hashing
  Future<bool> register(String username, String password) async {
    try {
      // Hash password with bcrypt (cost factor 12 for good security)
      final salt = BCrypt.gensalt();
      final hashedPassword = BCrypt.hashpw(password, salt);

      // Store user in encrypted database
      final userId = await _databaseService.createUser(username, hashedPassword);
      
      if (userId != null) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Login user with password verification
  Future<bool> login(String username, String password) async {
    try {
      // Get user from encrypted database
      final user = await _databaseService.getUserByUsername(username);
      
      if (user == null) {
        return false;
      }

      // Verify password with bcrypt
      final isValid = BCrypt.checkpw(password, user['password'] as String);
      
      if (isValid) {
        // Store session
        await _secureStorage.write(key: _sessionKey, value: 'authenticated');
        await _secureStorage.write(key: _userIdKey, value: user['id'].toString());
        return true;
      }
      
      return false;
    } catch (e) {
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
      final salt = BCrypt.gensalt();
      final hashedPassword = BCrypt.hashpw(newPassword, salt);

      // Update in database
      return await _databaseService.updateUserPassword(username, hashedPassword);
    } catch (e) {
      return false;
    }
  }
}
