import 'package:flutter/material.dart';
import 'package:submission_flutter_4/database/auth_repo.dart';
import 'package:submission_flutter_4/model/story.dart';

class StoryProvider extends ChangeNotifier {
  final AuthRepository authRepository;
  List<Story> stories = [];
  bool isLoading = false;

  StoryProvider(this.authRepository);

  Future<void> fetchStories(String token) async {
    isLoading = true;
    notifyListeners();
    stories = await authRepository.getStories(token);
    isLoading = false;
    notifyListeners();
  }
}
