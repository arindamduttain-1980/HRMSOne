import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final String? label;
  final double fontSize;
  final EdgeInsetsGeometry padding;

  const StatusBadge({
    super.key,
    required this.status,
    this.label,
    this.fontSize = 11,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String display = label ?? _formatStatus(status);

    final s = status.toLowerCase().trim();
    if (s == 'present' || s == 'paid' || s == 'won' || s == 'approved' || s == 'done' || s == 'accepted') {
      bg = AppColors.successLight;
      fg = AppColors.success;
    } else if (s == 'half_day' || s == 'pending' || s == 'proposal_sent' || s == 'in_progress' || s == 'negotiation') {
      bg = AppColors.warningLight;
      fg = AppColors.warning;
    } else if (s == 'work_from_home' || s == 'qualified' || s == 'review' || s == 'contacted') {
      bg = AppColors.infoLight;
      fg = AppColors.info;
    } else if (s == 'cancelled' || s == 'lost' || s == 'rejected' || s == 'inactive' || s == 'not_checked_in') {
      bg = AppColors.dangerLight;
      fg = AppColors.danger;
    } else {
      bg = AppColors.border;
      fg = AppColors.textSecondary;
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: fg,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            display,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }

  String _formatStatus(String text) {
    if (text.isEmpty) return 'Unknown';
    return text.split('_').map((w) {
      if (w.isEmpty) return '';
      return w[0].toUpperCase() + w.substring(1);
    }).join(' ');
  }
}

