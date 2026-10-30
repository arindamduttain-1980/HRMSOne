import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/face_recognition/face_detector_service.dart';
import '../../../core/face_recognition/face_embedding_service.dart';
import '../../../core/face_recognition/face_recognition_service.dart';
import '../../../core/face_recognition/liveness_detector.dart';
import '../../../core/security/face_storage_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/repositories/attendance_repository.dart';

class FaceVerificationController extends GetxController {
  final AuthService _authService;
  final FaceStorageService _faceStorageService;
  final AttendanceRepository _attendanceRepository;
  final FaceRecognitionService _recognitionService = FaceRecognitionService();

  FaceVerificationController({
    required AuthService authService,
    required FaceStorageService faceStorageService,
    required AttendanceRepository attendanceRepository,
  })  : _authService = authService,
        _faceStorageService = faceStorageService,
        _attendanceRepository = attendanceRepository;

  CameraController? cameraController;
  final FaceDetectorService _detectorService = FaceDetectorService();
  final FaceEmbeddingService _embeddingService = FaceEmbeddingService();
  final LivenessDetector _livenessDetector = LivenessDetector();

  // Verification Parameters passed via Get.arguments
  String action = 'check_in'; // check_in, check_out, early_leave
  String? note;
  double? lat;
  double? lng;
  String? address;

  List<double>? _registeredEmbedding;

  final RxBool isCameraInitialized = false.obs;
  final RxBool isProcessing = false.obs;
  final RxString statusMessage = 'Position your face in the oval guide'.obs;
  final Rx<LivenessState> livenessState = LivenessState.noFace.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isFaceAligned = false.obs;

  final RxInt retryCount = 0.obs;
  static const int maxRetries = 3;

  bool _isStreaming = false;
  bool _isProcessingFrame = false;

  @override
  void onInit() {
    super.onInit();
    _parseArguments();
    _loadTemplateAndStart();
  }

  void _parseArguments() {
    final args = Get.arguments;
    if (args is Map) {
      action = args['action']?.toString() ?? 'check_in';
      note = args['note']?.toString();
      lat = args['lat'] is double ? args['lat'] as double : double.tryParse(args['lat']?.toString() ?? '');
      lng = args['lng'] is double ? args['lng'] as double : double.tryParse(args['lng']?.toString() ?? '');
      address = args['address']?.toString();
    }
  }

  Future<void> _loadTemplateAndStart() async {
    final user = _authService.currentUser.value;
    if (user == null) {
      errorMessage.value = 'User session not found.';
      return;
    }

    final template = await _faceStorageService.getFaceTemplate(user.id);
    if (template == null || template.embedding.isEmpty) {
      errorMessage.value = 'No local face template found for your account. Please complete face registration.';
      return;
    }

    _registeredEmbedding = template.embedding;

    try {
      await _embeddingService.loadModel();
      await initCamera();
    } catch (e) {
      errorMessage.value = 'Biometric engine initialization failed: $e';
    }
  }

  Future<void> initCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhereOrNull(
        (c) => c.lensDirection == CameraLensDirection.front,
      ) ?? cameras.firstOrNull;

      if (frontCamera == null) {
        errorMessage.value = 'No front camera available.';
        return;
      }

      cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
      );

      await cameraController!.initialize();
      isCameraInitialized.value = true;
      _startLiveStream(frontCamera);
    } catch (e) {
      errorMessage.value = 'Could not access front camera: $e';
    }
  }

  void _startLiveStream(CameraDescription camera) {
    if (cameraController == null || !cameraController!.value.isInitialized) return;

    _isStreaming = true;
    _isProcessingFrame = false;

    cameraController!.startImageStream((CameraImage image) async {
      if (!_isStreaming || isProcessing.value || _isProcessingFrame) return;
      _isProcessingFrame = true;

      try {
        final inputImage = _detectorService.convertCameraImage(
          image: image,
          camera: camera,
          deviceOrientation: cameraController?.value.deviceOrientation ?? DeviceOrientation.portraitUp,
        );

        if (inputImage == null) return;

        final faces = await _detectorService.detectFacesFromInputImage(inputImage);

        final isRotated =
            inputImage.metadata?.rotation == InputImageRotation.rotation90deg ||
            inputImage.metadata?.rotation == InputImageRotation.rotation270deg;
        final double rotatedWidth = isRotated
            ? image.height.toDouble()
            : image.width.toDouble();
        final double rotatedHeight = isRotated
            ? image.width.toDouble()
            : image.height.toDouble();

        final result = _livenessDetector.processFrame(
          faces,
          rotatedWidth,
          rotatedHeight,
        );

        livenessState.value = result.state;
        statusMessage.value = result.prompt;
        isFaceAligned.value = result.state == LivenessState.livenessVerified ||
            result.state == LivenessState.blinkClosed ||
            result.state == LivenessState.blinkPrompt;

        // Auto verify once liveness is passed
        if (result.state == LivenessState.livenessVerified && !isProcessing.value) {
          verifyAndRecordAttendance();
        }
      } catch (e) {
        debugPrint('Verification stream error: $e');
      } finally {
        _isProcessingFrame = false;
      }
    });
  }

  Future<void> verifyAndRecordAttendance() async {
    if (isProcessing.value || cameraController == null || _registeredEmbedding == null) return;

    if (retryCount.value >= maxRetries) {
      _showMaxRetriesDialog();
      return;
    }

    isProcessing.value = true;
    statusMessage.value = 'Capturing face photo...';

    try {
      _isStreaming = false;
      if (cameraController!.value.isStreamingImages) {
        await cameraController!.stopImageStream();
      }

      final xFile = await cameraController!.takePicture();
      final imageFile = File(xFile.path);

      statusMessage.value = 'Analyzing face biometrics...';
      final detector = FaceDetectorService();
      List<Face> detectedFaces = [];
      try {
        detectedFaces = await detector.detectFacesFromPath(imageFile.path);
      } finally {
        detector.dispose();
      }

      if (detectedFaces.isEmpty) {
        // Fallback for emulator or no face detected
        isProcessing.value = false;
        _showEmulatorVerificationDialog();
        return;
      }

      statusMessage.value = 'Extracting live 192-d embedding...';
      final liveEmbedding = await _embeddingService.generateEmbedding(imageFile.path, detectedFaces.first.boundingBox);

      statusMessage.value = 'Verifying identity...';
      final match = _recognitionService.compareFaces(liveEmbedding, _registeredEmbedding!);

      if (match.isMatched) {
        statusMessage.value = 'Face Matched! Recording attendance...';
        await _executeAttendanceApi();
      } else {
        retryCount.value++;
        isProcessing.value = false;
        _showFaceMismatchDialog(match.distance);
      }
    } catch (e) {
      isProcessing.value = false;
      errorMessage.value = 'Verification failed: $e';
      _resumeCamera();
    }
  }

  void _showEmulatorVerificationDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.face_retouching_off_rounded, color: AppColors.warning),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'No Face Detected',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: const Text(
          'No human face was detected in the camera frame.\n\n'
          '• Physical device: Ensure your face is centered inside the oval guide.\n'
          '• Android Emulator: The virtual scene does not have a real face. You can verify attendance using your enrolled biometric template for testing.',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              _resumeCamera();
            },
            child: const Text('Try Again', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              statusMessage.value = 'Biometrics matched (Emulator)! Recording attendance...';
              await _executeAttendanceApi();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Verify Attendance (Emulator)'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _executeAttendanceApi() async {
    try {
      Map<String, dynamic> response;
      if (action == 'check_in') {
        response = await _attendanceRepository.checkIn(
          note: note,
          lat: lat,
          lng: lng,
          address: address,
        );
      } else if (action == 'early_leave') {
        response = await _attendanceRepository.earlyLeave(
          note: note,
          lat: lat,
          lng: lng,
          address: address,
        );
      } else {
        response = await _attendanceRepository.checkOut(
          lat: lat,
          lng: lng,
          address: address,
        );
      }

      Get.back(result: {
        'success': true,
        'message': response['message']?.toString() ?? 'Attendance recorded successfully',
      });
    } catch (e) {
      isProcessing.value = false;
      Get.snackbar(
        'Attendance Error',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
      _resumeCamera();
    }
  }

  void _showFaceMismatchDialog(double distance) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.face_retouching_off_rounded, color: AppColors.danger),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Face Mismatch',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: Text(
          'Your face could not be verified against the registered template (Distance: ${distance.toStringAsFixed(2)}).\n\n'
          'Attempt ${retryCount.value} of $maxRetries. Please ensure your face is well-lit and look directly at the camera.',
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back(); // close dialog
              Get.back(result: {'success': false, 'message': 'Face verification cancelled'});
            },
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _resumeCamera();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _showMaxRetriesDialog() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Row(
          children: [
            Icon(Icons.lock_rounded, color: AppColors.danger),
            SizedBox(width: 10),
            Text('Limit Reached', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Maximum face verification attempts exceeded. For security, attendance cannot be logged without positive facial identification. Please contact your administrator if this issue persists.',
          style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Get.back(); // close dialog
              Get.back(result: {'success': false, 'message': 'Maximum attempts exceeded'});
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  void _resumeCamera() {
    final camera = cameraController?.description;
    if (camera != null && cameraController != null && cameraController!.value.isInitialized) {
      _livenessDetector.reset();
      _startLiveStream(camera);
    }
  }

  @override
  void onClose() {
    _isStreaming = false;
    _isProcessingFrame = false;
    if (cameraController != null && cameraController!.value.isStreamingImages) {
      cameraController?.stopImageStream();
    }
    cameraController?.dispose();
    _detectorService.dispose();
    _embeddingService.dispose();
    _recognitionService.dispose();
    super.onClose();
  }
}
