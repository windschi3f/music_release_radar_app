import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:music_release_radar_app/auth/auth_client_exception.dart';
import 'package:music_release_radar_app/core/base_http_client.dart';

class AuthClient extends BaseHttpClient {
  final String _endpoint;

  AuthClient()
      : _endpoint = dotenv.env['MUSIC_RELEASE_RADAR_SERVICE_ENDPOINT'] ?? '' {
    if (_endpoint.isEmpty) {
      throw AuthClientException('Missing service endpoint in .env file');
    }
  }

  Future<void> createOrUpdateRefreshToken(
          String accessToken, String refreshToken) =>
      handleRequest(
          () => http.put(
                Uri.parse('$_endpoint/auth/spotify/refresh-token'),
                headers: getHeaders(accessToken, contentType: 'text/plain'),
                body: refreshToken,
              ),
          (_) => {});
}
