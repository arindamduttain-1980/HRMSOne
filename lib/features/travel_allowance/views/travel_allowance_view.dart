import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_state_view.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/travel_claim_model.dart';
import '../controllers/travel_controller.dart';

class TravelAllowanceView extends GetView<TravelController> {
  const TravelAllowanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Travel Allowance'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadClaims,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () {
          controller.openApplyModal();
          _showClaimModal(context);
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.isNotEmpty) {
          return ErrorStateView(
            error: controller.errorMessage.value,
            onRetry: controller.loadClaims,
          );
        }

        if (controller.claims.isEmpty) {
          return EmptyStateView(
            icon: Icons.alt_route_outlined,
            title: 'No Travel Claims',
            message:
                'Tap the + button to file local or outstation travel claims.',
            buttonText: 'Submit Claim',
            onButtonPressed: () {
              controller.openApplyModal();
              _showClaimModal(context);
            },
          );
        }

        return RefreshIndicator(
          onRefresh: controller.loadClaims,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: controller.claims.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (ctx, i) {
              final claim = controller.claims[i];
              return _buildClaimCard(context, claim);
            },
          ),
        );
      }),
    );
  }

  Widget _buildClaimCard(BuildContext context, TravelClaimModel claim) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${claim.fromPlace} → ${claim.toPlace}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              StatusBadge(status: claim.status),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            claim.purpose,
            style:
                const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  claim.mode.replaceAll('_', ' ').toUpperCase(),
                  style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                DateFormatter.toDisplayDate(claim.travelDate),
                style:
                    const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
              const Spacer(),
              Text(
                CurrencyFormatter.format(claim.totalAmount),
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppColors.success),
              ),
            ],
          ),
          if (claim.isPending) ...[
            const Divider(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => controller.cancelClaim(claim.id),
                icon:
                    const Icon(Icons.close, size: 14, color: AppColors.danger),
                label: const Text('Cancel Claim',
                    style: TextStyle(
                        fontSize: 12,
                        color: AppColors.danger,
                        fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showClaimModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          top: 24,
          left: 20,
          right: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom +
              MediaQuery.of(ctx).padding.bottom +
              20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('New Travel Claim', style: AppTextStyles.h3),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // From & To Places
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.fromPlaceController,
                      decoration: InputDecoration(
                        labelText: 'From Place',
                        hintText: 'e.g. Noida',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: controller.toPlaceController,
                      decoration: InputDecoration(
                        labelText: 'To Place',
                        hintText: 'e.g. Gurugram',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextField(
                controller: controller.purposeController,
                decoration: InputDecoration(
                  labelText: 'Purpose',
                  hintText: 'e.g. Client meeting with Sunrise Logistics',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),

              // Travel Type (single line full width)
              Obx(() => DropdownButtonFormField<String>(
                    value: controller.travelType.value,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Travel Type',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    items: controller.travelTypes.map((t) {
                      return DropdownMenuItem(
                        value: t,
                        child: Text(t.capitalizeFirst!,
                            style: const TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) controller.travelType.value = val;
                    },
                  )),
              const SizedBox(height: 12),

              // Travel Mode (single line full width)
              Obx(() => DropdownButtonFormField<String>(
                    value: controller.travelMode.value,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Travel Mode',
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    items: controller.travelModes.map((m) {
                      return DropdownMenuItem(
                        value: m,
                        child: Text(
                          m.replaceAll('_', ' ').capitalizeFirst!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) controller.travelMode.value = val;
                    },
                  )),
              const SizedBox(height: 12),

              // Distance & Ticket
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.distanceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Distance (KM)',
                        hintText: 'e.g. 45',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: controller.ticketExpenseController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Ticket / Tolls (₹)',
                        hintText: '0.00',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: controller.applyClaim,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Submit Claim',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
