part of 'tasks_cubit.dart';

@immutable
sealed class TasksState {}

final class TasksInitial extends TasksState {}

final class TasksLoading extends TasksState {}

final class TasksSuccess extends TasksState {
  final List<Task> tasks;

  TasksSuccess(this.tasks);
}

final class TasksError extends TasksState {
  final String message;

  TasksError(this.message);
}
