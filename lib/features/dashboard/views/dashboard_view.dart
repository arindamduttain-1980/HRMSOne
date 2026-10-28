import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/status_badge.dart';
import '../controllers/dashboard_controller.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();

    return Scaffold(
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: controller.loadDashboardData,
        color: AppColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Navy Gradient Header
              _buildHeader(context, authService),

              // 2. Main Punch Status Card
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: _buildAttendanceCard(context),
              ),

              // 3. Quick Action Feature Grid
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'QUICK ACCESS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureGrid(authService),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 4. Last 7 Days Attendance History
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: const [
                    Icon(Icons.history, size: 18, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text(
                      'Last 7 Days',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _buildHistoryList(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AuthService authService) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 28,
        left: 16,
        right: 16,
      ),
      decoration: const BoxDecoration(
        gradient: AppColors.navyGradient,
      ),
      child: Row(
        children: [
          Builder(
            builder: (ctx) => IconButton(
              icon: const Icon(Icons.menu, color: Colors.white, size: 26),
              onPressed: () => Scaffold.of(ctx).openDrawer(),
            ),
          ),
          const SizedBox(width: 8),

          // Avatar
          Obx(() {
            final user = authService.currentUser.value;
            return Stack(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primary,
                  backgroundImage: (user?.photoUrl != null && user!.photoUrl!.isNotEmpty)
                      ? NetworkImage(user.photoUrl!)
                      : null,
                  child: (user?.photoUrl == null || user!.photoUrl!.isEmpty)
                      ? Text(
                          user?.initials ?? '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        )
                      : null,
                ),
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: AppColors.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt, size: 10, color: Colors.white),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(width: 12),

          // Greeting & User Name
          Expanded(
            child: Obx(() {
              final user = authService.currentUser.value;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.greeting,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    user?.name ?? 'Employee',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    user?.designation.isNotEmpty == true ? user!.designation : (user?.role ?? ''),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              );
            }),
          ),

          // Logout
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white70, size: 22),
            onPressed: () => _confirmLogout(context, authService),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(BuildContext context) {
    return Transform.translate(
      offset: const Offset(0, -12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            // Live Clock
            Obx(() => Column(
                  children: [
                    Text(
                      controller.currentTime.value,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      controller.currentDate.value,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                )),
            const SizedBox(height: 14),

            // Status Badge
            Obx(() {
              final today = controller.todayRecord.value;
              String status = 'not_checked_in';
              String label = 'Not Checked In';

              if (today != null) {
                if (today.isCheckedIn) {
                  status = 'present';
                  label = 'Checked In';
                } else if (today.isCompleted) {
                  status = 'present';
                  label = 'Checked Out (${today.hoursWorked ?? 0} hrs)';
                } else if (today.isWFH) {
                  status = 'work_from_home';
                  label = 'Work From Home';
                } else if (today.isHalfDay) {
                  status = 'half_day';
                  label = 'Half Day';
                }
              }

              return StatusBadge(
                status: status,
                label: label,
                fontSize: 13,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              );
            }),
            const SizedBox(height: 18),

            // In / Out Times
            Obx(() {
              final today = controller.todayRecord.value;
              final checkInStr = DateFormatter.toDisplayTime(today?.checkIn);
              final checkOutStr = DateFormatter.toDisplayTime(today?.checkOut);

              return Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.login, size: 14, color: AppColors.success),
                              SizedBox(width: 4),
                              Text('Check In', style: AppTextStyles.caption),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            checkInStr,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.logout, size: 14, color: AppColors.danger),
                              SizedBox(width: 4),
                              Text('Check Out', style: AppTextStyles.caption),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            checkOutStr,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.danger,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 14),

            // Note Input
            TextField(
              controller: controller.noteController,
              decoration: InputDecoration(
                hintText: 'Add a note (optional)...',
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                filled: true,
                fillColor: AppColors.inputBg,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
              style: const TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 16),

            // Primary In/Out Action Buttons
            Obx(() {
              final isBusy = controller.isActionLoading.value;
              final isCheckingIn = controller.activeAction.value == 'check_in';
              final isCheckingOut = controller.activeAction.value == 'check_out';
              final today = controller.todayRecord.value;
              final hasCheckedIn = today != null && today.checkIn != null && today.checkIn!.isNotEmpty;
              final hasCheckedOut = today != null && today.checkOut != null && today.checkOut!.isNotEmpty;

              return Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: (isBusy || hasCheckedIn) ? null : controller.checkIn,
                      icon: isCheckingIn
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.fingerprint, size: 20),
                      label: Text(isCheckingIn ? 'Locating...' : 'Check In'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: (isBusy || !hasCheckedIn || hasCheckedOut) ? null : controller.checkOut,
                      icon: isCheckingOut
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.door_front_door_outlined, size: 20),
                      label: Text(isCheckingOut ? 'Locating...' : 'Check Out'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              );
            }),
            const SizedBox(height: 12),

            // Mark As: Half Day / WFH / Early Leave
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => controller.markStatus('half_day'),
                    icon: const Icon(Icons.timelapse, size: 14, color: AppColors.warning),
                    label: const Text('Half Day', style: TextStyle(fontSize: 11, color: AppColors.textPrimary)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => controller.markStatus('work_from_home'),
                    icon: const Icon(Icons.home_work_outlined, size: 14, color: AppColors.info),
                    label: const Text('WFH', style: TextStyle(fontSize: 11, color: AppColors.textPrimary)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: controller.earlyLeave,
                    icon: const Icon(Icons.directions_walk, size: 14, color: AppColors.danger),
                    label: const Text('Early Leave', style: TextStyle(fontSize: 11, color: AppColors.textPrimary)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureGrid(AuthService authService) {
    final items = [
      _FeatureItem('Notices', Icons.campaign_rounded, AppColors.primary, AppRoutes.noticeBoard),
      _FeatureItem('Notes', Icons.note_alt_rounded, Colors.amber.shade700, AppRoutes.stickyNotes),
      _FeatureItem('Calendar', Icons.calendar_month_rounded, Colors.purple.shade600, AppRoutes.calendar),
      _FeatureItem('Meetings', Icons.video_call_rounded, Colors.teal.shade600, AppRoutes.meetings),
      _FeatureItem('Tasks', Icons.task_alt_rounded, Colors.blue.shade700, AppRoutes.taskManager),
      _FeatureItem('Leaves', Icons.flight_takeoff_rounded, Colors.orange.shade700, AppRoutes.leaveManagement),
      _FeatureItem('Cards', Icons.badge_rounded, AppColors.secondary, AppRoutes.digitalCards),
      _FeatureItem('Tickets', Icons.headset_mic_rounded, Colors.pink.shade600, AppRoutes.supportTickets),
      _FeatureItem('Salary', Icons.receipt_long_rounded, Colors.green.shade700, AppRoutes.salarySlips),
      _FeatureItem('Travel', Icons.alt_route_rounded, Colors.indigo.shade600, AppRoutes.travelAllowance),
      if (authService.hasSalesAccess)
        _FeatureItem('Leads', Icons.people_alt_rounded, Colors.deepOrange.shade600, AppRoutes.leadsContacts),
      _FeatureItem('Chat', Icons.chat_bubble_rounded, Colors.cyan.shade700, AppRoutes.messenger),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.88,
      ),
      itemBuilder: (ctx, i) {
        final item = items[i];
        return InkWell(
          onTap: () => Get.toNamed(item.route),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(item.icon, color: item.color, size: 22),
                ),
                const SizedBox(height: 8),
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (controller.history.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: EmptyStateView(
            title: 'No recent attendance history',
            message: 'Your punch records from the last 7 days will appear here.',
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: controller.history.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (ctx, i) {
          final record = controller.history[i];
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(Icons.event_available, color: AppColors.primary, size: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormatter.toDisplayDate(record.date),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'In: ${DateFormatter.toDisplayTime(record.checkIn)}  •  Out: ${DateFormatter.toDisplayTime(record.checkOut)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusBadge(status: record.status),
              ],
            ),
          );
        },
      );
    });
  }

  void _confirmLogout(BuildContext context, AuthService authService) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm Logout', style: AppTextStyles.h3),
        content: const Text(
          'Are you sure you want to sign out of your account?',
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Get.back();
              authService.logout();
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem {
  final String title;
  final IconData icon;
  final Color color;
  final String route;

  _FeatureItem(this.title, this.icon, this.color, this.route);
}

