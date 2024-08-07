import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:submission_flutter_4/database/auth_repo.dart';
import 'package:submission_flutter_4/provider/auth_provider.dart';
import 'package:submission_flutter_4/provider/take_image_provider.dart';
import 'package:submission_flutter_4/provider/story_provider.dart';
import 'package:submission_flutter_4/provider/upload_story_provider.dart';
import 'package:submission_flutter_4/routes/router_delegate.dart';

void main() {
  runApp(const StoryApp());
}

class StoryApp extends StatefulWidget {
  const StoryApp({super.key});

  @override
  State<StoryApp> createState() => _StoryAppState();
}

class _StoryAppState extends State<StoryApp> {
  late MyRouterDelegate myRouterDelegate;
  late AuthProvider authProvider;

  @override
  void initState() {
    super.initState();
    final authRepository = AuthRepository();

    authProvider = AuthProvider(authRepository);

    myRouterDelegate = MyRouterDelegate(authRepository);
    authProvider.addListener(() {
      if (authProvider.isLoggedIn) {
        myRouterDelegate.onLogin();
      } else {
        myRouterDelegate.onLogout();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => authProvider),
        ChangeNotifierProvider(
            create: (context) => StoryProvider(AuthRepository())),
        ChangeNotifierProvider(
            create: (context) => UploadStoryProvider(AuthRepository())),
        ChangeNotifierProvider(create: (context) => TakeImageProvider()),
      ],
      child: MaterialApp(
        title: 'Story App',
        home: Router(
          routerDelegate: myRouterDelegate,
          backButtonDispatcher: RootBackButtonDispatcher(),
        ),
      ),
    );
  }
}
