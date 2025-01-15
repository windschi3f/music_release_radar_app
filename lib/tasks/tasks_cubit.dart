import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_release_radar_app/auth/auth_cubit.dart';
import 'package:music_release_radar_app/core/retry_policy.dart';
import 'package:music_release_radar_app/core/token_service.dart';
import 'package:music_release_radar_app/core/unauthorized_exception.dart';
import 'package:music_release_radar_app/spotify/model/spotify_playlist.dart';
import 'package:music_release_radar_app/spotify/spotify_client.dart';
import 'package:music_release_radar_app/tasks/task_client.dart';
import 'package:music_release_radar_app/tasks/task.dart';

part 'tasks_state.dart';

class TasksCubit extends Cubit<TasksState> {
  final TaskClient _taskClient;
  final RetryPolicy _retryPolicy;
  final AuthCubit _authCubit;
  final SpotifyClient _spotifyClient;

  TasksCubit({
    required SpotifyClient spotifyClient,
    required TokenService tokenService,
    required TaskClient taskClient,
    required AuthCubit authCubit,
  })  : _taskClient = taskClient,
        _retryPolicy = RetryPolicy(tokenService, spotifyClient),
        _authCubit = authCubit,
        _spotifyClient = spotifyClient,
        super(TasksInitial());

  Future<void> fetchTasks() async {
    emit(TasksLoading(state.tasks, state.userPlaylists));
    try {
      final tasks = await _retryPolicy.execute(
        (token) => _taskClient.getTasks(token),
      );

      for (final task in tasks) {
        task.taskItems = await _retryPolicy.execute(
          (token) => _taskClient.getTaskItems(token, task.id),
        );

        task.addedItems = await _retryPolicy.execute(
          (token) => _taskClient.getAddedItems(token, task.id),
        );
      }

      final userPlaylists = await _retryPolicy.execute(
        (token) => _spotifyClient.getUserPlaylists(token),
      );

      emit(TasksLoadingSuccess(tasks, userPlaylists));
    } on UnauthorizedException {
      _authCubit.logout();
    } catch (e) {
      emit(TasksLoadingError());
    }
  }

  Future<void> deleteTask(Task task) async {
    emit(TasksLoading(state.tasks, state.userPlaylists));

    try {
      await _retryPolicy.execute(
        (token) => _taskClient.deleteTask(token, task.id),
      );
      fetchTasks();
    } on UnauthorizedException {
      _authCubit.logout();
    } catch (e) {
      emit(TasksDeletionError(state.tasks, state.userPlaylists));
    }
  }

  Future<void> executeTask(Task task) async {
    emit(TasksLoading(state.tasks, state.userPlaylists));

    try {
      await _retryPolicy.execute(
        (token) => _taskClient.executeTask(token, task.id),
      );
      fetchTasks();
    } on UnauthorizedException {
      _authCubit.logout();
    } catch (e) {
      emit(TasksExecutionError(state.tasks, state.userPlaylists));
    }
  }
}
