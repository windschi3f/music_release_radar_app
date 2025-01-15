import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:music_release_radar_app/core/unauthorized_exception.dart';
import 'package:music_release_radar_app/spotify/model/spotify_artist.dart';
import 'package:music_release_radar_app/spotify/model/spotify_playlist.dart';
import 'package:music_release_radar_app/spotify/model/spotify_track.dart';
import 'package:music_release_radar_app/spotify/model/spotify_user.dart';
import 'package:music_release_radar_app/spotify/spotify_client_exception.dart';

class SpotifyClient {
  static const String _authorizationEndpoint =
      'https://accounts.spotify.com/authorize';
  static const String _tokenEndpoint = 'https://accounts.spotify.com/api/token';
  static const String _endpoint = 'https://api.spotify.com/v1';
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
        Uri.parse('$_endpoint/me'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      final userData = _handleResponse(response);

      return SpotifyUser.fromJson(userData);
    } catch (e) {
      if (e is UnauthorizedException || e is SpotifyClientException) {
        rethrow;
      } else {
        throw SpotifyClientException('Failed to fetch user data: $e');
      }
    }
  }

  Future<List<SpotifyArtist>> searchArtists(
      String accessToken, String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_endpoint/search?q=$query&type=artist'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      final artistsJson =
          _handleResponse(response)['artists'] as Map<String, dynamic>;
      final items = artistsJson['items'] as List<dynamic>;

      return items.map((artist) => SpotifyArtist.fromJson(artist)).toList();
    } catch (e) {
      if (e is UnauthorizedException || e is SpotifyClientException) {
        rethrow;
      } else {
        throw SpotifyClientException('Failed to search for artists: $e');
      }
    }
  }

  Future<List<SpotifyPlaylist>> getUserPlaylists(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse('$_endpoint/me/playlists'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      final playlistsJson = _handleResponse(response);
      final items = playlistsJson['items'] as List<dynamic>;

      return items
          .map((playlist) => SpotifyPlaylist.fromJson(playlist))
          .toList();
    } catch (e) {
      if (e is UnauthorizedException || e is SpotifyClientException) {
        rethrow;
      } else {
        throw SpotifyClientException('Failed to fetch user playlists: $e');
      }
    }
  }

  Future<List<SpotifyTrack>> getSeveralTracks(
      String accessToken, List<String> trackIds) async {
    try {
      final response = await http.get(
        Uri.parse('$_endpoint/tracks?ids=${trackIds.join(',')}'),
        headers: {'Authorization': 'Bearer $accessToken'},
      );

      final tracksJson = _handleResponse(response);
      final items = tracksJson['tracks'] as List<dynamic>;

      return items.map((track) => SpotifyTrack.fromJson(track)).toList();
    } catch (e) {
      if (e is UnauthorizedException || e is SpotifyClientException) {
        rethrow;
      } else {
        throw SpotifyClientException('Failed to fetch tracks: $e');
      }
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response,
      {int expectedStatusCode = 200}) {
    if (response.statusCode == expectedStatusCode) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else if (response.statusCode == 401) {
      throw UnauthorizedException();
    } else {
      throw SpotifyClientException(
          'Failed to fetch data (${response.statusCode}): ${response.body}');
    }
  }
}
