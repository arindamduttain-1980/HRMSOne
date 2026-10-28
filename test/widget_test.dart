import 'package:flutter_test/flutter_test.dart';
import 'package:mbs_attendance_app/core/constants/app_strings.dart';
import 'package:mbs_attendance_app/core/widgets/custom_button.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('App branding and button smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              children: [
                const Text(AppStrings.appName),
                CustomButton(
                  text: AppStrings.signIn,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(find.text(AppStrings.appName), findsOneWidget);
    expect(find.text(AppStrings.signIn), findsOneWidget);
  });
}
