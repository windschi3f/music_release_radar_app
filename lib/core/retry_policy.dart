import 'package:music_release_radar_app/core/token_service.dart';
import 'package:music_release_radar_app/core/unauthorized_exception.dart';
import 'package:music_release_radar_app/spotify/spotify_client.dart';

class RetryPolicy {
  final TokenService _tokenService;
  final SpotifyClient _spotifyClient;

  RetryPolicy(this._tokenService, this._spotifyClient);

  Future<T> execute<T>(Future<T> Function(String token) operation) async {
    final tokens = await _tokenService.retrieveTokens();
    try {
      return await operation(tokens[TokenService.accessTokenKey]!);
    } on UnauthorizedException {
      try {
        final tokenResponse = await _spotifyClient.refreshAccessToken(
          tokens[TokenService.refreshTokenKey]!,
        );
        await _tokenService.saveTokens(
          tokenResponse.accessToken!,
          tokenResponse.refreshToken,
        );
        return await operation(tokenResponse.accessToken!);
      } catch (e) {
        throw UnauthorizedException();
      }
    }
  }
}
