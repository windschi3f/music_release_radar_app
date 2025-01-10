class Task {
  final String id;
  final String name;
  final String platform;
  final int executionIntervalDays;
  final DateTime lastTimeExecuted;
  final DateTime checkFrom;
  final bool active;
  final String playlistId;

  Task({
    required this.id,
    required this.name,
    required this.platform,
    required this.executionIntervalDays,
    required this.lastTimeExecuted,
    required this.checkFrom,
    required this.active,
    required this.playlistId,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      name: json['name'],
      platform: json['platform'],
      executionIntervalDays: json['executionIntervalDays'],
      lastTimeExecuted: DateTime.parse(json['lastTimeExecuted']),
      checkFrom: DateTime.parse(json['checkFrom']),
      active: json['active'],
      playlistId: json['playlistId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'platform': platform,
      'executionIntervalDays': executionIntervalDays,
      'lastTimeExecuted': lastTimeExecuted.toIso8601String(),
      'checkFrom': checkFrom.toIso8601String(),
      'active': active,
      'playlistId': playlistId,
    };
  }
}
