import 'package:flutter_test/flutter_test.dart';
import 'package:mbs_attendance_app/core/utils/currency_formatter.dart';
import 'package:mbs_attendance_app/core/utils/date_formatter.dart';
import 'package:mbs_attendance_app/core/utils/validators.dart';

void main() {
  group('Utility Tests', () {
    test('CurrencyFormatter formats INR correctly', () {
      expect(CurrencyFormatter.format(50500.0), '₹50,500.00');
      expect(CurrencyFormatter.format('150000'), '₹1,50,000.00');
      expect(CurrencyFormatter.format(0), '₹0.00');
      expect(CurrencyFormatter.formatCompact(500000), '₹5,00,000');
    });

    test('DateFormatter parses dates and times correctly', () {
      expect(DateFormatter.toDisplayDate('2026-10-26'), '26 Oct 2026');
      expect(DateFormatter.formatMonthYear(10, 2026), 'October 2026');
      expect(DateFormatter.toDisplayTime('09:30:00'), '09:30 AM');
      expect(DateFormatter.toDisplayTime('18:45:00'), '06:45 PM');
    });

    test('Validators validate email, password, and URL', () {
      // Email
      expect(Validators.email('test@billing.com'), null);
      expect(Validators.email(''), 'Email is required');
      expect(Validators.email('invalid-email'), 'Please enter a valid email address');

      // Password
      expect(Validators.password('secret123'), null);
      expect(Validators.password(''), 'Password is required');
      expect(Validators.password('12'), 'Password must be at least 3 characters');

      // URL
      expect(Validators.url('https://aavenzaone.aavenzatechnologies.com'), null);
      expect(Validators.url('http://192.168.1.100/accounts'), null);
      expect(Validators.url('not-a-url'), 'Please enter a valid URL starting with http:// or https://');
    });
  });
}

