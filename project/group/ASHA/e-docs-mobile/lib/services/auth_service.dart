import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService;
  User? _currentUser;

  AuthService(this._apiService);

  User? get currentUser => _currentUser;
  ApiService get apiService => _apiService;

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userJson = prefs.getString('user');

    if (token != null && userJson != null) {
      _apiService.setToken(token);
      _currentUser = User.fromJson(jsonDecode(userJson));
    }
  }

  Future<Map<String, dynamic>> login(String username, String password) async {
    final result = await _apiService.login(username, password);

    if (result['success']) {
      _currentUser = result['user'];
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', result['token']);
      await prefs.setString('user', jsonEncode(_currentUser!.toJson()));
    }

    return result;
  }

  Future<void> logout() async {
    _currentUser = null;
    _apiService.clearToken();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }

  bool isLoggedIn() {
    return _currentUser != null;
  }

  bool isAdmin() {
    return _currentUser?.isAdmin ?? false;
  }
}
