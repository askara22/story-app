import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:submission_flutter_4/database/auth_repo.dart';
import 'package:submission_flutter_4/model/upload_response.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;

class UploadStoryProvider with ChangeNotifier {
  bool isUploading = false;
  String message = "";
  UploadResponse? uploadResponse;

  final AuthRepository authRepository;
  UploadStoryProvider(this.authRepository);
  static const baseUrl = 'https://story-api.dicoding.dev/v1';

  Future<void> upload(
    List<int> bytes,
    String fileName,
    String description,
  ) async {
    try {
      isUploading = true;
      notifyListeners();

      final token = await authRepository.getToken();
      if (token == null) {
        throw Exception('Token is null');
      }

      final uri = Uri.parse('$baseUrl/stories');
      var request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';

      final multiPartFile = http.MultipartFile.fromBytes(
        "photo",
        bytes,
        filename: fileName,
      );

      request.files.add(multiPartFile);
      request.fields['description'] = description;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        uploadResponse = UploadResponse.fromMap(responseData);
        message = uploadResponse?.message ?? "Success";
      } else {
        throw Exception(
            "Failed to upload file. Status code: ${response.statusCode}");
      }
    } catch (e) {
      message = 'Error: $e';
    } finally {
      isUploading = false;
      notifyListeners();
    }
  }

  Future<List<int>> compressImage(List<int> bytes) async {
    int imageLength = bytes.length;
    if (imageLength < 1000000) return bytes;
    final img.Image image = img.decodeImage(Uint8List.fromList(bytes))!;
    int compressQuality = 100;
    int length = imageLength;
    List<int> newByte = [];
    do {
      ///
      compressQuality -= 10;
      newByte = img.encodeJpg(
        image,
        quality: compressQuality,
      );
      length = newByte.length;
    } while (length > 1000000);
    return newByte;
  }
}
