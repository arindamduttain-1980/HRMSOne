import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/face_recognition/liveness_detector.dart';
import '../controllers/face_registration_controller.dart';

class FaceRegistrationCameraView extends GetView<FaceRegistrationController> {
  const FaceRegistrationCameraView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        if (!controller.isCameraInitialized.value) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  controller.errorMessage.isNotEmpty
                      ? controller.errorMessage.value
                      : 'Initializing front camera...',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            // Camera Preview
            Center(
              child: CameraPreview(controller.cameraController!),
            ),

            // Oval Viewfinder Overlay
            CustomPaint(
              painter: _OvalViewfinderPainter(
                livenessState: controller.livenessState.value,
                isAligned: controller.isFaceAligned.value,
              ),
            ),

            // Top Header & Prompt Pill
            SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.black45,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back,
                                color: Colors.white),
                            onPressed: () => Get.back(),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.face_unlock_rounded,
                                  color: Colors.white, size: 16),
                              SizedBox(width: 6),
                              Text(
                                'Face Enrollment',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 40),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Instructional Prompt Pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 10),
                      decoration: BoxDecoration(
                        color: _getPromptBackgroundColor(
                            controller.livenessState.value),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getPromptIcon(controller.livenessState.value),
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              controller.statusMessage.value,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Actions
            Positioned(
              bottom: 30,
              left: 24,
              right: 24,
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (controller.isProcessing.value)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2.5),
                            ),
                            SizedBox(width: 14),
                            Text(
                              'Processing Biometric Template...',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: controller.isCameraInitialized.value &&
                                !controller.isProcessing.value
                            ? controller.captureAndRegisterFace
                            : null,
                        icon: const Icon(Icons.camera_rounded, size: 22),
                        label: const Text('Capture & Register'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.white24,
                          disabledForegroundColor: Colors.white38,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 32, vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16)),
                          textStyle: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Color _getPromptBackgroundColor(LivenessState state) {
    switch (state) {
      case LivenessState.livenessVerified:
        return AppColors.success.withOpacity(0.9);
      case LivenessState.blinkClosed:
      case LivenessState.blinkPrompt:
        return AppColors.primary.withOpacity(0.9);
      case LivenessState.invalidFace:
        return AppColors.danger.withOpacity(0.9);
      case LivenessState.noFace:
        return Colors.black87;
    }
  }

  IconData _getPromptIcon(LivenessState state) {
    switch (state) {
      case LivenessState.livenessVerified:
        return Icons.check_circle_rounded;
      case LivenessState.blinkClosed:
      case LivenessState.blinkPrompt:
        return Icons.visibility_rounded;
      case LivenessState.invalidFace:
        return Icons.warning_rounded;
      case LivenessState.noFace:
        return Icons.face_rounded;
    }
  }
}

class _OvalViewfinderPainter extends CustomPainter {
  final LivenessState livenessState;
  final bool isAligned;

  _OvalViewfinderPainter({
    required this.livenessState,
    required this.isAligned,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.6)
      ..style = PaintingStyle.fill;

    // Viewfinder oval size
    final ovalWidth = size.width * 0.72;
    final ovalHeight = size.height * 0.46;
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.45),
      width: ovalWidth,
      height: ovalHeight,
    );

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addOval(rect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, backgroundPaint);

    // Border paint
    Color borderColor;
    if (livenessState == LivenessState.livenessVerified) {
      borderColor = AppColors.success;
    } else if (livenessState == LivenessState.invalidFace) {
      borderColor = AppColors.danger;
    } else if (isAligned) {
      borderColor = AppColors.primary;
    } else {
      borderColor = Colors.white70;
    }

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    canvas.drawOval(rect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _OvalViewfinderPainter oldDelegate) {
    return oldDelegate.livenessState != livenessState ||
        oldDelegate.isAligned != isAligned;
  }
}
