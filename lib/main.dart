import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'src/services/auth_service.dart';
import 'src/services/api_service.dart';
import 'src/pages/splash_screen.dart';
import 'src/pages/onboarding_screen.dart';
import 'src/pages/auth/login_screen.dart';
import 'src/pages/auth/signup_screen.dart';
import 'src/pages/home/fish_classifier_screen.dart';
import 'src/pages/home/navigation_screen.dart';
import 'src/constants/app_constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AquaVisionApp());
}

class AquaVisionApp extends StatelessWidget {
  const AquaVisionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => ApiService()),
      ],
      child: MaterialApp(
        title: '${AppConstants.appName} - Fish Classifier',
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFF0D47A1), // Deep ocean blue
            secondary: Color(0xFF1976D2), // Medium ocean blue
            surface: Color(0xFF0A1929), // Dark blue surface
            background: Color(0xFF061621), // Deep ocean background
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: Color(0xFFE3F2FD),
            onBackground: Color(0xFFE3F2FD),
            tertiary: Color(0xFF00BCD4), // Cyan accent like fish highlights
            outline: Color(0xFF1E88E5),
          ),
          scaffoldBackgroundColor: const Color(0xFF061621),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF0A1929),
            foregroundColor: Colors.white,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            shadowColor: Color(0x30000000),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1976D2),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 8,
              shadowColor: Color(0x401976D2),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF1E88E5)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF1E88E5)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF00BCD4), width: 2),
            ),
            filled: true,
            fillColor: const Color(0xFF0A1929),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          cardTheme: const CardThemeData(
            elevation: 12,
            color: Color(0xFF0A1929),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            shadowColor: Color(0x501976D2),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF0A1929),
            selectedItemColor: Color(0xFF00BCD4),
            unselectedItemColor: Color(0xFF64B5F6),
            elevation: 12,
            type: BottomNavigationBarType.fixed,
          ),
          textTheme: const TextTheme(
            headlineLarge:
                TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            headlineMedium: TextStyle(
                color: Color(0xFFE3F2FD), fontWeight: FontWeight.w600),
            bodyLarge: TextStyle(color: Color(0xFFE3F2FD)),
            bodyMedium: TextStyle(color: Color(0xFFBBDEFB)),
            labelLarge:
                TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(
            backgroundColor: Color(0xFF1976D2),
            foregroundColor: Colors.white,
            elevation: 12,
          ),
        ),
        home: const SplashScreen(),
        routes: {
          '/onboarding': (context) => const OnboardingScreen(),
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/home': (context) => const NavigationScreen(),
          '/fish-classifier': (context) => const FishClassifierScreen(),
        },
      ),
    );
  }
}
