import 'dart:io';
import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/face_recognition/face_detector_service.dart';
import '../../../core/face_recognition/face_embedding_service.dart';
import '../../../core/face_recognition/liveness_detector.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/security/face_storage_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/repositories/face_repository.dart';

class FaceRegistrationController extends GetxController {
  final AuthService _authService;
  final FaceStorageService _faceStorageService;
  final FaceRepository _faceRepository;

  FaceRegistrationController({
    required AuthService authService,
    required FaceStorageService faceStorageService,
    required FaceRepository faceRepository,
  })  : _authService = authService,
        _faceStorageService = faceStorageService,
        _faceRepository = faceRepository;

  CameraController? cameraController;
  final FaceDetectorService _detectorService = FaceDetectorService();
  final FaceEmbeddingService _embeddingService = FaceEmbeddingService();
  final LivenessDetector _livenessDetector = LivenessDetector();

  final RxBool isCameraInitialized = false.obs;
  final RxBool isProcessing = false.obs;
  final RxString statusMessage = 'Position your face inside the oval guide'.obs;
  final Rx<LivenessState> livenessState = LivenessState.noFace.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isFaceAligned = false.obs;

  bool _isStreaming = false;
  bool _isProcessingFrame = false;

  @override
  void onInit() {
    super.onInit();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      await _embeddingService.loadModel();
      await initCamera();
    } catch (e) {
      errorMessage.value = 'Failed to initialize face recognition: $e';
    }
  }

  Future<void> initCamera() async {
    try {
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhereOrNull(
            (c) => c.lensDirection == CameraLensDirection.front,
          ) ??
          cameras.firstOrNull;

      if (frontCamera == null) {
        errorMessage.value = 'No camera found on this device.';
        return;
      }

      cameraController = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await cameraController!.initialize();
      isCameraInitialized.value = true;
      _startLiveStream(frontCamera);
    } catch (e) {
      errorMessage.value = 'Could not access front camera: $e';
    }
  }

  void _startLiveStream(CameraDescription camera) {
    if (cameraController == null || !cameraController!.value.isInitialized)
      return;

    _isStreaming = true;
    _isProcessingFrame = false;

    cameraController!.startImageStream((CameraImage image) async {
      if (!_isStreaming || isProcessing.value || _isProcessingFrame) return;
      _isProcessingFrame = true;

      try {
        final inputImage = _detectorService.convertCameraImage(
          image: image,
          camera: camera,
          deviceOrientation: cameraController?.value.deviceOrientation ??
              DeviceOrientation.portraitUp,
        );

        if (inputImage == null) return;

        final faces =
            await _detectorService.detectFacesFromInputImage(inputImage);

        final isRotated = inputImage.metadata?.rotation ==
                InputImageRotation.rotation90deg ||
            inputImage.metadata?.rotation == InputImageRotation.rotation270deg;
        final double rotatedWidth =
            isRotated ? image.height.toDouble() : image.width.toDouble();
        final double rotatedHeight =
            isRotated ? image.width.toDouble() : image.height.toDouble();

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

        // Auto capture if liveness is verified
        if (result.state == LivenessState.livenessVerified &&
            !isProcessing.value) {
          captureAndRegisterFace();
        }
      } catch (e) {
        debugPrint('Face stream error: $e');
      } finally {
        _isProcessingFrame = false;
      }
    });
  }

  Future<void> captureAndRegisterFace() async {
    if (isProcessing.value || cameraController == null) return;

    isProcessing.value = true;
    statusMessage.value = 'Capturing face photo...';

    try {
      // Temporarily stop stream to take a high-res photo
      _isStreaming = false;
      if (cameraController!.value.isStreamingImages) {
        await cameraController!.stopImageStream();
      }

      final xFile = await cameraController!.takePicture();
      final imageFile = File(xFile.path);

      statusMessage.value = 'Analyzing face in photo...';
      final detector = FaceDetectorService();
      List<Face> detectedFaces = [];
      try {
        detectedFaces = await detector.detectFacesFromPath(imageFile.path);
      } finally {
        detector.dispose();
      }

      List<double> embedding;

      if (detectedFaces.isEmpty) {
        // Fallback for emulator or no face detected in camera
        isProcessing.value = false;
        _showEmulatorOrMissingFaceDialog(imageFile);
        return;
      } else if (detectedFaces.length > 1) {
        throw Exception(
            'Multiple faces detected. Please ensure only you are in frame.');
      } else {
        statusMessage.value = 'Generating 192-d biometric embedding...';
        embedding = await _embeddingService.generateEmbedding(
            imageFile.path, detectedFaces.first.boundingBox);
      }

      await _completeRegistration(embedding);
    } catch (e) {
      errorMessage.value = 'Face capture error: $e';
      statusMessage.value = 'Registration failed. Please try again.';
      isProcessing.value = false;
      _resumeCamera();
    }
  }

  void _showEmulatorOrMissingFaceDialog(File imageFile) {
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
          '• Physical device: Ensure your face is centered inside the oval guide under sufficient light.\n'
          '• Android Emulator: The default virtual room scene does not contain a real face. You can enroll a simulated 192-d template to verify the complete FRS flow.',
          style: TextStyle(
              fontSize: 14, color: AppColors.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              _resumeCamera();
            },
            child: const Text('Try Again',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await _enrollSimulatedBiometricTemplate();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Enroll Test Biometric (Emulator)'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _enrollSimulatedBiometricTemplate() async {
    isProcessing.value = true;
    statusMessage.value = 'Enrolling test biometric template...';
    try {
      final currentUser = _authService.currentUser.value;
      final employeeId = currentUser?.id ?? 0;
      // Generate deterministic 192-d test embedding based on employeeId
      final random = Random(employeeId + 42);
      final embedding =
          List<double>.generate(192, (i) => (random.nextDouble() * 2 - 1));

      await _completeRegistration(embedding);
    } catch (e) {
      errorMessage.value = 'Registration error: $e';
      isProcessing.value = false;
      _resumeCamera();
    }
  }

  Future<void> _completeRegistration(List<double> embedding) async {
    if (embedding.length != 192) {
      throw Exception('Invalid embedding size: ${embedding.length}');
    }

    final currentUser = _authService.currentUser.value;
    final employeeId = currentUser?.id ?? 0;

    statusMessage.value = 'Securing encrypted template in local database...';
    await _faceStorageService.saveFaceTemplate(
      employeeId: employeeId,
      embedding: embedding,
      isSynced: false,
    );

    statusMessage.value = 'Synchronizing with server...';
    final serverResp = await _faceRepository.registerFace(embedding: embedding);

    if (serverResp.success) {
      await _faceStorageService.markSynced(employeeId);
    }

    // Update current user state with face = 1
    if (currentUser != null) {
      _authService.updateUser(currentUser.copyWith(face: 1));
    }

    Get.offNamed(AppRoutes.faceRegistrationSuccess);
  }

  void _resumeCamera() {
    final camera = cameraController?.description;
    if (camera != null &&
        cameraController != null &&
        cameraController!.value.isInitialized) {
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
    super.onClose();
  }
}
