import 'dart:typed_data';

import 'package:dio/dio.dart';

import '../config.dart';

/// Uploads images to Cloudinary using an unsigned upload preset.
class CloudinaryService {
  CloudinaryService._();
  static final instance = CloudinaryService._();

  final _dio = Dio();

  /// Returns the `secure_url` of the uploaded image.
  Future<String> upload(
    Uint8List bytes, {
    required String filename,
    void Function(double progress)? onProgress,
  }) async {
    if (!AppConfig.cloudinaryConfigured) {
      throw StateError('Chưa cấu hình Cloudinary (lib/config.dart).');
    }
    final url = 'https://api.cloudinary.com/v1_1/${AppConfig.cloudinaryCloudName}/image/upload';
    final form = FormData.fromMap({
      'upload_preset': AppConfig.cloudinaryUploadPreset,
      'file': MultipartFile.fromBytes(bytes, filename: filename),
    });
    try {
      final res = await _dio.post<Map<String, dynamic>>(
        url,
        data: form,
        onSendProgress: (sent, total) {
          if (total > 0) onProgress?.call(sent / total);
        },
      );
      final secureUrl = res.data?['secure_url'] as String?;
      if (secureUrl == null) throw StateError('Cloudinary không trả về URL ảnh.');
      return secureUrl;
    } on DioException catch (e) {
      final msg = (e.response?.data is Map) ? (e.response!.data['error']?['message']) : null;
      throw StateError('Tải ảnh lên thất bại: ${msg ?? e.message}');
    }
  }
}
