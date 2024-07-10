import 'package:flutter/material.dart';
import 'package:submission_flutter_4/database/auth_repo.dart';
import 'package:submission_flutter_4/model/story.dart';

class StoryProvider extends ChangeNotifier {
  final AuthRepository authRepository;
  final List<Story> _stories = [];
  List<Story> get stories => _stories;
  bool isLoading = false;
  bool isFetchingMore = false;
  String? errorMessage;
  int _page = 1;
  final int _pageSize = 10;
  bool _hasMoreStories = true;

  StoryProvider(this.authRepository);

  Future<void> fetchStories() async {
    isLoading = true;
    errorMessage = null;
    _page = 1;
    _hasMoreStories = true;
    _stories.clear();
    await _fetchStories();
    isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMoreStories() async {
    if (isFetchingMore || !hasMoreStories) return;
    isFetchingMore = true;
    await _fetchStories();
    isFetchingMore = false;
    notifyListeners();
  }

  Future<void> _fetchStories() async {
    try {
      final token = await authRepository.getToken();
      if (token != null) {
        final newStories =
            await authRepository.getStories(token, _page, _pageSize);
        if (newStories.isEmpty) {
          _hasMoreStories = false;
        } else {
          _stories.addAll(newStories);
          _page++;
        }
      } else {
        errorMessage = "Token not found";
      }
    } catch (e) {
      errorMessage = e.toString();
    }
  }

  bool get hasMoreStories => _hasMoreStories;
}
