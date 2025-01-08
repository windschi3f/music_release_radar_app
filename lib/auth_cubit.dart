import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:music_release_radar_app/spotify/access_token_expired_exception.dart';
import 'package:music_release_radar_app/spotify/model/spotify_user.dart';
import 'package:music_release_radar_app/spotify/spotify_client.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final SpotifyClient _spotifyClient;
  final FlutterSecureStorage _secureStorage;

  AuthCubit({
    required SpotifyClient spotifyClient,
    required FlutterSecureStorage secureStorage,
  })  : _spotifyClient = spotifyClient,
        _secureStorage = secureStorage,
        super(AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());

    try {
      final accessToken = await _secureStorage.read(key: 'accessToken');
      final refreshToken = await _secureStorage.read(key: 'refreshToken');

      if (accessToken == null || refreshToken == null) {
        emit(AuthenticationRequired());
        return;
      }

      try {
        final user = await _spotifyClient.getUserData(accessToken);
        emit(Authenticated(user));
        return;
      } on AccessTokenExpiredException {
        final tokenResponse =
            await _spotifyClient.refreshAccessToken(refreshToken);
        _saveTokens(tokenResponse.accessToken!, tokenResponse.refreshToken);

        final user =
            await _spotifyClient.getUserData(tokenResponse.accessToken!);
        emit(Authenticated(user));
        return;
      }
    } catch (e) {
      await _clearTokens();
      emit(AuthenticationRequired());
    }
  }

  Future<void> authenticate() async {
    emit(AuthLoading());

    try {
      final response = await _spotifyClient.authenticate();
      _saveTokens(response.accessToken!, response.refreshToken!);

      final user = await _spotifyClient.getUserData(response.accessToken!);
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthenticationFailed(e.toString()));
    }
  }

  Future<void> _saveTokens(String accessToken, String? refreshToken) async {
    await _secureStorage.write(key: 'accessToken', value: accessToken);
    if (refreshToken != null) {
      await _secureStorage.write(key: 'refreshToken', value: refreshToken);
    }
  }

  Future<void> _clearTokens() async {
    await _secureStorage.delete(key: 'accessToken');
    await _secureStorage.delete(key: 'refreshToken');
  }
}
