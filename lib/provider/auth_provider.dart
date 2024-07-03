import 'package:flutter/material.dart';
import 'package:submission_flutter_4/database/auth_repo.dart';
import 'package:submission_flutter_4/model/story.dart';
import 'package:submission_flutter_4/model/user.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository authRepository;

  AuthProvider(this.authRepository);

  bool isLoadingLogin = false;
  bool isLoadingLogout = false;
  bool isLoadingRegister = false;
  bool isLoggedIn = false;
  String? errorMessage;
  String? token;

  Future<bool> login(User user) async {
    isLoadingLogin = true;
    notifyListeners();
    final result = await authRepository.login(user);
    isLoggedIn = result['success'];
    isLoadingLogin = false;
    token = result['token'];
    if (!isLoggedIn) {
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
      await authRepository.deleteUser();
    }
    isLoggedIn = await authRepository.isLoggedIn();
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

  Future<List<Story>> getStories() async {
    if (token == null) {
      return [];
    }
    return await authRepository.getStories(token!);
  }
}
