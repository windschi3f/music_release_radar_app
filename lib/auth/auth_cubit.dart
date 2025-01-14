import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_release_radar_app/core/token_service.dart';
import 'package:music_release_radar_app/core/unauthorized_exception.dart';
import 'package:music_release_radar_app/spotify/model/spotify_user.dart';
import 'package:music_release_radar_app/spotify/spotify_client.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SpotifyClient _spotifyClient;
  final TokenService _tokenService;
  SpotifyUser? _user;

  AuthCubit({
    required SpotifyClient spotifyClient,
    required TokenService tokenService,
  })  : _spotifyClient = spotifyClient,
        _tokenService = tokenService,
        super(AuthInitial());

  SpotifyUser? get user => _user;

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());

    try {
      final tokens = await _tokenService.retrieveTokens();
      final accessToken = tokens[TokenService.accessTokenKey];
      final refreshToken = tokens[TokenService.refreshTokenKey];

      if (accessToken == null || refreshToken == null) {
        emit(AuthenticationRequired());
        return;
      }

      try {
        _user = await _spotifyClient.getUserData(accessToken);
        emit(Authenticated(_user!));
        return;
      } on UnauthorizedException {
        final tokenResponse =
            await _spotifyClient.refreshAccessToken(refreshToken);
        await _tokenService.saveTokens(
            tokenResponse.accessToken!, tokenResponse.refreshToken);

        _user = await _spotifyClient.getUserData(tokenResponse.accessToken!);
        emit(Authenticated(_user!));
        return;
      }
    } catch (e) {
      await _tokenService.deleteTokens();
      emit(AuthenticationRequired());
    }
  }

  Future<void> authenticate() async {
    emit(AuthLoading());

    final tokens = await _tokenService.retrieveTokens();
    final accessToken = tokens[TokenService.accessTokenKey];
    final refreshToken = tokens[TokenService.refreshTokenKey];
    if (accessToken != null && refreshToken != null) {
      checkAuthStatus();
      return;
    }

    try {
      final response = await _spotifyClient.authenticate();
      await _tokenService.saveTokens(
          response.accessToken!, response.refreshToken!);

      _user = await _spotifyClient.getUserData(response.accessToken!);
      emit(Authenticated(_user!));
    } catch (e) {
      emit(AuthenticationFailed(e.toString()));
    }
  }

  Future<void> logout() async {
    await _tokenService.deleteTokens();
    emit(AuthenticationRequired());
  }
}
