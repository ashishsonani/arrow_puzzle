import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:puzzle/screens/app_splash_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('AppSplashScreen renders correctly', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    
    await tester.pumpWidget(
      const MaterialApp(
        home: AppSplashScreen(),
      ),
    );

    expect(find.byType(AppSplashScreen), findsOneWidget);
  });
}
