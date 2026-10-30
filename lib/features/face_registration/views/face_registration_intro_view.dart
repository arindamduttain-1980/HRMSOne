import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';

class FaceRegistrationIntroView extends StatelessWidget {
  const FaceRegistrationIntroView({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();
    final user = authService.currentUser.value;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await authService.logout();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Face Registration', style: AppTextStyles.h3),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Back to Login',
            onPressed: () async {
              await authService.logout();
            },
          ),
        ),
        body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 12),

              // Employee Profile Preview Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white,
                      child: Text(
                        user?.initials ?? '?',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Employee',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.designation.isNotEmpty == true ? user!.designation : (user?.role ?? ''),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.shield_rounded, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'FRS Required',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'Enroll Your Face Template',
                style: AppTextStyles.h2,
              ),
              const SizedBox(height: 6),
              const Text(
                'To mark daily attendance with one touch, a 192-dimensional biometric template must be enrolled for your account.',
                style: AppTextStyles.body,
              ),

              const SizedBox(height: 24),

              // Step-by-Step Guideline Cards
              Expanded(
                child: ListView(
                  children: const [
                    _InstructionTile(
                      icon: Icons.face_retouching_natural_rounded,
                      title: 'Position Your Face',
                      description: 'Hold the phone at eye level inside the oval frame.',
                    ),
                    SizedBox(height: 12),
                    _InstructionTile(
                      icon: Icons.light_mode_outlined,
                      title: 'Adequate Lighting',
                      description: 'Ensure your face is well-lit without strong backlight or shadows.',
                    ),
                    SizedBox(height: 12),
                    _InstructionTile(
                      icon: Icons.remove_red_eye_outlined,
                      title: 'Liveness & Blink Check',
                      description: 'Look directly into the camera and blink when prompted.',
                    ),
                    SizedBox(height: 12),
                    _InstructionTile(
                      icon: Icons.lock_outline_rounded,
                      title: 'Hardware Biometric Security',
                      description: 'Templates are stored locally with AES-256 encryption. Raw photos are not retained.',
                    ),
                  ],
                ),
              ),

              // Action Button
              ElevatedButton.icon(
                onPressed: () => Get.toNamed(AppRoutes.faceRegistrationCamera),
                icon: const Icon(Icons.camera_alt_rounded, size: 20),
                label: const Text('Start Face Registration'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    ),
  );
}
}

class _InstructionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _InstructionTile({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary)),
                const SizedBox(height: 3),
                Text(description, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

