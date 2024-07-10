import 'package:json_annotation/json_annotation.dart';

part 'upload_response.g.dart';

@JsonSerializable()
class UploadResponse {
  final bool error;
  final String message;

  UploadResponse({
    required this.error,
    required this.message,
  });

  factory UploadResponse.fromMap(Map<String, dynamic> map) {
    return UploadResponse(
      error: map['error'] ?? false,
      message: map['message'] ?? '',
    );
  }

  factory UploadResponse.fromJson(Map<String, dynamic> json) =>
      _$UploadResponseFromJson(json);

  Map<String, dynamic> toJson() => _$UploadResponseToJson(this);
}
