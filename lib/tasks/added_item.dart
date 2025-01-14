class AddedItem {
  final int id;
  final String externalId;
  final DateTime addedAt;

  AddedItem({
    required this.id,
    required this.externalId,
    required this.addedAt,
  });

  factory AddedItem.fromJson(Map<String, dynamic> json) {
    return AddedItem(
      id: json['id'],
      externalId: json['externalId'],
      addedAt: DateTime.parse(json['addedAt']),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AddedItem && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
