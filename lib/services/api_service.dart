import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  final Dio _dio = Dio();
  final String _baseUrl = 'https://finnovia.onrender.com/api';

  Future<Map<String, dynamic>> sendOCR(String imagePath) async {
    try {
      debugPrint('Sending OCR request for image: $imagePath');
      String fileName = imagePath.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(imagePath, filename: fileName),
      });

      Response response = await _dio.post(
        '$_baseUrl/send-to-fastapi-ocr',
        data: formData,
      );

      debugPrint('OCR request successful: ${response.data}');
      return response.data;
    } catch (e) {
      debugPrint('OCR request failed: $e');
      throw Exception('Failed to process receipt');
    }
  }

  Future<Map<String, dynamic>> sendVoice(String audioPath) async {
    try {
      String fileName = audioPath.split('/').last;
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          audioPath,
          filename: fileName,
          contentType: MediaType('audio', 'wav'),
        ),
      });

      Response response = await _dio.post(
        '$_baseUrl/send-to-fastapi',
        data: formData,
      );

      return response.data;
    } on DioException {
      throw Exception('Failed to process voice command.');
    } catch (e) {
      throw Exception('Failed to process voice command: $e');
    }
  }

  Future<String> sendAIAssist(String message) async {
    try {
      debugPrint('Sending AI assist request: $message');

      Response response = await _dio.post(
        'https://348512666c7a.ngrok-free.app/chat',
        data: {'message': message},
      );

      debugPrint('AI assist response: ${response.data}');

      if (response.data is Map && response.data.containsKey('response')) {
        return response.data['response'] as String;
      }

      throw Exception('Invalid response format from AI assist');
    } on DioException catch (e) {
      debugPrint('AI assist request failed: ${e.response?.data ?? e.message}');
      throw Exception(
        'Failed to get AI response: ${e.response?.data ?? e.message}',
      );
    } catch (e) {
      debugPrint('AI assist request failed: $e');
      throw Exception('Failed to get AI response: $e');
    }
  }
}
