import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:music_release_radar_app/core/unauthorized_exception.dart';

abstract class BaseHttpClient {
  Map<String, String> getHeaders(String accessToken, {String? contentType}) => {
        'Authorization': 'Bearer $accessToken',
        if (contentType != null) 'Content-Type': contentType,
      };

  Future<T> handleRequest<T>(Future<http.Response> Function() requestFn,
      T Function(dynamic json) parseResponse) async {
    try {
      final response = await requestFn();

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.statusCode == 204 || response.body.isEmpty) {
          return parseResponse(null);
        }
        final responseData = jsonDecode(response.body);
        return parseResponse(responseData);
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

Future<T> handleRequestWithNextPages<T>(
    String initialUrl,
    T Function(dynamic json) parseResponse,
    String accessToken, {
    String? contentType,
    Function(dynamic)? getItems,
    Function(dynamic)? getNext,
  }) async {
    var allItems = [];
    String? currentUrl = initialUrl;
    while (currentUrl != null) {
      final response = await handleRequest(
        () => http.get(
          Uri.parse(currentUrl!),
          headers: getHeaders(accessToken, contentType: contentType),
        ),
        (json) => json,
      );

      allItems.addAll(getItems?.call(response) ?? response['items'] ?? []);
      currentUrl = getNext?.call(response) ?? response['next'] as String?;
    }

    return parseResponse({'items': allItems});
  }

}
