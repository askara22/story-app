import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:submission_flutter_4/screen/new_story_screen.dart';
import 'package:submission_flutter_4/provider/image_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TakeImageProvider(),
      child: const MaterialApp(
        home: NewStoryScreen(),
      ),
    ),
  );
}
