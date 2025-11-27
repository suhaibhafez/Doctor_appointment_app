import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static String? get getTheme => _prefs.getString('theme');
  static String? get getToken => _prefs.getString('token');
  static String? get getLang => _prefs.getString('lang');
  static String? get getUserId => _prefs.getString('userId');

  static Future<bool> setLang(String lang) async {
    return await _prefs.setString('lang', lang);
  }

  static Future<bool> setTheme(String theme) async {
    return await _prefs.setString('theme', theme);
  }

  static Future<bool> setToken(String? token) async {
    
    if (token == null || token.isEmpty) return false;

    return await _prefs.setString('token', token);
  }
   static Future<bool> setUserId(String? id) async {
    if (id == null || id.isEmpty) return false;

    return await _prefs.setString('userId', id);
  }
  static Future<bool> clearToken() async => await _prefs.remove('token');
  static Future<bool> clearUserId() async => await _prefs.remove('userId');

}
