
import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://finnovia.onrender.com/api';

  Future<Map<String, dynamic>> sendOCR(String imagePath) async {
    try {
      String fileName = imagePath.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(imagePath, filename: fileName),
      });

      Response response = await _dio.post(
        '$_baseUrl/send-to-fastapi-ocr',
        data: formData,
      );

      return response.data;
    } catch (e) {
      throw Exception('Failed to process receipt: $e');
    }
  }

  Future<Map<String, dynamic>> sendVoice(String audioPath) async {
    try {
      String fileName = audioPath.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(audioPath, filename: fileName),
      });

      Response response = await _dio.post(
        '$_baseUrl/send-to-fastapi',
        data: formData,
      );

      return response.data;
    } catch (e) {
      throw Exception('Failed to process voice command: $e');
    }
  }
}
