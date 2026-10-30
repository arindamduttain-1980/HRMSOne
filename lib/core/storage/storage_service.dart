import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_constants.dart';
import '../../data/models/company_model.dart';
import '../../data/models/user_model.dart';

class StorageService extends GetxService {
  late SharedPreferences _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // Company and Server URL
  String get serverUrl => _prefs.getString(ApiConstants.keyServerUrl) ?? ApiConstants.defaultServerUrl;

  Future<bool> setServerUrl(String url) async {
    var formatted = url.trim();
    if (formatted.endsWith('/')) {
      formatted = formatted.substring(0, formatted.length - 1);
    }
    return await _prefs.setString(ApiConstants.keyServerUrl, formatted);
  }

  // Selected Company
  CompanyModel? get selectedCompany {
    final str = _prefs.getString(ApiConstants.keySelectedCompany);
    if (str == null || str.isEmpty) return null;
    try {
      final json = jsonDecode(str);
      return CompanyModel.fromJson(json as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<bool> setSelectedCompany(CompanyModel company) async {
    await setServerUrl(company.baseUrl);
    return await _prefs.setString(
      ApiConstants.keySelectedCompany,
      jsonEncode(company.toJson()),
    );
  }

  // Cached Company List
  List<CompanyModel> get cachedCompanyList {
    final str = _prefs.getString(ApiConstants.keyCompanyList);
    if (str == null || str.isEmpty) return [];
    try {
      final list = jsonDecode(str);
      if (list is List) {
        return list
            .whereType<Map<String, dynamic>>()
            .map((item) => CompanyModel.fromJson(item))
            .toList();
      }
    } catch (_) {}
    return [];
  }

  Future<bool> setCachedCompanyList(List<CompanyModel> list) async {
    final encoded = jsonEncode(list.map((e) => e.toJson()).toList());
    return await _prefs.setString(ApiConstants.keyCompanyList, encoded);
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

