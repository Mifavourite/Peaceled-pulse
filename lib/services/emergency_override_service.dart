import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Emergency Override Service with Delay
/// Provides emergency bypass with configurable delay for security
class EmergencyOverrideService {
  static const int _defaultDelaySeconds = 10;
  static const String _overrideDelayKey = 'emergency_override_delay';
  static const String _overrideEnabledKey = 'emergency_override_enabled';

  /// Get override delay in seconds
  Future<int> getOverrideDelay() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_overrideDelayKey) ?? _defaultDelaySeconds;
  }

  /// Set override delay
  Future<void> setOverrideDelay(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_overrideDelayKey, seconds);
  }

  /// Check if override is enabled
  Future<bool> isOverrideEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_overrideEnabledKey) ?? true;
  }

  /// Enable/disable override
  Future<void> setOverrideEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_overrideEnabledKey, enabled);
  }

  /// Request emergency override with delay
  /// Returns true if override should be granted, false if cancelled
  Future<bool> requestOverride(BuildContext context) async {
    final enabled = await isOverrideEnabled();
    if (!enabled) {
      _showOverrideDisabledDialog(context);
      return false;
    }

    final delay = await getOverrideDelay();
    
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _EmergencyOverrideDialog(
        delaySeconds: delay,
      ),
    ) ?? false;
  }

  void _showOverrideDisabledDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Override Disabled'),
        content: const Text(
          'Emergency override is currently disabled. Please enable it in settings if you need this feature.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// Emergency Override Dialog with Countdown
class _EmergencyOverrideDialog extends StatefulWidget {
  final int delaySeconds;

  const _EmergencyOverrideDialog({
    required this.delaySeconds,
  });

  @override
  State<_EmergencyOverrideDialog> createState() => _EmergencyOverrideDialogState();
}

class _EmergencyOverrideDialogState extends State<_EmergencyOverrideDialog> {
  int _remainingSeconds = 0;
  Timer? _countdownTimer;
  bool _canOverride = false;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.delaySeconds;
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
          HapticFeedback.selectionClick();
        } else {
          _canOverride = true;
          timer.cancel();
          HapticFeedback.mediumImpact();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.orange),
          SizedBox(width: 8),
          Text('Emergency Override'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _canOverride
                ? 'Override is now available'
                : 'Please wait ${_remainingSeconds} second${_remainingSeconds != 1 ? 's' : ''}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _canOverride ? Colors.green.shade700 : Colors.orange.shade700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          if (!_canOverride) ...[
            CircularProgressIndicator(
              value: (widget.delaySeconds - _remainingSeconds) / widget.delaySeconds,
              strokeWidth: 4,
            ),
            const SizedBox(height: 16),
            const Text(
              'This delay helps ensure thoughtful use of the override feature.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _canOverride
              ? () {
                  HapticFeedback.mediumImpact();
                  Navigator.of(context).pop(true);
                }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange.shade700,
            foregroundColor: Colors.white,
          ),
          child: const Text('Override'),
        ),
      ],
    );
  }
}
