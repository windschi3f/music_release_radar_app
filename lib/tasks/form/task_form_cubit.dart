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
      emit(ArtistSelectionState(TaskFormData(), [], [], false, ""));
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
      emit(ArtistSelectionState(state.formData, [], [], false, ""));
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
          [],
          [],
          false,
          ""));
    } on UnauthorizedException {
      _authCubit.logout();
    } on Exception catch (e) {
      emit(TaskFormError(state.formData, e.toString()));
    }
  }

  void onSearchQueryChanged(String query) async {
    if (state is! ArtistSelectionState) return;

    final currentState = state as ArtistSelectionState;

    if (currentState.isFollowedArtistsMode) {
      filterFollowedArtists(query);
    } else {
      searchArtists(query);
    }
  }

  void searchArtists(String query) async {
    if (state is! ArtistSelectionState) return;
    final currentState = state as ArtistSelectionState;

    if (query.isEmpty) {
      emit(currentState.copyWith(
        searchResults: [],
        searchQuery: query,
      ));
      return;
    }
    emit(TaskFormLoading(state.formData));
    try {
      final artists = await _retryPolicy.execute(
        (token) => _spotifyClient.searchArtists(token, query),
      );
      emit(currentState.copyWith(
        searchResults: artists,
        searchQuery: query,
      ));
    } on UnauthorizedException {
      _authCubit.logout();
    } on Exception catch (e) {
      emit(TaskFormError(state.formData, e.toString()));
    }
  }

  void filterFollowedArtists(String query) {
    if (state is! ArtistSelectionState) return;
    final currentState = state as ArtistSelectionState;

    final filteredArtists = currentState.followedArtists
        .where(
            (artist) => artist.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    emit(currentState.copyWith(
      searchResults: filteredArtists,
      searchQuery: query,
    ));
  }

  void toggleFollowedArtistsMode() async {
    if (state is! ArtistSelectionState) return;
    final currentState = state as ArtistSelectionState;
    final query = currentState.searchQuery;

    if (!currentState.isFollowedArtistsMode) {
      if (currentState.followedArtists.isEmpty) {
        emit(TaskFormLoading(state.formData));
        try {
          final followedArtists = await _retryPolicy.execute(
            (token) => _spotifyClient.getUserFollowedArtists(token),
          );
          final filtered = query.isEmpty
              ? followedArtists
              : followedArtists
                  .where((artist) =>
                      artist.name.toLowerCase().contains(query.toLowerCase()))
                  .toList();
          emit(currentState.copyWith(
            searchResults: filtered,
            followedArtists: followedArtists,
            isFollowedArtistsMode: true,
          ));
        } on UnauthorizedException {
          _authCubit.logout();
        } on Exception catch (e) {
          emit(TaskFormError(state.formData, e.toString()));
        }
      } else {
        final filtered = query.isEmpty
            ? currentState.followedArtists
            : currentState.followedArtists
                .where((artist) =>
                    artist.name.toLowerCase().contains(query.toLowerCase()))
                .toList();
        emit(currentState.copyWith(
          searchResults: filtered,
          isFollowedArtistsMode: true,
        ));
      }
    } else {
      emit(currentState.copyWith(
        isFollowedArtistsMode: false,
        searchResults: [],
      ));
      if (query.isNotEmpty) {
        searchArtists(query);
      }
    }
}

  void toggleArtistSelection(SpotifyArtist artist) {
    final selectedArtists = state.formData.selectedArtists;
    final isSelected = selectedArtists.contains(artist);
    final updatedSelection = isSelected
        ? selectedArtists.where((a) => a.id != artist.id).toList()
        : [...selectedArtists, artist];

    final artistSelectionState = state as ArtistSelectionState;
    emit(ArtistSelectionState(
        state.formData.copyWith(selectedArtists: updatedSelection),
        artistSelectionState.searchResults,
        artistSelectionState.followedArtists,
        artistSelectionState.isFollowedArtistsMode,
        artistSelectionState.searchQuery));
  }

  Future<void> loadPlaylistSelection() async {
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

  void createPlaylist(String name, bool isPublic) async {
    emit(TaskFormLoading(state.formData));

    try {
      final user = _authCubit.user!;
      await _retryPolicy.execute(
        (token) =>
            _spotifyClient.createPlaylist(token, user.id, name, isPublic),
      );
      loadPlaylistSelection();
    } on UnauthorizedException {
      _authCubit.logout();
    } on Exception catch (e) {
      emit(TaskFormError(state.formData, e.toString()));
    }
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
            _taskClient.addTaskItems(token, task.id, selectedArtistIds));
        _retryPolicy
            .execute((token) => _taskClient.executeTask(token, task.id));
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
