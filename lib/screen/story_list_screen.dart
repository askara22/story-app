import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:submission_flutter_4/provider/auth_provider.dart';
import 'package:submission_flutter_4/provider/story_provider.dart';
import 'package:submission_flutter_4/screen/new_story_screen.dart';

class StoryListScreen extends StatefulWidget {
  final Function() onLogout;
  final Function(String storyId) onStorySelected;

  const StoryListScreen({
    super.key,
    required this.onLogout,
    required this.onStorySelected,
  });

  @override
  _StoryListScreenState createState() => _StoryListScreenState();
}

class _StoryListScreenState extends State<StoryListScreen> {
  @override
  void initState() {
    super.initState();
    final storyProvider = context.read<StoryProvider>();
    storyProvider.fetchStories();
  }

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
              final storyProvider = context.read<StoryProvider>();
              storyProvider.fetchStories();
            },
            tooltip: "Refresh",
            icon: authProvider.isLoadingLogout
                ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                : const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () async {
              final authRead = context.read<AuthProvider>();
              final result = await authRead.logout();
              if (result) widget.onLogout();
            },
            tooltip: "Logout",
            icon: authProvider.isLoadingLogout
                ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                : const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const NewStoryScreen()));
        },
        tooltip: "New Story",
        child: const Icon(Icons.add),
      ),
      body: storyProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : storyProvider.errorMessage != null
              ? Center(child: Text('Error: ${storyProvider.errorMessage}'))
              : ListView.builder(
                  itemCount: storyProvider.stories.length,
                  itemBuilder: (context, index) {
                    final story = storyProvider.stories[index];
                    return InkWell(
                      onTap: () {
                        widget.onStorySelected(story.id);
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                        elevation: 4,
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(8),
                                topRight: Radius.circular(8),
                              ),
                              child: Image.network(
                                story.photoUrl,
                                width: double.infinity,
                                height: 150,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(Icons.error);
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                story.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
