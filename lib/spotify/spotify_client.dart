import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:music_release_radar_app/core/unauthorized_exception.dart';
import 'package:music_release_radar_app/spotify/model/spotify_user.dart';
import 'package:music_release_radar_app/spotify/spotify_client_exception.dart';

class SpotifyClient {
  static const String _authorizationEndpoint =
      'https://accounts.spotify.com/authorize';
  static const String _tokenEndpoint = 'https://accounts.spotify.com/api/token';
  static const String _userInfoEndpoint = 'https://api.spotify.com/v1/me';
  static const List<String> _scopes = [
    'playlist-modify-private',
    'playlist-modify-public'
  ];

  final String _clientId;
  final String _redirectUri;
  final FlutterAppAuth _appAuth = FlutterAppAuth();

  SpotifyClient()
      : _clientId = dotenv.env['SPOTIFY_CLIENT_ID'] ?? '',
        _redirectUri = dotenv.env['SPOTIFY_REDIRECT_URI'] ?? '' {
    if (_clientId.isEmpty || _redirectUri.isEmpty) {
      throw SpotifyClientException(
          'Missing Spotify client ID or redirect URI in .env file');
    }
  }

  Future<AuthorizationTokenResponse> authenticate() async {
    return await _appAuth.authorizeAndExchangeCode(
      AuthorizationTokenRequest(
        _clientId,
        _redirectUri,
        scopes: _scopes,
        serviceConfiguration: AuthorizationServiceConfiguration(
          authorizationEndpoint: _authorizationEndpoint,
          tokenEndpoint: _tokenEndpoint,
        ),
      ),
    );
  }

  Future<TokenResponse> refreshAccessToken(String refreshToken) async {
    return await _appAuth.token(
      TokenRequest(
        _clientId,
        _redirectUri,
        serviceConfiguration: AuthorizationServiceConfiguration(
          authorizationEndpoint: _authorizationEndpoint,
          tokenEndpoint: _tokenEndpoint,
        ),
        refreshToken: refreshToken,
      ),
    );
  }

  Future<SpotifyUser> getUserData(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse(_userInfoEndpoint),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body) as Map<String, dynamic>;
        return SpotifyUser.fromJson(userData);
      } else if (response.statusCode == 401) {
        throw UnauthorizedException();
      } else {
        throw SpotifyClientException(
            'Failed to fetch Spotify user data (${response.statusCode}): ${response.body}');
      }
    } on FormatException catch (e) {
      throw SpotifyClientException('Invalid response format: $e');
    } on UnauthorizedException {
      rethrow;
    } catch (e) {
      throw SpotifyClientException('Unknown error occurred: $e');
    }
  }
}
