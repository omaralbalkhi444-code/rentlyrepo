import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2/create_account_page.dart';
import 'package:p2/app_locale.dart';

void main() {
  setUp(() {
    AppLocale.locale.value = const Locale("en");
  });
// 1 
  testWidgets("CreateAccountPage UI loads", (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CreateAccountPage()),
    );

    expect(find.text("Rently"), findsOneWidget);
    expect(find.text("create_account"), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));

    expect(find.text("continue"), findsOneWidget);
  });
// 2

  testWidgets("Show validation errors when fields are empty",
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CreateAccountPage()),
    );

    await tester.tap(find.text("continue"));
    await tester.pump();

    expect(find.text("Please enter your email"), findsOneWidget);
    expect(find.text("Please enter your password"), findsOneWidget);
  });

// 3  in valid email

  testWidgets("Invalid email format shows error", (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CreateAccountPage()),
    );

    await tester.enterText(
        find.byType(TextFormField).first, "wrongEmail");
    await tester.enterText(
        find.byType(TextFormField).last, "123456");

    await tester.tap(find.text("continue"));
    await tester.pump();

    expect(find.text("Invalid email address"), findsOneWidget);
  });

// 4 
  testWidgets("Password shorter than 6 chars shows error",
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CreateAccountPage()),
    );

    await tester.enterText(
        find.byType(TextFormField).first, "test@gmail.com");
    await tester.enterText(
        find.byType(TextFormField).last, "123");

    await tester.tap(find.text("continue"));
    await tester.pump();

    expect(find.text("Password must be at least 6 characters"),
        findsOneWidget);
  });

// 5 
  testWidgets("Password visibility toggle works", (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: CreateAccountPage()),
    );

    expect(find.byIcon(Icons.visibility_off), findsOneWidget);

    await tester.tap(find.byIcon(Icons.visibility_off));
    await tester.pump();

    expect(find.byIcon(Icons.visibility), findsOneWidget);
  });
// 6

  testWidgets("Navigate to Login screen when clicking 'login'",
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: const CreateAccountPage(),
        routes: {
          '/login': (_) => const Scaffold(
                body: Center(
                  child: Text("Login Page"),
                ),
              ),
        },
      ),
    );

    await tester.tap(find.text("login"));
    await tester.pumpAndSettle();

    expect(find.text("Login Page"), findsOneWidget);
  });
}
