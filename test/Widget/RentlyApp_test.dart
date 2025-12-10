import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:p2/rently_app.dart';

void main() {

  testWidgets('Splash screen navigates to login after 3 sec',
      (WidgetTester tester) async {
        
    await tester.pumpWidget(
      MaterialApp(
        home: const RentlyApp(),
        routes: {
          '/login': (context) => const Scaffold(
                body: Center(child: Text('Login Page')),
              ),
        },
      ),
    );

    expect(find.text('Rently'), findsOneWidget);
    expect(find.byIcon(Icons.diamond), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));

    await tester.pumpAndSettle();

    
    expect(find.text('Login Page'), findsOneWidget);
  });
}
