import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../controllers/salary_controller.dart';

class SalarySlipDetailView extends GetView<SalaryController> {
  const SalarySlipDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Salary Payslip'),
      ),
      body: Obx(() {
        if (controller.isDetailLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final slip = controller.selectedSlipDetail.value;
        if (slip == null) {
          return const Center(child: Text('Payslip details could not be loaded.'));
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: AppColors.navyGradient,
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormatter.formatMonthYear(slip.month, slip.year).toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Colors.white.withOpacity(0.7),
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      slip.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${slip.empCode}  •  ${slip.designation}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Net Pay Highlight Banner
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.successLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.success.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Net Salary Payable',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.success,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(slip.netSalary),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Earnings Breakdown Table
              _buildSectionTitle('EARNINGS & ALLOWANCES'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _breakdownRow('Basic Salary', CurrencyFormatter.format(slip.basicSalary)),
                    const Divider(height: 1),
                    _breakdownRow('House Rent Allowance (HRA)', CurrencyFormatter.format(slip.hra)),
                    const Divider(height: 1),
                    _breakdownRow('Special Allowance', CurrencyFormatter.format(slip.specialAllowance)),
                    const Divider(height: 1),
                    _breakdownRow('Gross Salary', CurrencyFormatter.format(slip.grossSalary), isBold: true),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Deductions Breakdown Table
              _buildSectionTitle('DEDUCTIONS & TAXES'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  children: [
                    _breakdownRow('Provident Fund (PF)', CurrencyFormatter.format(slip.pfEmployee)),
                    const Divider(height: 1),
                    _breakdownRow('ESI Contribution', CurrencyFormatter.format(slip.esiEmployee)),
                    const Divider(height: 1),
                    _breakdownRow('Professional Tax (PT)', CurrencyFormatter.format(slip.professionalTax)),
                    const Divider(height: 1),
                    _breakdownRow('TDS (Income Tax)', CurrencyFormatter.format(slip.tds)),
                    const Divider(height: 1),
                    _breakdownRow('Total Deductions', CurrencyFormatter.format(slip.totalDeductions), isBold: true, isDanger: true),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Bank & Payment Details
              if (slip.bankName != null || slip.bankAccount != null) ...[
                _buildSectionTitle('DISBURSEMENT ACCOUNT'),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    children: [
                      _infoRow('Bank Name', slip.bankName ?? '--'),
                      const SizedBox(height: 8),
                      _infoRow('Account Number', slip.bankAccount != null ? '•••• •••• ${slip.bankAccount!.length > 4 ? slip.bankAccount!.substring(slip.bankAccount!.length - 4) : slip.bankAccount}' : '--'),
                      const SizedBox(height: 8),
                      _infoRow('IFSC Code', slip.bankIfsc ?? '--'),
                      if (slip.pan != null) ...[
                        const SizedBox(height: 8),
                        _infoRow('PAN', slip.pan!),
                      ],
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: AppColors.textSecondary,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _breakdownRow(String label, String value, {bool isBold = false, bool isDanger = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w500,
              color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
              color: isDanger ? AppColors.danger : (isBold ? AppColors.textPrimary : AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ],
    );
  }
}
