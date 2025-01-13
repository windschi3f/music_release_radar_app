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

  void loadArtistsSelection() {
    if (state is PlaylistSelectionState) {
      emit(ArtistSelectionState(
        searchResults: [],
        selectedArtists: (state as PlaylistSelectionState).selectedArtists,
      ));
    } else {
      emit(ArtistSelectionState(searchResults: [], selectedArtists: []));
    }
  }

  void searchArtists(String query) async {
    final currentState = state as ArtistSelectionState;

    try {
      final artists = await _retryPolicy.execute(
        (token) => _spotifyClient.searchArtists(token, query),
      );
      emit(ArtistSelectionState(
        searchResults: artists,
        selectedArtists: currentState.selectedArtists,
      ));
    } on UnauthorizedException {
      _authCubit.logout();
    } on Exception catch (e) {
      emit(TaskFormError(e.toString()));
    }
  }

  void toggleArtistSelection(SpotifyArtist artist) {
    final currentState = state as ArtistSelectionState;
    final isSelected = currentState.selectedArtists.contains(artist);
    final updatedSelection = isSelected
        ? currentState.selectedArtists.where((a) => a.id != artist.id).toList()
        : [...currentState.selectedArtists, artist];

    emit(currentState.copyWith(selectedArtists: updatedSelection));
  }

  Future<void> loadPlaylistSelection() async {
    final currentState = state as ArtistSelectionState;

    try {
      final userPlaylists = await _retryPolicy.execute(
        (token) => _spotifyClient.getUserPlaylists(token),
      );
      emit(PlaylistSelectionState(
        selectedArtists: currentState.selectedArtists,
        userPlaylists: userPlaylists,
        filteredPlaylists: userPlaylists,
        selectedPlaylist: null,
      ));
    } on UnauthorizedException {
      _authCubit.logout();
    } on Exception catch (e) {
      emit(TaskFormError(e.toString()));
    }
  }

  void selectPlaylist(SpotifyPlaylist playlist) {
    final currentState = state as PlaylistSelectionState;
    emit(currentState.copyWith(selectedPlaylist: playlist));
  }

  void filterPlaylists(String query) {
    final currentState = state as PlaylistSelectionState;
    final filteredPlaylists = currentState.userPlaylists
        .where((playlist) => playlist.name.toLowerCase().contains(query))
        .toList();

    emit(currentState.copyWith(filteredPlaylists: filteredPlaylists));
  }

  void saveTask(
      {required String name,
      required DateTime checkFrom,
      required int executionIntervalDays}) async {
    final currentState = state as PlaylistSelectionState;
    final selectedPlaylist = currentState.selectedPlaylist;
    final selectedArtists = currentState.selectedArtists;
    emit(TaskFormLoading());

    final taskRequestDto = TaskRequestDto(
      name: name,
      checkFrom: checkFrom,
      executionIntervalDays: executionIntervalDays,
      playlistId: selectedPlaylist!.id,
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
          selectedArtists
              .map((artist) => TaskItem(externalReferenceId: artist.id))
              .toList()));
      emit(TaskFormSaved());
    } on UnauthorizedException {
      _authCubit.logout();
    } on Exception catch (e) {
      emit(TaskFormError(e.toString()));
    }
  }
}
