import 'package:shared_preferences/shared_preferences.dart';
import 'dart:developer' as developer;

class StorageService {
   static const String _accessTokenKey = 'access_token';
  static const String _usernameKey = 'username';
  static const String _phoneKey = 'phone_number';
  static const String _isLoggedInKey = 'is_logged_in';

  // Save login data
  static Future<void> saveLoginData({
    required String accessToken,
    required String username,
    required String phoneNumber,
  }) async {
     developer.log('Saving Access Token: $accessToken');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, accessToken);
    await prefs.setString(_usernameKey, username);
    await prefs.setString(_phoneKey, phoneNumber);
    await prefs.setBool(_isLoggedInKey, true);
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }
  static Future<void> saveAccessToken(String token) async {
    developer.log('Saving Access Token: $token');

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessTokenKey, token);
  }
  // Get stored token
  /// جلب التوكن المحفوظ
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_accessTokenKey);
  }

  // Get stored username
  static Future<String?> getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_usernameKey);
  }

  // Get stored phone number
  static Future<String?> getPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_phoneKey);
  }

  // Get all user data
  static Future<Map<String, String?>> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'token': prefs.getString(_accessTokenKey),
      'username': prefs.getString(_usernameKey),
      'phone_number': prefs.getString(_phoneKey),
    };
  }

  // Clear all login data (logout)
  static Future<void> clearLoginData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_usernameKey);
    await prefs.remove(_phoneKey);
    await prefs.setBool(_isLoggedInKey, false);
  }

  // Update username (if changed in profile)
  static Future<void> updateUsername(String newUsername) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_usernameKey, newUsername);
  }

  // Save user preferences
  static Future<void> saveUserPreferences({
    required String learningPath,
    required String appLanguage,
    String? academicLevel,
    String? tmazightScript,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('learning_path', learningPath);
    await prefs.setString('app_language', appLanguage);
    if (academicLevel != null) {
      await prefs.setString('academic_level', academicLevel);
    }
    if (tmazightScript != null) {
      await prefs.setString('tmazight_script', tmazightScript);
    }
  }

  // Get user preferences
  static Future<Map<String, String?>> getUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'learning_path': prefs.getString('learning_path'),
      'app_language': prefs.getString('app_language'),
      'academic_level': prefs.getString('academic_level'),
      'tmazight_script': prefs.getString('tmazight_script'),
    };
  }

  // Update learning path
  static Future<void> updateLearningPath(String learningPath) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('learning_path', learningPath);
  }

  // Update app language
  static Future<void> updateAppLanguage(String appLanguage) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', appLanguage);
  }

  // Save gender
  static Future<void> saveGender(String gender) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gender', gender);
  }

  // Get gender
  static Future<String?> getGender() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('gender');
  }
} 