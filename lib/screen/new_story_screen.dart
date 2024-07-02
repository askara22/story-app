import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:submission_flutter_4/provider/image_provider.dart';

class NewStoryScreen extends StatefulWidget {
  const NewStoryScreen({super.key});

  @override
  State<NewStoryScreen> createState() => _NewStoryScreenState();
}

class _NewStoryScreenState extends State<NewStoryScreen> {
  TextEditingController desController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Story"),
        actions: [
          IconButton(
            onPressed: () => _onUpload(),
            icon: const Icon(Icons.upload),
            tooltip: "Unggah",
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 1,
              child: context.watch<TakeImageProvider>().imagePath == null
                  ? const Align(
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.image,
                        size: 100,
                      ),
                    )
                  : _showImage(),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => _onGalleryView(),
                    child: const Text("Gallery"),
                  ),
                  ElevatedButton(
                    onPressed: () => _onCameraView(),
                    child: const Text("Camera"),
                  ),
                ],
              ),
            ),
            Expanded(
                child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20),
              child: SizedBox(
                height: 16,
                child: TextField(
                  controller: desController,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(), hintText: 'Description'),
                ),
              ),
            )),
            Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: FilledButton(
                    onPressed: () => _onUpload(), child: const Text('Upload'))),
          ],
        ),
      ),
    );
  }

  _onUpload() async {}

  _onGalleryView() async {}

  _onCameraView() async {}

  _onCustomCameraView() async {}

  Widget _showImage() {
    return Container();
  }
}
