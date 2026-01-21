import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../services/detection_service.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import 'detection_overlay_screen.dart';
import 'recovery_screen.dart';

/// Detection Screen with real-time camera preview and enhanced features
class DetectionScreen extends StatefulWidget {
  const DetectionScreen({super.key});

  @override
  State<DetectionScreen> createState() => _DetectionScreenState();
}

class _DetectionScreenState extends State<DetectionScreen> {
  final _detectionService = DetectionService();
  final _authService = AuthService();
  final _databaseService = DatabaseService();
  final _imagePicker = ImagePicker();
  
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  bool _isCameraActive = false;
  bool _hasPermission = false;
  
  File? _selectedImage;
  bool _isProcessing = false;
  Map<String, dynamic>? _detectionResult;
  double _confidenceThreshold = 0.8; // Default 80%
  bool _isRealTimeDetection = false;
  Timer? _realTimeTimer;
  int _lockDurationMinutes = 3; // Default 3 minutes (1-5 range)
  
  @override
  void initState() {
    super.initState();
    _initializeDetection();
    _checkCameraPermission();
  }

  Future<void> _initializeDetection() async {
    await _detectionService.initialize();
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    if (status.isGranted) {
      setState(() {
        _hasPermission = true;
      });
      await _initializeCamera();
    } else if (status.isDenied) {
      // Permission not requested yet
      setState(() {
        _hasPermission = false;
      });
    }
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      setState(() {
        _hasPermission = true;
      });
      await _initializeCamera();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera permission is required for preview'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        return;
      }

      _cameraController = CameraController(
        _cameras![0],
        ResolutionPreset.medium,
        enableAudio: false, // No audio needed
      );

      await _cameraController!.initialize();
      
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Camera initialization error: $e')),
        );
      }
    }
  }

  Future<void> _startCameraPreview() async {
    if (!_hasPermission) {
      await _requestCameraPermission();
      return;
    }

    if (!_isCameraInitialized) {
      await _initializeCamera();
    }

    if (_cameraController != null && _cameraController!.value.isInitialized) {
      setState(() {
        _isCameraActive = true;
        _selectedImage = null;
        _detectionResult = null;
      });
    }
  }

  Future<void> _stopCameraPreview() async {
    _realTimeTimer?.cancel();
    setState(() {
      _isCameraActive = false;
      _isRealTimeDetection = false;
    });
  }

  Future<void> _startRealTimeDetection() async {
    if (!_isCameraActive || _cameraController == null || !_cameraController!.value.isInitialized) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Camera not ready. Please start camera first.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() {
      _isRealTimeDetection = true;
    });

    _realTimeTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) async {
      if (!_isRealTimeDetection || 
          _cameraController == null || 
          !_cameraController!.value.isInitialized ||
          !mounted) {
        timer.cancel();
        return;
      }

      try {
        final image = await _cameraController!.takePicture();
        final result = await _detectionService.detectImage(
          image.path,
          threshold: _confidenceThreshold,
        );

        if (mounted) {
          setState(() {
            _detectionResult = result;
          });

          // Show enhanced overlay if NSFW detected above threshold
          if (result['isNsfw'] == true && 
              (result['confidence'] as double) >= _confidenceThreshold) {
            _showEnhancedOverlay(result['confidence'] as double);
            _stopRealTimeDetection();
          }
        }
      } catch (e) {
        // Log error but continue detection
        debugPrint('Real-time detection error: $e');
        // Cancel timer on persistent errors
        if (!mounted || _cameraController == null || !_cameraController!.value.isInitialized) {
          timer.cancel();
        }
      }
    });
  }

  void _stopRealTimeDetection() {
    _realTimeTimer?.cancel();
    setState(() {
      _isRealTimeDetection = false;
    });
  }

  Future<void> _captureAndTest() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final image = await _cameraController!.takePicture();
      setState(() {
        _selectedImage = File(image.path);
        _detectionResult = null;
      });
      await _detectImage();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error capturing image: $e')),
        );
      }
    }
  }

  Future<void> _saveScreenshotToTestFolder() async {
    if (_selectedImage == null) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final testFolder = Directory(path.join(directory.path, 'test_screenshots'));
      if (!await testFolder.exists()) {
        await testFolder.create(recursive: true);
      }

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'test_$timestamp.jpg';
      final testFile = File(path.join(testFolder.path, fileName));
      
      await _selectedImage!.copy(testFile.path);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Screenshot saved to test folder: $fileName'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving screenshot: $e')),
        );
      }
    }
  }

  Future<void> _reportFalsePositive() async {
    if (_detectionResult == null) return;

    try {
      final userId = await _authService.getCurrentUserId();
      if (userId != null) {
        // Log false positive to database
        await _databaseService.logDetection(
          userId,
          _selectedImage?.path,
          _detectionResult!['confidence'] as double,
          false, // Mark as false positive
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('False positive reported. Thank you for the feedback!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error reporting false positive: $e')),
        );
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    // Stop camera if active
    if (_isCameraActive) {
      await _stopCameraPreview();
    }

    try {
      final pickedFile = await _imagePicker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          // On web, path might be a data URL, handle both cases
          if (kIsWeb) {
            // For web, we store the path as-is (it's a blob URL or data URL)
            _selectedImage = null; // Don't use File on web
            _selectedImagePath = pickedFile.path; // Store path for web
          } else {
            _selectedImage = File(pickedFile.path);
            _selectedImagePath = null;
          }
          _detectionResult = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _detectImage() async {
    final imagePath = kIsWeb ? _selectedImagePath : _selectedImage?.path;
    if (imagePath == null) return;

    setState(() {
      _isProcessing = true;
      _detectionResult = null;
    });

    try {
      final result = await _detectionService.detectImage(
        imagePath,
        threshold: _confidenceThreshold,
      );
      
      // Only log to database if user explicitly saves
      // (Privacy: no automatic storage)

      setState(() {
        _detectionResult = result;
        _isProcessing = false;
      });

      // Show enhanced overlay if NSFW detected above threshold
      if (result['isNsfw'] == true && 
          (result['confidence'] as double) >= _confidenceThreshold) {
        if (mounted) {
          _showEnhancedOverlay(result['confidence'] as double);
        }
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Detection error: $e')),
        );
      }
    }
  }

  Future<void> _saveDetection() async {
    if (_selectedImage == null || _detectionResult == null) return;

    try {
      final userId = await _authService.getCurrentUserId();
      if (userId != null) {
        await _databaseService.logDetection(
          userId,
          _selectedImage!.path,
          _detectionResult!['confidence'] as double,
          _detectionResult!['isNsfw'] as bool,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Detection saved to encrypted storage'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving detection: $e')),
        );
      }
    }
  }

  Future<void> _clearAllData() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'This will delete all detection logs and test screenshots. '
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final userId = await _authService.getCurrentUserId();
        if (userId != null) {
          // Clear detection logs from database
          await _databaseService.clearDetectionLogs(userId);
          
          // Clear test screenshots
          final directory = await getApplicationDocumentsDirectory();
          final testFolder = Directory(path.join(directory.path, 'test_screenshots'));
          if (await testFolder.exists()) {
            await testFolder.delete(recursive: true);
          }

          setState(() {
            _selectedImage = null;
            _selectedImagePath = null;
            _detectionResult = null;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('All data cleared successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error clearing data: $e')),
          );
        }
      }
    }
  }

  void _showEnhancedOverlay(double confidence) {
    // Stop camera preview if active
    if (_isCameraActive) {
      _stopCameraPreview();
    }

    // Navigate to enhanced overlay screen
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DetectionOverlayScreen(
          confidence: confidence,
          lockDurationMinutes: _lockDurationMinutes,
          onRecovery: () {
            // Show recovery screen after lock period
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => RecoveryScreen(
                  onContinue: () {
                    // Return to detection screen and reset
                    Navigator.of(context).pop();
                    setState(() {
                      _selectedImage = null;
                      _detectionResult = null;
                      _isCameraActive = false;
                    });
                  },
                ),
              ),
            );
          },
        ),
        fullscreenDialog: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNsfw = _detectionResult?['isNsfw'] == true;
    final confidence = _detectionResult?['confidence'] ?? 0.0;
    final meetsThreshold = confidence >= _confidenceThreshold;
    
    // Responsive sizing for mobile
    final mediaQuery = MediaQuery.of(context);
    final isSmallScreen = mediaQuery.size.height < 600 || mediaQuery.size.width < 360;
    final buttonMinHeight = 56.0; // 56dp minimum for touch-friendly buttons

    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Detection'),
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearAllData,
            tooltip: 'Clear all data',
            iconSize: 24,
          ),
        ],
      ),
      body: Container(
        // Show red background if NSFW detected above threshold
        color: isNsfw && meetsThreshold ? Colors.red.shade900 : Colors.white,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.all(isSmallScreen ? 12.0 : 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                // Settings Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Confidence Threshold
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Confidence Threshold',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${(_confidenceThreshold * 100).toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Slider(
                          value: _confidenceThreshold,
                          min: 0.60,
                          max: 0.95,
                          divisions: 35,
                          label: '${(_confidenceThreshold * 100).toStringAsFixed(0)}%',
                          onChanged: (value) {
                            setState(() {
                              _confidenceThreshold = value;
                            });
                          },
                        ),
                        const Text(
                          'Adjust sensitivity (60% - 95%)',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        
                        const Divider(height: 32),
                        
                        // Lock Duration
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Lock Duration',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '$_lockDurationMinutes min',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange.shade900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Slider(
                          value: _lockDurationMinutes.toDouble(),
                          min: 1.0,
                          max: 5.0,
                          divisions: 4,
                          label: '$_lockDurationMinutes min',
                          onChanged: (value) {
                            setState(() {
                              _lockDurationMinutes = value.toInt();
                            });
                          },
                        ),
                        const Text(
                          'Recovery lock time (1-5 minutes)',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Camera Preview or Image Display
                if (_isCameraActive && _cameraController != null && _cameraController!.value.isInitialized) ...[
                  // Real-time Camera Preview - responsive height
                  Container(
                    height: isSmallScreen ? 300 : 400,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, width: 2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        children: [
                          CameraPreview(_cameraController!),
                          // Overlay showing detection result
                          if (_detectionResult != null)
                            Positioned(
                              top: isSmallScreen ? 8 : 16,
                              left: isSmallScreen ? 8 : 16,
                              right: isSmallScreen ? 8 : 16,
                              child: Container(
                                padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                                decoration: BoxDecoration(
                                  color: isNsfw && meetsThreshold
                                      ? Colors.red.withOpacity(0.9)
                                      : Colors.green.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      isNsfw && meetsThreshold ? '⚠️ NSFW Detected' : '✓ Safe',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: isSmallScreen ? 14 : 16,
                                      ),
                                    ),
                                    Text(
                                      'Confidence: ${(confidence * 100).toStringAsFixed(1)}%',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: isSmallScreen ? 10 : 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  // Touch-friendly buttons - wrap in Flexible for smaller screens
                  isSmallScreen
                      ? Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _isRealTimeDetection
                                    ? _stopRealTimeDetection
                                    : _startRealTimeDetection,
                                icon: Icon(_isRealTimeDetection ? Icons.stop : Icons.play_arrow),
                                label: Text(_isRealTimeDetection ? 'Stop Detection' : 'Start Real-time'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isRealTimeDetection
                                      ? Colors.red.shade700
                                      : Colors.green.shade700,
                                  foregroundColor: Colors.white,
                                  minimumSize: Size(double.infinity, buttonMinHeight),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _captureAndTest,
                                    icon: const Icon(Icons.camera),
                                    label: const Text('Capture'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue.shade700,
                                      foregroundColor: Colors.white,
                                      minimumSize: Size(double.infinity, buttonMinHeight),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _stopCameraPreview,
                                    icon: const Icon(Icons.stop),
                                    label: const Text('Stop'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.grey.shade700,
                                      foregroundColor: Colors.white,
                                      minimumSize: Size(double.infinity, buttonMinHeight),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Flexible(
                              child: ElevatedButton.icon(
                                onPressed: _isRealTimeDetection
                                    ? _stopRealTimeDetection
                                    : _startRealTimeDetection,
                                icon: Icon(_isRealTimeDetection ? Icons.stop : Icons.play_arrow),
                                label: Text(_isRealTimeDetection ? 'Stop Detection' : 'Start Real-time'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isRealTimeDetection
                                      ? Colors.red.shade700
                                      : Colors.green.shade700,
                                  foregroundColor: Colors.white,
                                  minimumSize: Size(0, buttonMinHeight),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: ElevatedButton.icon(
                                onPressed: _captureAndTest,
                                icon: const Icon(Icons.camera),
                                label: const Text('Capture & Test'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade700,
                                  foregroundColor: Colors.white,
                                  minimumSize: Size(0, buttonMinHeight),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Flexible(
                              child: ElevatedButton.icon(
                                onPressed: _stopCameraPreview,
                                icon: const Icon(Icons.stop),
                                label: const Text('Stop Camera'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.grey.shade700,
                                  foregroundColor: Colors.white,
                                  minimumSize: Size(0, buttonMinHeight),
                                ),
                              ),
                            ),
                          ],
                        ),
                ] else if (_selectedImage != null || _selectedImagePath != null) ...[
                  // Static Image Display - responsive
                  Container(
                    height: isSmallScreen ? 300 : 400,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: kIsWeb && _selectedImagePath != null
                          ? Image.network(
                              _selectedImagePath!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(Icons.error, size: 48, color: Colors.red),
                                );
                              },
                            )
                          : _selectedImage != null
                              ? Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                  cacheWidth: 800, // Optimize memory for mobile
                                )
                              : const Center(child: Icon(Icons.image, size: 48)),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isProcessing ? null : _detectImage,
                      icon: _isProcessing
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.search),
                      label: Text(_isProcessing ? 'Testing...' : 'Test Detection'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blue.shade900,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, buttonMinHeight),
                      ),
                    ),
                  ),
                ] else ...[
                  // No image selected - responsive
                  Container(
                    height: isSmallScreen ? 300 : 400,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey, style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.image,
                            size: isSmallScreen ? 60 : 80,
                            color: Colors.grey,
                          ),
                          SizedBox(height: isSmallScreen ? 12 : 16),
                          Text(
                            'No image selected',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 16 : 18,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                SizedBox(height: isSmallScreen ? 12 : 16),

                // Action Buttons - touch-friendly
                if (!_isCameraActive)
                  isSmallScreen
                      ? Column(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _hasPermission
                                    ? _startCameraPreview
                                    : _requestCameraPermission,
                                icon: const Icon(Icons.camera_alt),
                                label: const Text('Camera'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade700,
                                  foregroundColor: Colors.white,
                                  minimumSize: Size(double.infinity, buttonMinHeight),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: () => _pickImage(ImageSource.gallery),
                                icon: const Icon(Icons.photo_library),
                                label: const Text('Gallery'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade700,
                                  foregroundColor: Colors.white,
                                  minimumSize: Size(double.infinity, buttonMinHeight),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _hasPermission
                                    ? _startCameraPreview
                                    : _requestCameraPermission,
                                icon: const Icon(Icons.camera_alt),
                                label: const Text('Camera'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade700,
                                  foregroundColor: Colors.white,
                                  minimumSize: Size(0, buttonMinHeight),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _pickImage(ImageSource.gallery),
                                icon: const Icon(Icons.photo_library),
                                label: const Text('Gallery'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade700,
                                  foregroundColor: Colors.white,
                                  minimumSize: Size(0, buttonMinHeight),
                                ),
                              ),
                            ),
                          ],
                        ),

                // Detection Results
                if (_detectionResult != null) ...[
                  const SizedBox(height: 24),
                  Card(
                    color: isNsfw && meetsThreshold
                        ? Colors.red.shade50
                        : Colors.green.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Detection Result:',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isNsfw && meetsThreshold
                                      ? Colors.red.shade900
                                      : Colors.green.shade900,
                                ),
                              ),
                              if (isNsfw && !meetsThreshold)
                                TextButton.icon(
                                  onPressed: _reportFalsePositive,
                                  icon: const Icon(Icons.flag, size: 16),
                                  label: const Text('Report False Positive'),
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.orange,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildResultRow(
                            'Status',
                            isNsfw && meetsThreshold ? '⚠️ NSFW Detected' : '✓ Safe',
                            isNsfw && meetsThreshold,
                          ),
                          _buildResultRow(
                            'Confidence',
                            '${(confidence * 100).toStringAsFixed(1)}%',
                            isNsfw && meetsThreshold,
                          ),
                          _buildResultRow(
                            'Threshold',
                            '${(_confidenceThreshold * 100).toStringAsFixed(0)}%',
                            isNsfw && meetsThreshold,
                          ),
                          if (_detectionResult!['error'] != null)
                            _buildResultRow(
                              'Error',
                              _detectionResult!['error'].toString(),
                              false,
                            ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              OutlinedButton.icon(
                                onPressed: _saveDetection,
                                icon: const Icon(Icons.save),
                                label: const Text('Save Detection'),
                              ),
                              OutlinedButton.icon(
                                onPressed: _saveScreenshotToTestFolder,
                                icon: const Icon(Icons.screenshot),
                                label: const Text('Save Screenshot'),
                              ),
                            ],
                          ),
                        ],
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
      ),
    );
  }

  Widget _buildResultRow(String label, String value, bool isWarning) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isWarning ? Colors.red.shade900 : Colors.green.shade900,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isWarning ? Colors.red.shade900 : Colors.green.shade900,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _realTimeTimer?.cancel();
    _cameraController?.dispose();
    _detectionService.dispose();
    super.dispose();
  }
}
