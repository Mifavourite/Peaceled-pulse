import 'package:dio/dio.dart';

/// Security Utilities for HTTPS and security headers
class SecurityUtils {
  /// Create Dio client with HTTPS and security headers
  static Dio createSecureDio() {
    final dio = Dio();

    // Set default security headers
    dio.options.headers = {
      'Content-Type': 'application/json',
      'X-Content-Type-Options': 'nosniff',
      'X-Frame-Options': 'DENY',
      'X-XSS-Protection': '1; mode=block',
      'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
      'Content-Security-Policy': "default-src 'self'",
    };

    // Enforce HTTPS
    dio.options.baseUrl = 'https://'; // Ensure HTTPS
    dio.options.validateStatus = (status) => status! < 500;

    // Add interceptors for additional security
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        // Ensure all requests use HTTPS
        if (options.uri.scheme != 'https') {
          return handler.reject(
            DioException(
              requestOptions: options,
              error: 'HTTPS required for all network calls',
            ),
          );
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        // Log security-related errors
        if (error.response?.statusCode == 403 || error.response?.statusCode == 401) {
          // Handle authentication errors
        }
        return handler.next(error);
      },
    ));

    return dio;
  }

  /// Validate URL is HTTPS
  static bool isValidHttpsUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.scheme == 'https';
    } catch (e) {
      return false;
    }
  }
}
