class TaskItemRequestDto {
  final String itemType;
  final String externalReferenceId;

  TaskItemRequestDto({
    this.itemType = 'ARTIST',
    required this.externalReferenceId,
  });

  Map<String, dynamic> toJson() {
    return {
      'itemType': itemType,
      'externalReferenceId': externalReferenceId,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TaskItemRequestDto &&
        other.externalReferenceId == externalReferenceId;
  }

  @override
  int get hashCode => itemType.hashCode ^ externalReferenceId.hashCode;
}
