import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:submission_flutter_4/database/auth_repo.dart';
import 'package:submission_flutter_4/model/story.dart';
import 'package:submission_flutter_4/model/user.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository authRepository;

  AuthProvider(this.authRepository) {
    _loadLoginState();
  }

  bool isLoadingLogin = false;
  bool isLoadingLogout = false;
  bool isLoadingRegister = false;
  bool isLoggedIn = false;
  String? errorMessage;
  String? token;

  Future<void> _loadLoginState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    token = prefs.getString('token');
    notifyListeners();
  }

  Future<bool> login(User user) async {
    isLoadingLogin = true;
    notifyListeners();
    final result = await authRepository.login(user);
    isLoggedIn = result['success'];
    isLoadingLogin = false;
    if (isLoggedIn) {
      token = result['token'];
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('token', token!);
    } else {
      errorMessage = result['message'];
    }
    notifyListeners();
    return isLoggedIn;
  }

  Future<bool> logout() async {
    isLoadingLogout = true;
    notifyListeners();
    final logout = await authRepository.logout();
    if (logout) {
      final preferences = await SharedPreferences.getInstance();
      await preferences.remove('token');
      await preferences.setBool('isLoggedIn', false);
    }
    isLoggedIn = false;
    isLoadingLogout = false;
    notifyListeners();
    return !isLoggedIn;
  }

  Future<bool> saveUser(User user) async {
    isLoadingRegister = true;
    notifyListeners();
    final result = await authRepository.register(user);
    isLoadingRegister = false;
    final isSuccess = result['success'];
    if (!isSuccess) {
      errorMessage = result['message'];
    }
    notifyListeners();
    return isSuccess;
  }

  Future<List<Story>> getStories(int page, int pageSize) async {
    if (token == null) {
      return [];
    }
    return await authRepository.getStories(token!, page, pageSize);
  }
}
