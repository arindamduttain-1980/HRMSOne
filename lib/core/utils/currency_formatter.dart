import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _inrFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  static final NumberFormat _inrCompactFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );

  static String format(dynamic amount) {
    if (amount == null) return '₹0.00';
    try {
      final val = amount is num ? amount : double.tryParse(amount.toString()) ?? 0.0;
      return _inrFormat.format(val);
    } catch (_) {
      return '₹$amount';
    }
  }

  static String formatCompact(dynamic amount) {
    if (amount == null) return '₹0';
    try {
      final val = amount is num ? amount : double.tryParse(amount.toString()) ?? 0.0;
      return _inrCompactFormat.format(val);
    } catch (_) {
      return '₹$amount';
    }
  }
}

