import 'package:music_release_radar_app/tasks/added_items/added_item_type.dart';

class AddedItem {
  final int id;
  final String externalId;
  final DateTime addedAt;
  final AddedItemType itemType;

  AddedItem({
    required this.id,
    required this.externalId,
    required this.addedAt,
    required this.itemType,
  });

  factory AddedItem.fromJson(Map<String, dynamic> json) {
    return AddedItem(
      id: json['id'],
      externalId: json['externalId'],
      addedAt: DateTime.parse(json['addedAt']),
      itemType: AddedItemType.values.firstWhere(
          (e) => e.toString() == 'AddedItemType.${json['itemType']}'),
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
