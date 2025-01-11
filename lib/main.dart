import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:music_release_radar_app/auth/auth_cubit.dart';
import 'package:music_release_radar_app/core/token_service.dart';
import 'package:music_release_radar_app/auth/auth_page.dart';
import 'package:music_release_radar_app/spotify/spotify_client.dart';
import 'package:music_release_radar_app/tasks/task_client.dart';
import 'package:music_release_radar_app/tasks/tasks_cubit.dart';
import 'package:music_release_radar_app/tasks/tasks_page.dart';

Future<void> main() async {
  await dotenv.load();

  final spotifyClient = SpotifyClient();
  final tokenService = TokenService(FlutterSecureStorage());
  final taskClient = TaskClient();

  runApp(MyApp(
    spotifyClient: spotifyClient,
    tokenService: tokenService,
    taskClient: taskClient,
  ));
}

class MyApp extends StatelessWidget {
  final SpotifyClient spotifyClient;
  final TokenService tokenService;
  final TaskClient taskClient;

  const MyApp({
    super.key,
    required this.spotifyClient,
    required this.tokenService,
    required this.taskClient,
  });

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const AuthPage(),
        ),
        GoRoute(
          path: '/tasks',
          builder: (context, state) {
            return BlocProvider(
              create: (context) => TasksCubit(
                spotifyClient: spotifyClient,
                tokenService: tokenService,
                taskClient: taskClient,
                authCubit: context.read<AuthCubit>(),
              ),
              child: TasksPage(),
            );
          },
        ),
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
