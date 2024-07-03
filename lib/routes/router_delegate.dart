import 'package:flutter/material.dart';
import 'package:submission_flutter_4/database/auth_repo.dart';
import 'package:submission_flutter_4/screen/login_screen.dart';
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

  String? selectedQuote;

  List<Page> historyStack = [];
  bool? isLoggedIn;
  bool isRegister = false;

  _init() async {
    isLoggedIn = await authRepository.isLoggedIn();
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
              isLoggedIn = true;
              notifyListeners();
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
              isLoggedIn = false;
              notifyListeners();
            },
            // quotes: quotes,
            // onTapped: (String quoteId) {
            //   selectedQuote = quoteId;
            //   notifyListeners();
            // },
          ),
        ),
        if (selectedQuote != null)
          MaterialPage(
            key: ValueKey(selectedQuote),
            child: const StoryDetailScreen(
                // quoteId: selectedQuote!,
                ),
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

        isRegister = false;
        selectedQuote = null;
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
