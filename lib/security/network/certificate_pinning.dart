import 'dart:io';
import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// Certificate Pinning Service for network security
class CertificatePinningService {
  final Map<String, List<String>> _pinnedCertificates = {};
  final Dio _dio = Dio();

  /// Add certificate pin for a domain
  void addCertificatePin(String domain, List<String> publicKeyHashes) {
    _pinnedCertificates[domain] = publicKeyHashes;
  }

  /// Configure Dio with certificate pinning
  Dio getSecureDio() {
    _dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        client.badCertificateCallback = (X509Certificate cert, String host, int port) {
          return _verifyCertificate(cert, host);
        };
        return client;
      },
    );
    return _dio;
  }

  /// Verify certificate against pinned certificates
  bool _verifyCertificate(X509Certificate cert, String host) {
    final domain = _extractDomain(host);
    final pinnedHashes = _pinnedCertificates[domain];
    
    if (pinnedHashes == null || pinnedHashes.isEmpty) {
      // No pinning configured for this domain - allow (or deny based on policy)
      return true; // Change to false for strict mode
    }

    // Extract public key hash from certificate
    final certHash = _getCertificateHash(cert);
    
    // Check if certificate hash matches any pinned hash
    return pinnedHashes.contains(certHash);
  }

  /// Extract domain from host
  String _extractDomain(String host) {
    // Remove port if present
    if (host.contains(':')) {
      return host.split(':').first;
    }
    return host;
  }

  /// Get certificate public key hash (SHA-256)
  String _getCertificateHash(X509Certificate cert) {
    // In a real implementation, extract the public key from the certificate
    // and compute its SHA-256 hash
    final certBytes = cert.der;
    final hash = sha256.convert(certBytes);
    return base64Encode(hash.bytes);
  }

  /// Load certificate pins from configuration
  void loadPinsFromConfig(Map<String, dynamic> config) {
    config.forEach((domain, hashes) {
      if (hashes is List) {
        _pinnedCertificates[domain] = hashes.cast<String>();
      }
    });
  }

  /// Get all pinned domains
  List<String> getPinnedDomains() {
    return _pinnedCertificates.keys.toList();
  }

  /// Remove certificate pin for a domain
  void removeCertificatePin(String domain) {
    _pinnedCertificates.remove(domain);
  }

  /// Clear all certificate pins
  void clearAllPins() {
    _pinnedCertificates.clear();
  }
}
