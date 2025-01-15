import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:music_release_radar_app/core/base_http_client.dart';

import 'package:music_release_radar_app/spotify/model/spotify_artist.dart';
import 'package:music_release_radar_app/spotify/model/spotify_playlist.dart';
import 'package:music_release_radar_app/spotify/model/spotify_track.dart';
import 'package:music_release_radar_app/spotify/model/spotify_user.dart';
import 'package:music_release_radar_app/spotify/spotify_client_exception.dart';

class SpotifyClient extends BaseHttpClient {
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

  Future<SpotifyUser> getUserData(String accessToken) => handleRequest(
        () => http.get(
          Uri.parse('$_endpoint/me'),
          headers: getHeaders(accessToken),
        ),
        (json) => SpotifyUser.fromJson(json),
      );

  Future<List<SpotifyArtist>> searchArtists(String accessToken, String query) =>
      handleRequest(
        () => http.get(
          Uri.parse('$_endpoint/search?q=$query&type=artist'),
          headers: getHeaders(accessToken),
        ),
        (json) => (json['artists']['items'] as List)
            .map((artist) => SpotifyArtist.fromJson(artist))
            .toList(),
      );

  Future<List<SpotifyPlaylist>> getUserPlaylists(String accessToken) =>
      handleRequest(
        () => http.get(
          Uri.parse('$_endpoint/me/playlists'),
          headers: getHeaders(accessToken),
        ),
        (json) => (json['items'] as List)
            .map((playlist) => SpotifyPlaylist.fromJson(playlist))
            .toList(),
      );

  Future<List<SpotifyTrack>> getSeveralTracks(
          String accessToken, List<String> trackIds) =>
      handleRequest(
        () => http.get(
          Uri.parse('$_endpoint/tracks?ids=${trackIds.join(",")}'),
          headers: getHeaders(accessToken),
        ),
        (json) => (json['tracks'] as List)
            .map((track) => SpotifyTrack.fromJson(track))
            .toList(),
      );
}
