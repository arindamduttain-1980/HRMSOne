import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Get.find<AuthService>();

    return Drawer(
      backgroundColor: AppColors.card,
      elevation: 16,
      child: Column(
        children: [
          // Header
          Obx(() {
            final user = authService.currentUser.value;
            return Container(
              width: double.infinity,
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 20,
                bottom: 24,
                left: 20,
                right: 20,
              ),
              decoration: const BoxDecoration(
                gradient: AppColors.navyGradient,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Avatar
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 30,
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
                                      fontSize: 20,
                                    ),
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: InkWell(
                              onTap: () {
                                Get.back();
                                Get.toNamed(AppRoutes.profile);
                              },
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.secondary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt, size: 12, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    user?.name ?? 'Employee',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user?.designation.isNotEmpty == true ? user!.designation : (user?.role ?? ''),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }),

          // Navigation List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _navItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home,
                  title: 'Home',
                  route: AppRoutes.dashboard,
                ),
                _navItem(
                  icon: Icons.campaign_outlined,
                  activeIcon: Icons.campaign,
                  title: 'Notice Board',
                  route: AppRoutes.noticeBoard,
                ),
                _navItem(
                  icon: Icons.note_alt_outlined,
                  activeIcon: Icons.note_alt,
                  title: 'Sticky Notes',
                  route: AppRoutes.stickyNotes,
                ),
                _navItem(
                  icon: Icons.calendar_month_outlined,
                  activeIcon: Icons.calendar_month,
                  title: 'Calendar',
                  route: AppRoutes.calendar,
                ),
                _navItem(
                  icon: Icons.video_call_outlined,
                  activeIcon: Icons.video_call,
                  title: 'Meetings',
                  route: AppRoutes.meetings,
                ),
                _navItem(
                  icon: Icons.task_alt_outlined,
                  activeIcon: Icons.task_alt,
                  title: 'Task Manager',
                  route: AppRoutes.taskManager,
                ),
                _navItem(
                  icon: Icons.flight_takeoff_outlined,
                  activeIcon: Icons.flight_takeoff,
                  title: 'Leaves',
                  route: AppRoutes.leaveManagement,
                ),
                _navItem(
                  icon: Icons.badge_outlined,
                  activeIcon: Icons.badge,
                  title: 'Digital Cards',
                  route: AppRoutes.digitalCards,
                ),

                // Sales Section (role gated)
                Obx(() {
                  if (!authService.hasSalesAccess) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionHeader('SALES'),
                      _navItem(
                        icon: Icons.people_outline,
                        activeIcon: Icons.people,
                        title: 'Leads & Contacts',
                        route: AppRoutes.leadsContacts,
                      ),
                      _navItem(
                        icon: Icons.receipt_long_outlined,
                        activeIcon: Icons.receipt_long,
                        title: 'Sales Invoices',
                        route: AppRoutes.salesInvoices,
                      ),
                      _navItem(
                        icon: Icons.track_changes_outlined,
                        activeIcon: Icons.track_changes,
                        title: 'Sales Target',
                        route: AppRoutes.salesTargets,
                      ),
                    ],
                  );
                }),

                // IT Support Section
                _sectionHeader('IT SUPPORT'),
                _navItem(
                  icon: Icons.headset_mic_outlined,
                  activeIcon: Icons.headset_mic,
                  title: 'My Tickets',
                  route: AppRoutes.supportTickets,
                ),

                // Payroll Section
                _sectionHeader('PAYROLL'),
                _navItem(
                  icon: Icons.request_quote_outlined,
                  activeIcon: Icons.request_quote,
                  title: 'My Salary Slips',
                  route: AppRoutes.salarySlips,
                ),
                _navItem(
                  icon: Icons.alt_route_outlined,
                  activeIcon: Icons.alt_route,
                  title: 'My Travel Allowance',
                  route: AppRoutes.travelAllowance,
                ),

                // Messenger Section
                _sectionHeader('COMMUNICATION'),
                _navItem(
                  icon: Icons.chat_bubble_outline,
                  activeIcon: Icons.chat_bubble,
                  title: 'Chat / Messenger',
                  route: AppRoutes.messenger,
                ),
              ],
            ),
          ),

          // Footer - Logout
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.danger),
            title: const Text(
              'Logout',
              style: TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
            onTap: () {
              Get.back(); // close drawer
              _confirmLogout(context, authService);
            },
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required IconData activeIcon,
    required String title,
    required String route,
  }) {
    final isSelected = Get.currentRoute == route;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      child: Material(
        color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          dense: true,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          leading: Icon(
            isSelected ? activeIcon : icon,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            size: 22,
          ),
          title: Text(
            title,
            style: TextStyle(
              color: isSelected ? AppColors.primary : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 14,
            ),
          ),
          onTap: () {
            Get.back(); // Close drawer
            if (Get.currentRoute != route) {
              Get.toNamed(route);
            }
          },
        ),
      ),
    );
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

