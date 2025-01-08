import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:music_release_radar_app/auth_cubit.dart';
import 'package:music_release_radar_app/spotify/spotify_client.dart';

Future<void> main() async {
  await dotenv.load();

  final spotifyClient = SpotifyClient();
  final secureStorage = const FlutterSecureStorage();

  runApp(MyApp(
    spotifyClient: spotifyClient,
    secureStorage: secureStorage,
  ));
}

class MyApp extends StatelessWidget {
  final SpotifyClient spotifyClient;
  final FlutterSecureStorage secureStorage;

  const MyApp({
    super.key,
    required this.spotifyClient,
    required this.secureStorage,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => AuthCubit(
            spotifyClient: spotifyClient,
            secureStorage: secureStorage,
          )..checkAuthStatus(),
        ),
      ],
      child: MaterialApp(
        home: BlocConsumer<AuthCubit, AuthState>(
            listener: (context, state) {
              if (state is AuthenticationFailed) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                  ),
                );
              }
            },
            builder: (context, state) =>
                Scaffold(body: _buildBody(context, state))),
      ),
    );
  }

  Widget _buildBody(BuildContext context, AuthState state) {
    if (state is AuthLoading) {
      return Center(
        child: CircularProgressIndicator(),
      );
    } else if (state is Authenticated) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome ${state.user.displayName}!'),
            Text('Followers: ${state.user.followerCount}'),
          ],
        ),
      );
    } else {
      return Center(
        child: ElevatedButton(
          onPressed: () {
            context.read<AuthCubit>().authenticate();
          },
          child: const Text('Login with Spotify'),
        ),
      );
    }
  }
}
