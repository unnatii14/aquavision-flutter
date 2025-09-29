import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mock User class to simulate Firebase User
class MockUser {
  final String? displayName;
  final String? email;

  MockUser(this.displayName, this.email);
}

class AuthService extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _errorMessage;
  String? _userName;
  String? _userEmail;
  bool _isFirstTime = true;
  bool _hasSeenOnboarding = false;

  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isFirstTime => _isFirstTime;
  bool get hasSeenOnboarding => _hasSeenOnboarding;

  // Mock user object
  MockUser? get user => _isLoggedIn ? MockUser(_userName, _userEmail) : null;

  AuthService() {
    _loadUserSession();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  Future<void> _loadUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool('is_logged_in') ?? false;
    _userName = prefs.getString('user_name');
    _userEmail = prefs.getString('user_email');
    _isFirstTime = prefs.getBool('is_first_time') ?? true;
    _hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _setLoading(true);
      _setError(null);

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Enhanced validation
      if (email.isEmpty || password.isEmpty) {
        _setError('Please fill in all fields');
        return false;
      }

      if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
          .hasMatch(email)) {
        _setError('Please enter a valid email address');
        return false;
      }

      if (password.length < 6) {
        _setError('Password must be at least 6 characters');
        return false;
      }

      // Mock successful login
      _isLoggedIn = true;
      _userEmail = email;
      _userName = email.split('@')[0]; // Use part before @ as name
      _isFirstTime = false;

      await _saveUserSession();
      return true;
    } catch (e) {
      _setError('An unexpected error occurred');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> signUp(String email, String password, String name) async {
    try {
      _setLoading(true);
      _setError(null);

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Enhanced validation
      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        _setError('Please fill in all fields');
        return false;
      }

      if (name.length < 2) {
        _setError('Name must be at least 2 characters');
        return false;
      }

      if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
          .hasMatch(email)) {
        _setError('Please enter a valid email address');
        return false;
      }

      if (password.length < 6) {
        _setError('Password must be at least 6 characters');
        return false;
      }

      // Mock successful signup - don't auto-login
      _isLoggedIn = false; // User needs to login after signup
      _userEmail = null;
      _userName = null;
      _isFirstTime = false; // Mark that they've created an account

      // Save only the first-time status, not login status
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_first_time', false);
      await prefs.setBool('has_seen_onboarding', _hasSeenOnboarding);

      return true;
    } catch (e) {
      _setError('An unexpected error occurred');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      _isLoggedIn = false;
      _userName = null;
      _userEmail = null;
      await _clearUserSession();
      notifyListeners();
    } catch (e) {
      _setError('Error signing out');
    }
  }

  Future<void> _saveUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_logged_in', _isLoggedIn);
    await prefs.setString('user_email', _userEmail ?? '');
    await prefs.setString('user_name', _userName ?? '');
    await prefs.setBool('is_first_time', _isFirstTime);
    await prefs.setBool('has_seen_onboarding', _hasSeenOnboarding);
  }

  Future<void> markOnboardingSeen() async {
    _hasSeenOnboarding = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_onboarding', true);
    notifyListeners();
  }

  Future<void> _clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_logged_in');
    await prefs.remove('user_email');
    await prefs.remove('user_name');
    await prefs.setBool('is_first_time', true);
    await prefs.setBool('has_seen_onboarding', false);
  }

  void clearError() {
    _setError(null);
  }
}
