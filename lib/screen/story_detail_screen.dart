import 'package:flutter/material.dart';

class StoryDetailScreen extends StatelessWidget {
  const StoryDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detial Story'),
      ),
      body: const Text('Story Detail'),
    );
  }
}
