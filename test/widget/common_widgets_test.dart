import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mbs_attendance_app/core/widgets/custom_button.dart';
import 'package:mbs_attendance_app/core/widgets/status_badge.dart';
import 'package:mbs_attendance_app/core/widgets/empty_state_view.dart';
import 'package:mbs_attendance_app/core/widgets/error_state_view.dart';

void main() {
  group('Common Widget Tests', () {
    testWidgets('CustomButton renders text and responds to tap', (WidgetTester tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Sign In',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Sign In'), findsOneWidget);
      await tester.tap(find.text('Sign In'));
      expect(tapped, true);
    });

    testWidgets('StatusBadge renders correct status text and color', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: StatusBadge(status: 'present'),
          ),
        ),
      );

      expect(find.text('Present'), findsOneWidget);
    });

    testWidgets('EmptyStateView renders title and message', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateView(
              title: 'No Data',
              message: 'Try searching again',
            ),
          ),
        ),
      );

      expect(find.text('No Data'), findsOneWidget);
      expect(find.text('Try searching again'), findsOneWidget);
    });

    testWidgets('ErrorStateView renders error and retry button', (WidgetTester tester) async {
      bool retried = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorStateView(
              error: 'Connection timed out',
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Connection timed out'), findsOneWidget);
      await tester.tap(find.text('Try Again'));
      expect(retried, true);
    });
  });
}

