import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:submission_flutter_4/provider/story_provider.dart';
import 'package:submission_flutter_4/provider/take_image_provider.dart';
import 'package:submission_flutter_4/provider/upload_story_provider.dart';

class NewStoryScreen extends StatefulWidget {
  final Function onNewStory;

  const NewStoryScreen({super.key, required this.onNewStory});

  @override
  State<NewStoryScreen> createState() => _NewStoryScreenState();
}

class _NewStoryScreenState extends State<NewStoryScreen> {
  TextEditingController desController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final uploadProvider = context.watch<UploadStoryProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("New Story"),
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
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
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
            Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: SizedBox(
                height: 100,
                child: TextField(
                  controller: desController,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(), hintText: 'Description'),
                  maxLines: 5,
                  minLines: 4,
                ),
              ),
            ),
            Padding(
                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                child: ElevatedButton(
                  onPressed: () => _onUpload(context),
                  child: uploadProvider.isUploading
                      ? const CircularProgressIndicator(
                          color: Colors.purple,
                        )
                      : const Text('Upload'),
                )),
          ],
        ),
      ),
    );
  }

  _onUpload(BuildContext context) async {
    final takeImageProvider = context.read<TakeImageProvider>();
    final imagePath = takeImageProvider.imagePath;
    final imageFile = takeImageProvider.imageFile;

    if (imagePath == null || imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an image')),
      );
      return;
    }

    final description = desController.text;
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a description')),
      );
      return;
    }

    final fileName = imageFile.name;
    final bytes = await imageFile.readAsBytes();

    final uploadProvider = context.read<UploadStoryProvider>();
    final newBytes = await uploadProvider.compressImage(bytes);
    await uploadProvider.upload(newBytes, fileName, description);

    if (uploadProvider.uploadResponse != null) {
      desController.clear();
      takeImageProvider.setImageFile(null);
      takeImageProvider.setImagePath(null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(uploadProvider.message)),
      );
      final storyProvider = context.read<StoryProvider>();
      storyProvider.fetchStories();
      widget.onNewStory();
    }
  }

  _onGalleryView() async {
    final provider = context.read<TakeImageProvider>();

    final isMacOS = defaultTargetPlatform == TargetPlatform.macOS;
    final isLinux = defaultTargetPlatform == TargetPlatform.linux;
    if (isMacOS || isLinux) return;

    final ImagePicker picker = ImagePicker();

    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      provider.setImageFile(pickedFile);
      provider.setImagePath(pickedFile.path);
    }
  }

  _onCameraView() async {
    final provider = context.read<TakeImageProvider>();

    final isAndroid = defaultTargetPlatform == TargetPlatform.android;
    final isiOS = defaultTargetPlatform == TargetPlatform.iOS;
    final isNotMobile = !(isAndroid || isiOS);
    if (isNotMobile) return;

    final ImagePicker picker = ImagePicker();

    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.camera,
    );

    if (pickedFile != null) {
      provider.setImageFile(pickedFile);
      provider.setImagePath(pickedFile.path);
    }
  }

  Widget _showImage() {
    final imagePath = context.read<TakeImageProvider>().imagePath;
    return kIsWeb
        ? Image.network(
            imagePath.toString(),
            fit: BoxFit.contain,
          )
        : Image.file(
            File(imagePath.toString()),
            fit: BoxFit.contain,
          );
  }
}
