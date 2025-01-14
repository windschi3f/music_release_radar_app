part of 'tasks_cubit.dart';

@immutable
sealed class TasksState {}

final class TasksInitial extends TasksState {}

final class TasksLoading extends TasksState {}

final class TasksSuccess extends TasksState {
  final List<Task> tasks;
  final List<SpotifyPlaylist> userPlaylists;

  TasksSuccess(this.tasks, this.userPlaylists);
}

final class TasksError extends TasksState {
  final String message;

  TasksError(this.message);
}
