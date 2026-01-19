import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

/// VPN Detection Service
class VPNDetectionService {
  final Connectivity _connectivity = Connectivity();

  /// Check if VPN is active
  Future<bool> isVPNActive() async {
    try {
      if (Platform.isAndroid) {
        return await _checkAndroidVPN();
      } else if (Platform.isIOS) {
        return await _checkIOSVPN();
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Get network connection type
  Future<String> getConnectionType() async {
    final result = await _connectivity.checkConnectivity();
    return result.toString();
  }

  /// Check for suspicious network conditions
  Future<Map<String, dynamic>> checkNetworkSecurity() async {
    final isVPN = await isVPNActive();
    final connectionType = await getConnectionType();
    
    return {
      'vpnActive': isVPN,
      'connectionType': connectionType,
      'isSecure': !isVPN && connectionType.contains('wifi'),
      'warnings': _generateWarnings(isVPN, connectionType),
    };
  }

  List<String> _generateWarnings(bool isVPN, String connectionType) {
    final warnings = <String>[];
    
    if (isVPN) {
      warnings.add('VPN detected - connection may be routed through third party');
    }
    
    if (connectionType.contains('mobile')) {
      warnings.add('Mobile data connection - may be less secure than WiFi');
    }
    
    return warnings;
  }

  Future<bool> _checkAndroidVPN() async {
    // On Android, check for VPN interfaces
    // This is a simplified check - in production, use platform channels
    try {
      final result = await Process.run('ip', ['addr', 'show']);
      final output = result.stdout.toString();
      // Check for common VPN interface names
      return output.contains('tun') || 
             output.contains('ppp') || 
             output.contains('wg');
    } catch (e) {
      return false;
    }
  }

  Future<bool> _checkIOSVPN() async {
    // On iOS, VPN detection is more restricted
    // This would typically require platform channels
    // For now, return false as iOS doesn't easily expose VPN status
    return false;
  }
}
