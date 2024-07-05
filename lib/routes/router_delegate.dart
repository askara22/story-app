import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:submission_flutter_4/database/auth_repo.dart';
import 'package:submission_flutter_4/screen/login_screen.dart';
import 'package:submission_flutter_4/screen/new_story_screen.dart';
import 'package:submission_flutter_4/screen/register_screen.dart';
import 'package:submission_flutter_4/screen/splash_screen.dart';
import 'package:submission_flutter_4/screen/story_detail_screen.dart';
import 'package:submission_flutter_4/screen/story_list_screen.dart';

class MyRouterDelegate extends RouterDelegate
    with ChangeNotifier, PopNavigatorRouterDelegateMixin {
  final GlobalKey<NavigatorState> _navigatorKey;
  final AuthRepository authRepository;

  MyRouterDelegate(this.authRepository)
      : _navigatorKey = GlobalKey<NavigatorState>() {
    _init();
  }

  @override
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  String? selectedStoryId;

  List<Page> historyStack = [];
  bool? isLoggedIn;
  bool isRegister = false;
  bool isNewStory = false;

  void onLogin() {
    isLoggedIn = true;
    notifyListeners();
  }

  void onLogout() {
    isLoggedIn = false;
    notifyListeners();
  }

  void onSelectStory(String storyId) {
    selectedStoryId = storyId;
    notifyListeners();
  }

  _init() async {
    final preferences = await SharedPreferences.getInstance();
    isLoggedIn = preferences.getBool('isLoggedIn') ?? false;
    authRepository.token = preferences.getString('token');
    notifyListeners();
  }

  List<Page> get _splashStack => const [
        MaterialPage(
          key: ValueKey("SplashPage"),
          child: SplashScreen(),
        ),
      ];

  List<Page> get _loggedOutStack => [
        MaterialPage(
          key: const ValueKey("LoginPage"),
          child: LoginScreen(
            onLogin: () {
              onLogin();
            },
            onRegister: () {
              isRegister = true;
              notifyListeners();
            },
          ),
        ),
        if (isRegister == true)
          MaterialPage(
            key: const ValueKey("RegisterPage"),
            child: RegisterScreen(
              onRegister: () {
                isRegister = false;
                notifyListeners();
              },
              onLogin: () {
                isRegister = false;
                notifyListeners();
              },
            ),
          ),
      ];
  List<Page> get _loggedInStack => [
        MaterialPage(
          key: const ValueKey("StoryListPage"),
          child: StoryListScreen(
            onLogout: () {
              onLogout();
            },
            onStorySelected: (storyId) {
              onSelectStory(storyId);
            },
            toNewStory: () {
              isNewStory = true;
              notifyListeners();
            },
          ),
        ),
        if (selectedStoryId != null)
          MaterialPage(
            key: ValueKey(selectedStoryId),
            child: StoryDetailScreen(
              storyId: selectedStoryId!,
            ),
          ),
        if (isNewStory)
          MaterialPage(
            key: const ValueKey("NewStoryPage"),
            child: NewStoryScreen(onNewStory: () {
              isNewStory = false;
              notifyListeners();
            }),
          ),
      ];

  @override
  Widget build(BuildContext context) {
    if (isLoggedIn == null) {
      historyStack = _splashStack;
    } else if (isLoggedIn == true) {
      historyStack = _loggedInStack;
    } else {
      historyStack = _loggedOutStack;
    }
    return Navigator(
      key: navigatorKey,
      pages: historyStack,
      onPopPage: (route, result) {
        final didPop = route.didPop(result);
        if (!didPop) {
          return false;
        }

        if (selectedStoryId != null) {
          selectedStoryId = null;
        } else if (isNewStory) {
          isNewStory = false;
        } else if (isRegister) {
          isRegister = false;
        } else {
          isLoggedIn = false;
        }
        notifyListeners();
        return true;
      },
    );
  }

  @override
  Future<void> setNewRoutePath(configuration) async {
    /* Do Nothing */
  }
}
