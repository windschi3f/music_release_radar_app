part of 'tasks_cubit.dart';

@immutable
sealed class TasksState {
  final List<Task> tasks;
  final List<SpotifyPlaylist> userPlaylists;

  const TasksState({this.tasks = const [], this.userPlaylists = const []});
}

final class TasksInitial extends TasksState {}

final class TasksLoading extends TasksState {
  const TasksLoading(List<Task> tasks, List<SpotifyPlaylist> userPlaylists)
      : super(tasks: tasks, userPlaylists: userPlaylists);
}

final class TasksLoadingSuccess extends TasksState {
  const TasksLoadingSuccess(
      List<Task> tasks, List<SpotifyPlaylist> userPlaylists)
      : super(tasks: tasks, userPlaylists: userPlaylists);
}

final class TasksLoadingError extends TasksState {}

final class TasksDeletionError extends TasksState {
  const TasksDeletionError(
      List<Task> tasks, List<SpotifyPlaylist> userPlaylists)
      : super(tasks: tasks, userPlaylists: userPlaylists);
}

final class TasksExecutionError extends TasksState {
  const TasksExecutionError(
      List<Task> tasks, List<SpotifyPlaylist> userPlaylists)
      : super(tasks: tasks, userPlaylists: userPlaylists);
}
