import 'package:shared_preferences/shared_preferences.dart';

class DemoAuthState {
  static bool isLoggedIn = false;

  static const _keyLoggedIn = 'demo_logged_in';
  static const _keyEmail = 'demo_email';
  static const _keyPassword = 'demo_password';

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    isLoggedIn = prefs.getBool(_keyLoggedIn) ?? false;
    if (isLoggedIn) {
      // load into SignupPage.userData indirectly is handled by login screen when needed
    }
  }

  static Future<void> saveCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyPassword, password);
  }

  static Future<Map<String, String>> getSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final email = prefs.getString(_keyEmail) ?? '';
    final password = prefs.getString(_keyPassword) ?? '';
    return {'email': email, 'password': password};
  }

  static Future<void> signIn({String? email, String? password}) async {
    isLoggedIn = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, true);
    if (email != null && password != null) {
      await saveCredentials(email, password);
    }
  }

  static Future<void> signOut() async {
    isLoggedIn = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, false);
  }
}


