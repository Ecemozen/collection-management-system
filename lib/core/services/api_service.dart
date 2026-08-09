import 'dart:convert';

import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';

class ApiService {
  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse("${ApiConstants.baseUrl}/$endpoint");

    final response = await http.get(url);

    return response;
  }

  Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse("${ApiConstants.baseUrl}/$endpoint");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    return response;
  }

  Future<http.Response> delete(String endpoint) async {
    final url = Uri.parse("${ApiConstants.baseUrl}/$endpoint");

    final response = await http.delete(
      url,
      headers: {
        "Content-Type": "application/json",
      },
    );

    return response;
  }

  Future<http.Response> put(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final url = Uri.parse("${ApiConstants.baseUrl}/$endpoint");

    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    return response;
  }

  // İmzalı makbuz / dosya yükleme
  Future<http.Response> uploadFile(
    String endpoint,
    String filePath,
  ) async {
    final url = Uri.parse("${ApiConstants.baseUrl}/$endpoint");

    final request = http.MultipartRequest(
      "POST",
      url,
    );

    final file = await http.MultipartFile.fromPath(
      "file",
      filePath,
    );

    request.files.add(file);

    final streamedResponse = await request.send();

    final response = await http.Response.fromStream(
      streamedResponse,
    );

    return response;
  }
}