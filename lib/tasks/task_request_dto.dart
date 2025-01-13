class TaskRequestDto {
  final String name;
  final String platform;
  final int executionIntervalDays;
  final DateTime checkFrom;
  final bool active;
  final String playlistId;
  final String refreshToken;

  TaskRequestDto({
    required this.name,
    this.platform = 'SPOTIFY',
    required this.executionIntervalDays,
    required this.checkFrom,
    this.active = true,
    required this.playlistId,
    required this.refreshToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'platform': platform,
      'executionIntervalDays': executionIntervalDays,
      'checkFrom': checkFrom.toUtc().toIso8601String(),
      'active': active,
      'playlistId': playlistId,
      'refreshToken': refreshToken,
    };
  }
}
