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
  final List<SpotifyPlaylist> selectedPlaylists;

  PlaylistSelectionState(
      {required this.selectedArtists,
      required this.userPlaylists,
      required this.selectedPlaylists});

  PlaylistSelectionState copyWith({
    List<SpotifyArtist>? selectedArtists,
    List<SpotifyPlaylist>? userPlaylists,
    List<SpotifyPlaylist>? selectedPlaylists,
  }) {
    return PlaylistSelectionState(
      selectedArtists: selectedArtists ?? this.selectedArtists,
      userPlaylists: userPlaylists ?? this.userPlaylists,
      selectedPlaylists: selectedPlaylists ?? this.selectedPlaylists,
    );
  }
}
