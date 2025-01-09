import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:music_release_radar_app/auth/auth_cubit.dart';
import 'package:music_release_radar_app/core/token_service.dart';
import 'package:music_release_radar_app/auth/auth_page.dart';
import 'package:music_release_radar_app/spotify/spotify_client.dart';

Future<void> main() async {
  await dotenv.load();

  final spotifyClient = SpotifyClient();
  final tokenService = TokenService(FlutterSecureStorage());

  runApp(MyApp(
    spotifyClient: spotifyClient,
    tokenService: tokenService,
  ));
}

class MyApp extends StatelessWidget {
  final SpotifyClient spotifyClient;
  final TokenService tokenService;

  const MyApp({
    super.key,
    required this.spotifyClient,
    required this.tokenService,
  });

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const AuthPage(),
        )
      ],
    );

    return BlocProvider(
      create: (context) => AuthCubit(
        spotifyClient: spotifyClient,
        tokenService: tokenService,
      )..checkAuthStatus(),
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }
}
