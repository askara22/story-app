import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:submission_flutter_4/model/story.dart';
import 'package:submission_flutter_4/provider/auth_provider.dart';
import 'package:submission_flutter_4/provider/story_provider.dart';

class StoryListScreen extends StatelessWidget {
  final Function() onLogout;

  const StoryListScreen({
    Key? key,
    required this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final storyProvider = context.watch<StoryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Story App"),
        actions: [
          IconButton(
            onPressed: () async {
              final authRead = context.read<AuthProvider>();
              final result = await authRead.logout();
              if (result) onLogout();
            },
            tooltip: "Logout",
            icon: authProvider.isLoadingLogout
                ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                : const Icon(Icons.logout),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await storyProvider.fetchStories(); // Fetch stories here
        },
        tooltip: "New Story",
        child: const Icon(Icons.add),
      ),
      body: storyProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : storyProvider.errorMessage != null
              ? Center(child: Text('Error: ${storyProvider.errorMessage}'))
              : ListView.builder(
                  itemCount: storyProvider.stories.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Image.network(
                        storyProvider.stories[index].photoUrl,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(storyProvider.stories[index].name),
                      subtitle: Text(storyProvider.stories[index].description),
                    );
                  },
                ),
    );
  }
}
