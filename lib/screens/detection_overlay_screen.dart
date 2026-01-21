import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';
import '../services/emergency_override_service.dart';

/// Enhanced Red Overlay Screen with scripture images, shofar sound, and lock timer
/// Optimized for mobile: responsive design, battery efficient, memory managed
class DetectionOverlayScreen extends StatefulWidget {
  final double confidence;
  final VoidCallback onRecovery;
  final int lockDurationMinutes; // 1-5 minutes

  const DetectionOverlayScreen({
    super.key,
    required this.confidence,
    required this.onRecovery,
    this.lockDurationMinutes = 3,
  });

  @override
  State<DetectionOverlayScreen> createState() => _DetectionOverlayScreenState();
}

class _DetectionOverlayScreenState extends State<DetectionOverlayScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late AudioPlayer _audioPlayer;
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  Timer? _lockTimer;
  Timer? _imageRotationTimer;
  Duration _remainingTime = Duration.zero;
  int _currentImageIndex = 0;
  bool _isLocked = true;
  bool _isPlayingSound = false;
  bool _isPaused = false;
  final EmergencyOverrideService _overrideService = EmergencyOverrideService();

  // 15 scripture images (local assets) - cached
  static final List<String> _scriptureImagePaths = List.generate(
    15,
    (index) => 'assets/images/scriptures/scripture_${index + 1}.png',
  );
  
  // Cache for image existence checks to reduce repeated lookups
  final Map<String, bool> _imageCache = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _audioPlayer = AudioPlayer();
    _remainingTime = Duration(minutes: widget.lockDurationMinutes);

    // Animation controllers with optimized durations
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000), // Reduced from 1500ms
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500), // Slower pulse for battery
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _playShofarSound();
    _startLockTimer();
    _startImageRotation();
    
    // Only start pulse if app is in foreground
    if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Pause/resume animations and timers based on app state for battery optimization
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _pauseAnimations();
      _isPaused = true;
    } else if (state == AppLifecycleState.resumed) {
      _resumeAnimations();
      _isPaused = false;
    }
  }

  void _pauseAnimations() {
    _pulseController.stop();
    _imageRotationTimer?.cancel();
    // Don't pause lock timer - it should continue in background
  }

  void _resumeAnimations() {
    _pulseController.repeat(reverse: true);
    _startImageRotation();
  }

  Future<void> _playShofarSound() async {
    try {
      if (mounted) {
        setState(() => _isPlayingSound = true);
      }
      // Play shofar sound (local audio file)
      await _audioPlayer.play(AssetSource('audio/shofar.mp3'));
      
      // Wait for sound to complete
      await _audioPlayer.onPlayerComplete.first.timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          // Timeout after 10 seconds to prevent hanging
          debugPrint('Audio playback timeout');
        },
      );
      
      if (mounted) {
        setState(() => _isPlayingSound = false);
      }
    } catch (e) {
      // Handle missing audio file gracefully
      debugPrint('Audio file not found: $e');
      if (mounted) {
        setState(() => _isPlayingSound = false);
      }
    }
  }

  void _startLockTimer() {
    _lockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        if (_remainingTime.inSeconds > 0) {
          _remainingTime = Duration(seconds: _remainingTime.inSeconds - 1);
        } else {
          _isLocked = false;
          timer.cancel();
          HapticFeedback.mediumImpact();
        }
      });
    });
  }

  void _startImageRotation() {
    _imageRotationTimer?.cancel(); // Cancel existing timer
    _imageRotationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted || _isPaused) {
        timer.cancel();
        return;
      }

      if (mounted) {
        setState(() {
          _currentImageIndex = (_currentImageIndex + 1) % _scriptureImagePaths.length;
        });
      }
    });
  }

  void _handleRecovery() {
    if (!_isLocked) {
      _lockTimer?.cancel();
      _imageRotationTimer?.cancel();
      _audioPlayer.stop();
      _audioPlayer.dispose();
      _fadeController.dispose();
      _pulseController.dispose();
      widget.onRecovery();
    }
  }

  String _formatTime(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _lockTimer?.cancel();
    _imageRotationTimer?.cancel();
    _audioPlayer.dispose();
    _fadeController.dispose();
    _pulseController.dispose();
    _imageCache.clear(); // Clear cache on dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent back button during lock
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Scaffold(
          backgroundColor: Colors.red.shade900,
          body: SafeArea(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.red.shade900,
                    Colors.red.shade800,
                    Colors.red.shade900,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
              child: Stack(
                children: [
                  // Animated pulsing background
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.center,
                            radius: 1.5 * _pulseAnimation.value,
                            colors: [
                              Colors.red.shade900.withOpacity(0.3),
                              Colors.red.shade900.withOpacity(0.0),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  // Main content
                  Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Responsive sizing based on screen size
                        final screenHeight = constraints.maxHeight;
                        final screenWidth = constraints.maxWidth;
                        final isSmallScreen = screenHeight < 600 || screenWidth < 360;
                        final iconSize = isSmallScreen ? 60.0 : 80.0;
                        final titleFontSize = isSmallScreen ? 22.0 : 28.0;
                        final padding = isSmallScreen ? 16.0 : 24.0;
                        final spacing = isSmallScreen ? 16.0 : 32.0;

                        return SingleChildScrollView(
                          padding: EdgeInsets.all(padding),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Warning icon with pulse
                              AnimatedBuilder(
                                animation: _pulseAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _pulseAnimation.value,
                                    child: Container(
                                      padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.white.withOpacity(0.2),
                                        border: Border.all(
                                          color: Colors.white,
                                          width: isSmallScreen ? 3 : 4,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.warning_rounded,
                                        size: iconSize,
                                        color: Colors.white,
                                      ),
                                    ),
                                  );
                                },
                              ),

                              SizedBox(height: spacing),

                              // Warning message - responsive
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  '⚠️ Inappropriate Content Detected',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: titleFontSize,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        blurRadius: 10,
                                        color: Colors.black.withOpacity(0.5),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              SizedBox(height: spacing / 2),

                              Text(
                                'Confidence: ${(widget.confidence * 100).toStringAsFixed(1)}%',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 16 : 20,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withOpacity(0.9),
                                ),
                              ),

                              SizedBox(height: isSmallScreen ? 24 : 48),

                              // Lock timer display - responsive
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isSmallScreen ? 24 : 32,
                                  vertical: isSmallScreen ? 12 : 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.5),
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      _isLocked ? 'Lock Duration' : '✓ Recovery Ready',
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 14 : 18,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(height: isSmallScreen ? 6 : 8),
                                    Text(
                                      _formatTime(_remainingTime),
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 28 : 36,
                                        fontWeight: FontWeight.bold,
                                        color: _isLocked
                                            ? Colors.orange.shade300
                                            : Colors.green.shade300,
                                        fontFeatures: const [
                                          FontFeature.tabularFigures(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(height: isSmallScreen ? 24 : 48),

                              // Scripture image carousel - responsive height
                              Container(
                                height: isSmallScreen ? 200 : 300,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(14),
                                  child: _buildScriptureImage(),
                                ),
                              ),

                              SizedBox(height: isSmallScreen ? 24 : 32),

                              // Recovery button - touch-friendly (min 48dp)
                              AnimatedOpacity(
                                opacity: _isLocked ? 0.5 : 1.0,
                                duration: const Duration(milliseconds: 300),
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: _isLocked ? null : _handleRecovery,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.red.shade900,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isSmallScreen ? 32 : 48,
                                        vertical: 18, // Min 48dp touch target
                                      ),
                                      minimumSize: const Size(double.infinity, 56), // 56dp for better touch
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: _isLocked ? 0 : 8,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(_isLocked ? Icons.lock : Icons.check_circle),
                                        const SizedBox(width: 8),
                                        Text(
                                          _isLocked
                                              ? 'Please wait...'
                                              : 'Continue Recovery',
                                          style: TextStyle(
                                            fontSize: isSmallScreen ? 16 : 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              if (_isLocked) ...[
                                SizedBox(height: spacing / 2),
                                Text(
                                  'Take this time to reflect and reset',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: isSmallScreen ? 12 : 14,
                                    color: Colors.white.withOpacity(0.7),
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                                
                                SizedBox(height: 16),
                                
                                // Emergency Override Button
                                SizedBox(
                                  width: double.infinity,
                                  child: TextButton.icon(
                                    onPressed: () async {
                                      final override = await _overrideService.requestOverride(context);
                                      if (override && mounted) {
                                        _handleRecovery();
                                      }
                                    },
                                    icon: Icon(
                                      Icons.emergency,
                                      color: Colors.orange.shade300,
                                      size: isSmallScreen ? 20 : 24,
                                    ),
                                    label: Text(
                                      'Emergency Override',
                                      style: TextStyle(
                                        fontSize: isSmallScreen ? 14 : 16,
                                        color: Colors.orange.shade300,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: isSmallScreen ? 24 : 32,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(
                                          color: Colors.orange.shade300.withOpacity(0.5),
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Sound indicator
                  if (_isPlayingSound)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.volume_up,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScriptureImage() {
    final imagePath = _scriptureImagePaths[_currentImageIndex];
    
    // Optimize: Use const widgets and cache images
    // Try to load the image, fallback to placeholder if not found
    return FutureBuilder<bool>(
      future: _checkImageExists(imagePath),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data == true) {
          return Image.asset(
            imagePath,
            fit: BoxFit.cover,
            cacheWidth: 800, // Limit image resolution for memory optimization
            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
          );
        }
        return _buildPlaceholder();
      },
    );
  }

  Future<bool> _checkImageExists(String path) async {
    // Check cache first to avoid repeated lookups (memory optimization)
    if (_imageCache.containsKey(path)) {
      return _imageCache[path] ?? false;
    }
    
    try {
      // Try to load the asset to check if it exists
      await rootBundle.load(path);
      _imageCache[path] = true;
      return true;
    } catch (e) {
      // Asset doesn't exist or can't be loaded
      _imageCache[path] = false;
      return false;
    }
  }

  Widget _buildPlaceholder() {
    final scriptures = [
      'Philippians 4:13',
      'Lamentations 3:22-23',
      '1 Peter 5:7',
      'Deuteronomy 31:6',
      'Joshua 1:9',
      'Matthew 11:28',
      'Proverbs 15:1',
      'Psalm 34:18',
      'Proverbs 3:5-6',
      '1 Thessalonians 5:18',
      'Philippians 4:7',
      'Isaiah 40:31',
      'Jeremiah 31:3',
      '1 John 1:9',
      'Jeremiah 29:11',
    ];

    final scriptureRef = scriptures[_currentImageIndex];
    
    return Container(
      color: Colors.white.withOpacity(0.05),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book_outlined,
              size: 64,
              color: Colors.white.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              scriptureRef,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.8),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Scripture ${_currentImageIndex + 1} of 15',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
