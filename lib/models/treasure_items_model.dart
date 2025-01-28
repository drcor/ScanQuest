/// Table name of the TreasureItems model
const String tableTreasureItems = 'items';

/// TreasureItem table fields
mixin TreasureItemFields {
  static final List<String> allValues = [
    id,
    nfcId,
    name,
    description,
    image,
    experience,
    collectedOn,
    isFound,
  ];
  static const String id = 'id';
  static const String nfcId = 'nfc_id';
  static const String name = 'name';
  static const String description = 'description';
  static const String image = 'image';
  static const String experience = 'experience';
  static const String collectedOn = 'collected_on';
  static const String isFound = 'is_found';
}

class TreasureItem {
  int? id;
  String nfcId;
  String name;
  String? description;
  String image;
  int experience;
  DateTime collectedOn;
  bool isFound;

  TreasureItem({
    this.id,
    required this.nfcId,
    required this.name,
    this.description,
    required this.image,
    required this.experience,
    required this.collectedOn,
    required this.isFound,
  });

  /// Create a TreasureItem from a json map
  factory TreasureItem.fromJson(Map<String, dynamic> json) {
    return TreasureItem(
      id: json[TreasureItemFields.id] as int?,
      nfcId: json[TreasureItemFields.nfcId] as String,
      name: json[TreasureItemFields.name] as String,
      description: json[TreasureItemFields.description] as String?,
      image: json[TreasureItemFields.image] as String,
      experience: json[TreasureItemFields.experience] as int,
      collectedOn:
          DateTime.parse(json[TreasureItemFields.collectedOn] as String),
      isFound: json[TreasureItemFields.isFound] == 1 ? true : false,
    );
  }

  /// Create a json map from a TreasureItem
  Map<String, dynamic> toJson() {
    return {
      TreasureItemFields.id: id,
      TreasureItemFields.nfcId: nfcId,
      TreasureItemFields.name: name,
      TreasureItemFields.description: description,
      TreasureItemFields.image: image,
      TreasureItemFields.experience: experience,
      TreasureItemFields.collectedOn: collectedOn.toIso8601String(),
      TreasureItemFields.isFound: isFound ? 1 : 0, // Fix for SQLite
    };
  }
}
