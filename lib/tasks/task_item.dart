class TaskItem {
  final String itemType;
  final String externalReferenceId;

  TaskItem({
    this.itemType = 'ARTIST',
    required this.externalReferenceId,
  });

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      itemType: json['itemType'],
      externalReferenceId: json['externalReferenceId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemType': itemType,
      'externalReferenceId': externalReferenceId,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TaskItem &&
        other.itemType == itemType &&
        other.externalReferenceId == externalReferenceId;
  }

  @override
  int get hashCode => itemType.hashCode ^ externalReferenceId.hashCode;
}
