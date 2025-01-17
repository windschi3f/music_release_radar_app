import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_release_radar_app/auth/auth_cubit.dart';
import 'package:music_release_radar_app/core/retry_policy.dart';
import 'package:music_release_radar_app/core/token_service.dart';
import 'package:music_release_radar_app/core/unauthorized_exception.dart';
import 'package:music_release_radar_app/spotify/model/spotify_artist.dart';
import 'package:music_release_radar_app/spotify/model/spotify_playlist.dart';
import 'package:music_release_radar_app/spotify/spotify_client.dart';
import 'package:music_release_radar_app/tasks/task.dart';
import 'package:music_release_radar_app/tasks/task_client.dart';
import 'package:music_release_radar_app/tasks/task_item_request_dto.dart';
import 'package:music_release_radar_app/tasks/task_request_dto.dart';

part 'task_form_state.dart';

class TaskFormCubit extends Cubit<TaskFormState> {
  final SpotifyClient _spotifyClient;
  final RetryPolicy _retryPolicy;
  final AuthCubit _authCubit;
  final TaskClient _taskClient;

  TaskFormCubit({
    required SpotifyClient spotifyClient,
    required TokenService tokenService,
    required TaskClient taskClient,
    required AuthCubit authCubit,
  })  : _spotifyClient = spotifyClient,
        _retryPolicy = RetryPolicy(tokenService, spotifyClient),
        _authCubit = authCubit,
        _taskClient = taskClient,
        super(TaskFormInitial());

  void navigateForward() {
    if (state is TaskFormInitial || state is TaskFormSaved) {
      emit(ArtistSelectionState(TaskFormData(), []));
    } else if (state is ArtistSelectionState) {
      loadPlaylistSelection();
    } else if (state is PlaylistSelectionState) {
      emit(TaskConfigState(state.formData));
    }
  }

  void navigateBack() {
    if (state is ArtistSelectionState) {
      emit(TaskFormInitial());
    } else if (state is PlaylistSelectionState) {
      emit(ArtistSelectionState(state.formData, []));
    } else if (state is TaskConfigState) {
      emit(
          PlaylistSelectionState(state.formData, state.formData.userPlaylists));
    }
  }

  void modifyTask(Task task) async {
    emit(TaskFormLoading(TaskFormData()));

    try {
      final selectedArtists = await _retryPolicy.execute(
        (token) => _spotifyClient.getSeveralArtists(token,
            task.taskItems.map((item) => item.externalReferenceId).toList()),
      );
      final userPlaylists = await _retryPolicy.execute(
        (token) => _spotifyClient.getUserPlaylists(token),
      );

      emit(ArtistSelectionState(
          TaskFormData(
              selectedArtists: selectedArtists,
              userPlaylists: userPlaylists,
              selectedPlaylist: userPlaylists.firstWhere(
                (p) => p.id == task.playlistId,
              ),
              modifyTask: task),
          []));
    } on UnauthorizedException {
      _authCubit.logout();
    } on Exception catch (e) {
      emit(TaskFormError(state.formData, e.toString()));
    }
  }

  void searchArtists(String query) async {
    if (query.isEmpty) {
      emit(ArtistSelectionState(state.formData, []));
      return;
    }

    emit(TaskFormLoading(state.formData));
    try {
      final artists = await _retryPolicy.execute(
        (token) => _spotifyClient.searchArtists(token, query),
      );
      emit(ArtistSelectionState(state.formData, artists));
    } on UnauthorizedException {
      _authCubit.logout();
    } on Exception catch (e) {
      emit(TaskFormError(state.formData, e.toString()));
    }
  }

  void toggleArtistSelection(SpotifyArtist artist) {
    final selectedArtists = state.formData.selectedArtists;

    final isSelected = selectedArtists.contains(artist);
    final updatedSelection = isSelected
        ? selectedArtists.where((a) => a.id != artist.id).toList()
        : [...selectedArtists, artist];

    emit(ArtistSelectionState(
        state.formData.copyWith(selectedArtists: updatedSelection),
        (state as ArtistSelectionState).searchResults));
  }

  Future<void> loadPlaylistSelection() async {
    if (state.formData.userPlaylists.isNotEmpty) {
      emit(
          PlaylistSelectionState(state.formData, state.formData.userPlaylists));
      return;
    }

    emit(TaskFormLoading(state.formData));
    try {
      final userPlaylists = await _retryPolicy.execute(
        (token) => _spotifyClient.getUserPlaylists(token),
      );

      emit(PlaylistSelectionState(
          state.formData.copyWith(userPlaylists: userPlaylists),
          userPlaylists));
    } on UnauthorizedException {
      _authCubit.logout();
    } on Exception catch (e) {
      emit(TaskFormError(state.formData, e.toString()));
    }
  }

  void selectPlaylist(SpotifyPlaylist playlist) {
    emit(PlaylistSelectionState(
        state.formData.copyWith(selectedPlaylist: playlist),
        (state as PlaylistSelectionState).filteredPlaylists));
  }

  void filterPlaylists(String query) {
    final filteredPlaylists = state.formData.userPlaylists
        .where((playlist) => playlist.name.toLowerCase().contains(query))
        .toList();

    emit(PlaylistSelectionState(state.formData, filteredPlaylists));
  }

  void saveTask(
      {required String name,
      required DateTime checkFrom,
      required int executionIntervalDays}) async {
    emit(TaskFormLoading(state.formData));

    final taskRequestDto = TaskRequestDto(
      name: name,
      checkFrom: checkFrom,
      executionIntervalDays: executionIntervalDays,
      playlistId: state.formData.selectedPlaylist!.id,
    );
    final selectedArtistIds = state.formData.selectedArtists
        .map((artist) => TaskItemRequestDto(externalReferenceId: artist.id))
        .toList();

    try {
      if (state.formData.modifyTask == null) {
        final task = await _retryPolicy.execute(
          (token) => _taskClient.createTask(token, taskRequestDto),
        );
        await _retryPolicy.execute((token) =>
            _taskClient.addTaskItems(token, task.id,
            selectedArtistIds));
      } else {
        await _retryPolicy.execute(
          (token) => _taskClient.updateTask(
              token, state.formData.modifyTask!.id, taskRequestDto),
        );
        await _retryPolicy.execute((token) => _taskClient.updateTaskItems(
            token, state.formData.modifyTask!.id, selectedArtistIds));
      }
      emit(TaskFormSaved(state.formData));
    } on UnauthorizedException {
      _authCubit.logout();
    } on Exception catch (e) {
      emit(TaskFormError(state.formData, e.toString()));
    }
  }
}
