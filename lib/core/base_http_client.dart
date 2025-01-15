import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:music_release_radar_app/core/unauthorized_exception.dart';

abstract class BaseHttpClient {
  Map<String, String> getHeaders(String accessToken,
          {bool includeJson = false}) =>
      {
        'Authorization': 'Bearer $accessToken',
        if (includeJson) 'Content-Type': 'application/json',
      };

  Future<T> handleRequest<T>(
    Future<http.Response> Function() requestFn,
    T Function(dynamic json) parseResponse, {
    int expectedStatus = 200,
    bool returnRawResponse = false,
  }) async {
    try {
      final response = await requestFn();

      if (response.statusCode == expectedStatus) {
        if (response.statusCode == 204 || response.body.isEmpty) {
          return parseResponse(null);
        }
        final responseData = jsonDecode(response.body);
        return parseResponse(returnRawResponse ? responseData : responseData);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else {
        throw Exception(
            'Request failed (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      if (e is UnauthorizedException) rethrow;
      throw Exception('Request failed: $e');
    }
  }
}
