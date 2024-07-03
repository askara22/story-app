import 'package:flutter/material.dart';
import 'package:submission_flutter_4/database/auth_repo.dart';
import 'package:submission_flutter_4/model/story.dart';

class StoryProvider extends ChangeNotifier {
  final AuthRepository authRepository;
  List<Story> _stories = [];
  List<Story> get stories => _stories;
  bool isLoading = false;
  String? errorMessage;

  StoryProvider(this.authRepository);

  Future<void> fetchStories() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final token = await authRepository.getToken();
      if (token != null) {
        _stories = await authRepository.getStories(token);
      } else {
        errorMessage = "Token not found";
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
