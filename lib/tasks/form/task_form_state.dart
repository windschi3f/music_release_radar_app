part of 'task_form_cubit.dart';

@immutable
abstract class TaskFormState {}

class TaskFormInitial extends TaskFormState {}

class TaskFormLoading extends TaskFormState {}

class TaskFormError extends TaskFormState {
  final String message;
  TaskFormError(this.message);
}

class ArtistSelectionState extends TaskFormState {
  final List<SpotifyArtist> searchResults;
  final List<SpotifyArtist> selectedArtists;

  ArtistSelectionState({
    required this.searchResults,
    required this.selectedArtists,
  });

  ArtistSelectionState copyWith({
    List<SpotifyArtist>? searchResults,
    List<SpotifyArtist>? selectedArtists,
  }) {
    return ArtistSelectionState(
      searchResults: searchResults ?? this.searchResults,
      selectedArtists: selectedArtists ?? this.selectedArtists,
    );
  }
}

class PlaylistSelectionState extends TaskFormState {
  final List<SpotifyArtist> selectedArtists;
  final List<SpotifyPlaylist> userPlaylists;
  final List<SpotifyPlaylist> filteredPlaylists;
  final SpotifyPlaylist? selectedPlaylist;

  PlaylistSelectionState(
      {required this.selectedArtists,
      required this.userPlaylists,
      required this.filteredPlaylists,
      required this.selectedPlaylist});

  PlaylistSelectionState copyWith({
    List<SpotifyArtist>? selectedArtists,
    List<SpotifyPlaylist>? userPlaylists,
    List<SpotifyPlaylist>? filteredPlaylists,
    SpotifyPlaylist? selectedPlaylist,
  }) {
    return PlaylistSelectionState(
      selectedArtists: selectedArtists ?? this.selectedArtists,
      userPlaylists: userPlaylists ?? this.userPlaylists,
      filteredPlaylists: filteredPlaylists ?? this.filteredPlaylists,
      selectedPlaylist: selectedPlaylist ?? this.selectedPlaylist,
    );
  }
}

class TaskFormSaved extends TaskFormState {}
