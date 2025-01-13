import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_release_radar_app/auth/auth_cubit.dart';
import 'package:music_release_radar_app/core/retry_policy.dart';
import 'package:music_release_radar_app/core/token_service.dart';
import 'package:music_release_radar_app/core/unauthorized_exception.dart';
import 'package:music_release_radar_app/spotify/model/spotify_artist.dart';
import 'package:music_release_radar_app/spotify/model/spotify_playlist.dart';
import 'package:music_release_radar_app/spotify/spotify_client.dart';
import 'package:music_release_radar_app/tasks/task_client.dart';
import 'package:music_release_radar_app/tasks/task_item.dart';
import 'package:music_release_radar_app/tasks/task_request_dto.dart';

part 'task_form_state.dart';

class TaskFormCubit extends Cubit<TaskFormState> {
  final SpotifyClient _spotifyClient;
  final RetryPolicy _retryPolicy;
  final AuthCubit _authCubit;
  final TokenService _tokenService;
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
        _tokenService = tokenService,
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
      refreshToken: await _tokenService
          .retrieveTokens()
          .then((tokens) => tokens[TokenService.refreshTokenKey]!),
    );

    try {
      final task = await _retryPolicy.execute(
        (token) => _taskClient.createTask(token, taskRequestDto),
      );
      await _retryPolicy.execute((token) => _taskClient.addTaskItems(
          token,
          task.id,
          state.formData.selectedArtists
              .map((artist) => TaskItem(externalReferenceId: artist.id))
              .toList()));
      emit(TaskFormSaved(state.formData));
    } on UnauthorizedException {
      _authCubit.logout();
    } on Exception catch (e) {
      emit(TaskFormError(state.formData, e.toString()));
    }
  }
}
