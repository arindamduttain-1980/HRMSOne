import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/error_state_view.dart';
import '../../../core/widgets/status_badge.dart';
import '../../../data/models/sales_invoice_model.dart';
import '../controllers/sales_invoice_controller.dart';

class SalesInvoicesView extends GetView<SalesInvoiceController> {
  const SalesInvoicesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales Invoices'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.loadInvoices,
          ),
        ],
      ),
      body: Column(
        children: [
          // Month Selector Filter
          Obx(() {
            if (controller.availableMonths.isEmpty) {
              return const SizedBox.shrink();
            }
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.white,
              child: Row(
                children: [
                  const Icon(Icons.filter_list, size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  const Text('Billing Month: ', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 8),
                  DropdownButton<String>(
                    value: '${controller.selectedYear.value}-${controller.selectedMonth.value}',
                    underline: const SizedBox.shrink(),
                    items: controller.availableMonths.map((m) {
                      final val = '${m["year"]}-${m["month"]}';
                      final label = DateFormatter.formatMonthYear(m['month']!, m['year']!);
                      return DropdownMenuItem(value: val, child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        final parts = val.split('-');
                        controller.selectedYear.value = int.parse(parts[0]);
                        controller.selectedMonth.value = int.parse(parts[1]);
                        controller.loadInvoices();
                      }
                    },
                  ),
                ],
              ),
            );
          }),
          const Divider(height: 1),

          // Invoices List
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.errorMessage.isNotEmpty) {
                return ErrorStateView(
                  error: controller.errorMessage.value,
                  onRetry: controller.loadInvoices,
                );
              }

              if (controller.invoices.isEmpty) {
                return const EmptyStateView(
                  icon: Icons.receipt_long_outlined,
                  title: 'No Invoices Found',
                  message: 'No sales invoices generated for this period.',
                );
              }

              return RefreshIndicator(
                onRefresh: controller.loadInvoices,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: controller.invoices.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (ctx, i) {
                    final invoice = controller.invoices[i];
                    return _buildInvoiceCard(context, invoice);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceCard(BuildContext context, SalesInvoiceSummaryModel invoice) {
    return InkWell(
      onTap: () {
        controller.loadInvoiceDetail(invoice.id);
        Get.toNamed(AppRoutes.salesInvoiceDetail);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
                  invoice.invoiceNo,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
                StatusBadge(status: invoice.paymentStatus),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              invoice.customerName,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            if (invoice.customerCompany != null && invoice.customerCompany!.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                invoice.customerCompany!,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Date: ${DateFormatter.toDisplayDate(invoice.invoiceDate)}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                Text(
                  CurrencyFormatter.format(invoice.grandTotal),
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
