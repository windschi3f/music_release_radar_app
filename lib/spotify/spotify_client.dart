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
    'playlist-read-private',
    'playlist-modify-private',
    'playlist-modify-public',
    'user-follow-read'
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

  Future<List<SpotifyArtist>> getSeveralArtists(
      String accessToken, List<String> artistIds) {
    final chunkSize = 50;
    final chunks = <List<String>>[];
    for (var i = 0; i < artistIds.length; i += chunkSize) {
      chunks.add(artistIds.sublist(i,
          i + chunkSize > artistIds.length ? artistIds.length : i + chunkSize));
    }

    return Future.wait(chunks.map((chunk) => handleRequest(
              () => http.get(
                Uri.parse('$_endpoint/artists?ids=${chunk.join(",")}'),
                headers: getHeaders(accessToken),
              ),
              (json) => (json['artists'] as List)
                  .map((artist) => SpotifyArtist.fromJson(artist))
                  .toList(),
            )))
        .then((responses) => responses.expand((element) => element).toList());
  }

  Future<List<SpotifyArtist>> getUserFollowedArtists(String accessToken) =>
      handleRequestWithNextPages(
        '$_endpoint/me/following?type=artist&limit=50',
        (json) => (json['items'] as List)
            .map((artist) => SpotifyArtist.fromJson(artist))
            .toList(),
        accessToken,
        getItems: (json) => json['artists']['items'],
        getNext: (json) => json['artists']['next'],
      );

  Future<List<SpotifyPlaylist>> getUserPlaylists(String accessToken) =>
      handleRequestWithNextPages(
        '$_endpoint/me/playlists?limit=50',
        (json) => (json['items'] as List)
            .map((playlist) => SpotifyPlaylist.fromJson(playlist))
            .toList(),
        accessToken,
      );

  Future<void> createPlaylist(String accessToken, String userId,
          String playlistName, bool isPublic) =>
      handleRequest(
        () => http.post(
          Uri.parse('$_endpoint/users/$userId/playlists'),
          headers: getHeaders(accessToken, contentType: 'application/json'),
          body: '{"name":"$playlistName","public":$isPublic}',
        ),
        (_) => {},
      );

  Future<List<SpotifyTrack>> getSeveralTracks(
      String accessToken, List<String> trackIds) {
    final chunkSize = 50;
    final chunks = <List<String>>[];
    for (var i = 0; i < trackIds.length; i += chunkSize) {
      chunks.add(trackIds.sublist(i,
          i + chunkSize > trackIds.length ? trackIds.length : i + chunkSize));
    }

    return Future.wait(chunks.map((chunk) => handleRequest(
              () => http.get(
                Uri.parse('$_endpoint/tracks?ids=${chunk.join(",")}'),
                headers: getHeaders(accessToken),
              ),
              (json) => (json['tracks'] as List)
                  .map((track) => SpotifyTrack.fromJson(track))
                  .toList(),
            )))
        .then((responses) => responses.expand((element) => element).toList());
  }
}
