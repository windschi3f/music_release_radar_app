part of 'task_form_cubit.dart';

@immutable
abstract class TaskFormState {
  final TaskFormData formData;
  const TaskFormState(this.formData);
}

class TaskFormData {
  final List<SpotifyArtist> selectedArtists;
  final List<SpotifyPlaylist> userPlaylists;
  final SpotifyPlaylist? selectedPlaylist;

  const TaskFormData({
    this.selectedArtists = const [],
    this.userPlaylists = const [],
    this.selectedPlaylist,
  });

  TaskFormData copyWith({
    List<SpotifyArtist>? selectedArtists,
    List<SpotifyPlaylist>? userPlaylists,
    SpotifyPlaylist? selectedPlaylist,
  }) {
    return TaskFormData(
      selectedArtists: selectedArtists ?? this.selectedArtists,
      userPlaylists: userPlaylists ?? this.userPlaylists,
      selectedPlaylist: selectedPlaylist ?? this.selectedPlaylist,
    );
  }
}

class TaskFormInitial extends TaskFormState {
  TaskFormInitial() : super(TaskFormData());
}

class TaskFormLoading extends TaskFormState {
  const TaskFormLoading(super.formData);
}

class TaskFormError extends TaskFormState {
  final String message;
  const TaskFormError(super.formData, this.message);
}

class ArtistSelectionState extends TaskFormState {
  final List<SpotifyArtist> searchResults;

  const ArtistSelectionState(super.formData, this.searchResults);
}

class PlaylistSelectionState extends TaskFormState {
  final List<SpotifyPlaylist> filteredPlaylists;

  const PlaylistSelectionState(super.formData, this.filteredPlaylists);
}

class TaskConfigState extends TaskFormState {
  const TaskConfigState(super.formData);
}

class TaskFormSaved extends TaskFormState {
  const TaskFormSaved(super.formData);
}
