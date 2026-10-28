import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../../data/models/user_model.dart';

class StorageService extends GetxService {
  late SharedPreferences _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // Server URL
  String get serverUrl => _prefs.getString(ApiConstants.keyServerUrl) ?? ApiConstants.defaultServerUrl;

  Future<bool> setServerUrl(String url) async {
    var formatted = url.trim();
    if (formatted.endsWith('/')) {
      formatted = formatted.substring(0, formatted.length - 1);
    }
    return await _prefs.setString(ApiConstants.keyServerUrl, formatted);
  }

  // Token
  String? get token => _prefs.getString(ApiConstants.keyToken);

  bool get hasToken => token != null && token!.isNotEmpty;

  Future<bool> setToken(String token) async {
    return await _prefs.setString(ApiConstants.keyToken, token);
  }

  Future<bool> clearToken() async {
    return await _prefs.remove(ApiConstants.keyToken);
  }

  // User
  UserModel? get user {
    final str = _prefs.getString(ApiConstants.keyUser);
    if (str == null || str.isEmpty) return null;
    try {
      final json = jsonDecode(str);
      return UserModel.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<bool> setUser(UserModel user) async {
    return await _prefs.setString(ApiConstants.keyUser, jsonEncode(user.toJson()));
  }

  Future<bool> clearUser() async {
    return await _prefs.remove(ApiConstants.keyUser);
  }

  // Remember Email
  String? get rememberEmail => _prefs.getString(ApiConstants.keyRememberEmail);

  Future<bool> setRememberEmail(String email) async {
    return await _prefs.setString(ApiConstants.keyRememberEmail, email);
  }

  // Clear Session
  Future<void> clearSession() async {
    await clearToken();
    await clearUser();
  }
}

