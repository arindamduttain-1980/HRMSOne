import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/error_state_view.dart';
import '../../../data/models/card_data_model.dart';
import '../controllers/card_controller.dart';

class DigitalCardsView extends GetView<CardController> {
  const DigitalCardsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9), // Web background
      appBar: AppBar(
        backgroundColor: AppColors.navyDark, // Web navy header
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.badge_outlined, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
              'Digital Cards',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: 'Refresh',
            onPressed: controller.loadCardData,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.cardData.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty && controller.cardData.value == null) {
          return ErrorStateView(
            error: controller.errorMessage.value,
            onRetry: controller.loadCardData,
          );
        }

        final data = controller.cardData.value;
        if (data == null) {
          return const Center(child: Text('No card information found.'));
        }

        return RefreshIndicator(
          onRefresh: controller.loadCardData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              children: [
                // Top Segmented Tab: [ID Card] | [Visiting Card]
                _buildTabSelector(),
                const SizedBox(height: 20),

                // Card Pane Presentation
                if (controller.selectedTab.value == 'id')
                  _buildIdCardPane(context, data)
                else
                  _buildVisitingCardPane(context, data),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      }),
    );
  }

  /// Top tabs matching web .card-tabs
  Widget _buildTabSelector() {
    return Obx(() {
      final isId = controller.selectedTab.value == 'id';

      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Row(
          children: [
            // ID Card Tab
            Expanded(
              child: InkWell(
                onTap: () => controller.switchTab('id'),
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(12)),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isId ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.badge_outlined,
                        size: 16,
                        color: isId ? Colors.white : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'ID Card',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                          color: isId ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Visiting Card Tab
            Expanded(
              child: InkWell(
                onTap: () => controller.switchTab('visiting'),
                borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: !isId ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.contact_mail_outlined,
                        size: 16,
                        color: !isId ? Colors.white : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Visiting Card',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13.5,
                          color: !isId ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ─────────────────────────────────────────────────────────────
  // ID CARD PANE (Image 2)
  // ─────────────────────────────────────────────────────────────

  Widget _buildIdCardPane(BuildContext context, DigitalCardDataModel data) {
    final emp = data.employee;
    final comp = data.company;
    final initials = controller.getInitials(emp.name);
    final officePhone = comp.phone?.trim() ?? '';
    final showSafety = (emp.bloodGroup != null && emp.bloodGroup!.isNotEmpty) ||
        (emp.emergencyContact != null && emp.emergencyContact!.isNotEmpty) ||
        officePhone.isNotEmpty;

    String joinedStr = emp.joinDate ?? '';
    if (joinedStr.isNotEmpty) {
      try {
        final dt = DateTime.parse(joinedStr);
        joinedStr = DateFormat('d MMM yyyy').format(dt);
      } catch (_) {}
    }

    return Column(
      children: [
        // 1. Physical Badge Layout wrapped in RepaintBoundary for PNG export
        RepaintBoundary(
          key: controller.idCardKey,
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 340),
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.border, width: 1.5),
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
                // Lanyard Clip Notch
                Container(
                  width: 48,
                  height: 6,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 14),

                // Company Header Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (comp.logoUrl != null && comp.logoUrl!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Image.network(
                          comp.logoUrl!,
                          width: 22,
                          height: 22,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.business,
                            size: 18,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      )
                    else
                      const Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Icon(Icons.business, size: 18, color: AppColors.textSecondary),
                      ),
                    Flexible(
                      child: Text(
                        comp.name.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Employee Avatar
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A56DB),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1A56DB).withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: (emp.photoUrl != null && emp.photoUrl!.isNotEmpty)
                        ? Image.network(
                            emp.photoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(
                                initials,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              initials,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 14),

                // Employee Name
                Text(
                  emp.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),

                // Designation
                Text(
                  emp.designation,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),

                // Department
                if (emp.department != null && emp.department!.isNotEmpty) ...[
                  const SizedBox(height: 1),
                  Text(
                    emp.department!,
                    style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 12),

                // Divider
                const Divider(color: Color(0xFFE2E8F0), height: 1),
                const SizedBox(height: 10),

                // ID No. & Joined Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    if (emp.empCode.isNotEmpty)
                      Column(
                        children: [
                          const Text(
                            'ID NO.',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            emp.empCode,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    if (joinedStr.isNotEmpty)
                      Column(
                        children: [
                          const Text(
                            'JOINED',
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            joinedStr,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                // Safety / Office line box
                if (showSafety) ...[
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF1F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFECDD3)),
                    ),
                    child: Column(
                      children: [
                        if (officePhone.isNotEmpty)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.apartment, size: 14, color: Color(0xFF991B1B)),
                              const SizedBox(width: 6),
                              Text(
                                'Office: $officePhone',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF991B1B),
                                ),
                              ),
                            ],
                          ),
                        if (emp.emergencyContact != null && emp.emergencyContact!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.phone_in_talk, size: 13, color: Color(0xFF991B1B)),
                              const SizedBox(width: 6),
                              Text(
                                'Emergency: ${emp.emergencyContact!}${emp.emergencyName != null && emp.emergencyName!.isNotEmpty ? " (${emp.emergencyName!})" : ""}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF991B1B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 14),

                // Centered QR Code
                QrImageView(
                  data: (emp.shareUrl != null && emp.shareUrl!.isNotEmpty)
                      ? emp.shareUrl!
                      : (emp.empCode.isNotEmpty ? emp.empCode : 'AAVENZA-ID'),
                  version: QrVersions.auto,
                  size: 88.0,
                  backgroundColor: Colors.white,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Color(0xFF0A1628),
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Color(0xFF0A1628),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 2. Action Buttons: [Download] and [Share] (Image 2)
        _buildActionButtons(mode: 'id'),
        const SizedBox(height: 20),

        // 3. Safety Details Form (Image 2)
        Container(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'BLOOD GROUP',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Obx(() => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border, width: 1.5),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: controller.selectedBloodGroup.value,
                        isExpanded: true,
                        icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondary),
                        items: controller.bloodGroups.map((bg) {
                          return DropdownMenuItem<String>(
                            value: bg,
                            child: Text(
                              bg,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) controller.selectedBloodGroup.value = val;
                        },
                      ),
                    ),
                  )),
              const SizedBox(height: 12),

              const Text(
                'EMERGENCY CONTACT NAME',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: controller.emergencyNameController,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'e.g. Spouse / Parent name',
                  hintStyle: const TextStyle(fontSize: 14, color: AppColors.textMuted),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              const Text(
                'EMERGENCY CONTACT NUMBER',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: controller.emergencyPhoneController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'e.g. 9876543210',
                  hintStyle: const TextStyle(fontSize: 14, color: AppColors.textMuted),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Save ID Card Details Button
              ElevatedButton(
                onPressed: controller.updateSafetyDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0891B2), // Web blue
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check, size: 18, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      'Save ID Card Details',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // VISITING CARD PANE (Image 1)
  // ─────────────────────────────────────────────────────────────

  Widget _buildVisitingCardPane(BuildContext context, DigitalCardDataModel data) {
    final emp = data.employee;
    final comp = data.company;
    final initials = controller.getInitials(emp.name);

    return Column(
      children: [
        // 1. Digital Visiting Card wrapped in RepaintBoundary for PNG export
        RepaintBoundary(
          key: controller.visitingCardKey,
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 340),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0A1628), // Navy
                  Color(0xFF1E3A5F), // Navy Mid
                  Color(0xFF1A56DB), // Vibrant Blue
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Company Header Row
                Row(
                  children: [
                    if (comp.logoUrl != null && comp.logoUrl!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Image.network(
                          comp.logoUrl!,
                          width: 20,
                          height: 20,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.business,
                            size: 16,
                            color: Colors.white70,
                          ),
                        ),
                      )
                    else
                      const Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: Icon(Icons.business, size: 16, color: Colors.white70),
                      ),
                    Expanded(
                      child: Text(
                        comp.name.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Avatar Circle
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.35), width: 1.5),
                  ),
                  child: ClipOval(
                    child: (emp.photoUrl != null && emp.photoUrl!.isNotEmpty)
                        ? Image.network(
                            emp.photoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Text(
                                initials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: Text(
                              initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 14),

                // Name
                Text(
                  emp.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),

                // Role / Dept
                Text(
                  '${emp.designation}${emp.department != null && emp.department!.isNotEmpty ? " - ${emp.department!}" : ""}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                // Tagline if set
                if (emp.tagline != null && emp.tagline!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    '"${emp.tagline}"',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 11.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
                const SizedBox(height: 16),

                // Contacts: Phone & Email
                if (emp.phone != null && emp.phone!.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.phone, size: 14, color: Colors.white.withOpacity(0.7)),
                      const SizedBox(width: 8),
                      Text(
                        emp.phone!,
                        style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],
                if (emp.email != null && emp.email!.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(Icons.mail, size: 14, color: Colors.white.withOpacity(0.7)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          emp.email!,
                          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],

                // Address Line
                if (comp.address != null && comp.address!.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Divider(color: Colors.white.withOpacity(0.18), height: 1),
                  const SizedBox(height: 10),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on, size: 14, color: Colors.white.withOpacity(0.65)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          comp.address!,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.75),
                            fontSize: 11,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // 2. Action Buttons: [Download] and [Share] (Image 1)
        _buildActionButtons(mode: 'visiting'),
        const SizedBox(height: 20),

        // 3. Tagline Form Section (Image 1)
        Container(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Text(
                    'TAGLINE ',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    '(shown on your visiting card)',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              TextField(
                controller: controller.taglineController,
                maxLength: 150,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: 'e.g. Building growth through smart solutions',
                  hintStyle: const TextStyle(fontSize: 14, color: AppColors.textMuted),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border, width: 1.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border, width: 1.5),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Save Tagline Button
              ElevatedButton(
                onPressed: controller.updateTagline,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0891B2), // Web blue
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check, size: 18, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      'Save Tagline',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Copy Link Row (Image 1)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 1.5),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        (emp.shareUrl != null && emp.shareUrl!.isNotEmpty)
                            ? emp.shareUrl!
                            : 'https://aavenzaone.aavenzatechnologies.com/card/...',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: controller.copyCardLink,
                      child: const Text(
                        'Copy',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Action Buttons: [Download] and [Share] (Both Cards)
  // ─────────────────────────────────────────────────────────────

  Widget _buildActionButtons({required String mode}) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 340),
      child: Row(
        children: [
          // Download Button
          Expanded(
            child: InkWell(
              onTap: () => controller.downloadCard(mode),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border, width: 1.5),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.download, size: 16, color: AppColors.textPrimary),
                    SizedBox(width: 6),
                    Text(
                      'Download',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Share Button
          Expanded(
            child: InkWell(
              onTap: () => controller.shareCard(mode),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0891B2), // Web cyan/blue share button
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.share, size: 16, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      'Share',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
