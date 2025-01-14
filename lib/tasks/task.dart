import 'package:music_release_radar_app/tasks/added_item.dart';
import 'package:music_release_radar_app/tasks/task_item.dart';

class Task {
  final int id;
  final String name;
  final String platform;
  final int executionIntervalDays;
  final DateTime? lastTimeExecuted;
  final DateTime checkFrom;
  final bool active;
  final String playlistId;
  List<TaskItem> taskItems;
  List<AddedItem> addedItems;

  Task({
    required this.id,
    required this.name,
    required this.platform,
    required this.executionIntervalDays,
    required this.lastTimeExecuted,
    required this.checkFrom,
    required this.active,
    required this.playlistId,
    this.taskItems = const [],
    this.addedItems = const [],
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      name: json['name'],
      platform: json['platform'],
      executionIntervalDays: json['executionIntervalDays'],
      lastTimeExecuted: json['lastTimeExecuted'] != null
          ? DateTime.parse(json['lastTimeExecuted'])
          : null,
      checkFrom: DateTime.parse(json['checkFrom']),
      active: json['active'],
      playlistId: json['playlistId'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Task && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
