import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:submission_flutter_4/provider/auth_provider.dart';
import 'package:submission_flutter_4/provider/story_provider.dart';
import 'package:submission_flutter_4/widgets/story_card.dart';

class StoryListScreen extends StatefulWidget {
  final Function() onLogout;
  final Function(String storyId) onStorySelected;
  final Function() toNewStory;

  const StoryListScreen({
    super.key,
    required this.onLogout,
    required this.onStorySelected,
    required this.toNewStory,
  });

  @override
  _StoryListScreenState createState() => _StoryListScreenState();
}

class _StoryListScreenState extends State<StoryListScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_onScroll);
    final storyProvider = context.read<StoryProvider>();
    storyProvider.fetchStories();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (scrollController.position.pixels >=
        scrollController.position.maxScrollExtent * 0.8) {
      final storyProvider = context.read<StoryProvider>();
      if (storyProvider.hasMoreStories && !storyProvider.isFetchingMore) {
        storyProvider.fetchMoreStories();
      }
    }
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
            icon: const Icon(Icons.refresh),
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
                    color: Colors.purple,
                  )
                : const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          widget.toNewStory();
        },
        tooltip: "New Story",
        child: const Icon(Icons.add),
      ),
      body: storyProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : storyProvider.errorMessage != null
              ? Center(child: Text('Error: ${storyProvider.errorMessage}'))
              : ListView.builder(
                  controller: scrollController,
                  itemCount: storyProvider.stories.length + 1,
                  itemBuilder: (context, index) {
                    if (index == storyProvider.stories.length) {
                      return storyProvider.hasMoreStories
                          ? const Center(child: CircularProgressIndicator())
                          : const SizedBox.shrink();
                    }
                    final story = storyProvider.stories[index];
                    return InkWell(
                      onTap: () {
                        widget.onStorySelected(story.id);
                      },
                      child: StoryCard(story: story),
                    );
                  },
                ),
    );
  }
}
