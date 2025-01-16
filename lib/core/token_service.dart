import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:music_release_radar_app/auth/auth_client.dart';

class TokenService {
  static const String accessTokenKey = 'accessToken';
  static const String refreshTokenKey = 'refreshToken';

  final FlutterSecureStorage _secureStorage;
  final AuthClient _authClient;

  TokenService(this._secureStorage, this._authClient);

  Future<void> saveTokens(String accessToken, String? refreshToken) async {
    await _secureStorage.write(key: accessTokenKey, value: accessToken);
    if (refreshToken != null) {
      await _authClient.createOrUpdateRefreshToken(accessToken, refreshToken);
      await _secureStorage.write(key: refreshTokenKey, value: refreshToken);
    }
  }

  Future<Map<String, String?>> retrieveTokens() async {
    final accessToken = await _secureStorage.read(key: accessTokenKey);
    final refreshToken = await _secureStorage.read(key: refreshTokenKey);
    return {
      accessTokenKey: accessToken,
      refreshTokenKey: refreshToken,
    };
  }

  Future<void> deleteTokens() async {
    await _secureStorage.delete(key: accessTokenKey);
    await _secureStorage.delete(key: 'refreshToken');
  }
}
