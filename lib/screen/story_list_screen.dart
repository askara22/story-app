import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:submission_flutter_4/provider/auth_provider.dart';

class StoryListScreen extends StatelessWidget {
  final Function() onLogout;

  const StoryListScreen({
    Key? key,
    required this.onLogout,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authWatch = context.watch<AuthProvider>();
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
            icon: authWatch.isLoadingLogout
                ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                : const Icon(Icons.logout),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {},
        tooltip: "New Story",
        child: authWatch.isLoadingLogout
            ? const CircularProgressIndicator(
                color: Colors.white,
              )
            : const Icon(Icons.add),
      ),
    );
  }
}
