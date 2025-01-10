import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_release_radar_app/auth/auth_cubit.dart';
import 'package:music_release_radar_app/core/retry_policy.dart';
import 'package:music_release_radar_app/core/token_service.dart';
import 'package:music_release_radar_app/core/unauthorized_exception.dart';
import 'package:music_release_radar_app/spotify/spotify_client.dart';
import 'package:music_release_radar_app/tasks/task_client.dart';
import 'package:music_release_radar_app/tasks/task.dart';

part 'tasks_state.dart';

class TasksCubit extends Cubit<TasksState> {
  final TaskClient _taskClient;
  final RetryPolicy _retryPolicy;
  final AuthCubit _authCubit;

  TasksCubit({
    required SpotifyClient spotifyClient,
    required TokenService tokenService,
    required TaskClient taskClient,
    required AuthCubit authCubit,
  })  : _taskClient = taskClient,
        _retryPolicy = RetryPolicy(tokenService, spotifyClient),
        _authCubit = authCubit,
        super(TasksInitial());

  Future<void> fetchTasks() async {
    emit(TasksLoading());
    try {
      final tasks = await _retryPolicy.execute(
        (token) => _taskClient.getTasks(token),
      );
      emit(TasksSuccess(tasks));
    } on UnauthorizedException {
      _authCubit.logout();
    } catch (e) {
      emit(TasksError(e.toString()));
    }
  }
}
