class TaskItem {
  final int id;
  final String itemType;
  final String externalReferenceId;

  TaskItem({
    required this.id,
    this.itemType = 'ARTIST',
    required this.externalReferenceId,
  });

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id'],
      itemType: json['itemType'],
      externalReferenceId: json['externalReferenceId'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TaskItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
