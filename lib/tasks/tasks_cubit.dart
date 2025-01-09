import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_release_radar_app/core/token_service.dart';
import 'package:music_release_radar_app/spotify/spotify_client.dart';
import 'package:music_release_radar_app/spotify/model/spotify_user.dart';

part 'tasks_state.dart';

class TasksCubit extends Cubit<TasksState> {
  final SpotifyClient _spotifyClient;
  final TokenService _tokenService;
  final SpotifyUser _user;

  TasksCubit({
    required SpotifyClient spotifyClient,
    required TokenService tokenService,
    required SpotifyUser user,
  })  : _spotifyClient = spotifyClient,
        _tokenService = tokenService,
        _user = user,
        super(TasksInitial());
}
