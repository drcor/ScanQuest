const String tableTreasureItems = 'items';

mixin TreasureItemFields {
  static final List<String> allValues = [
    id,
    nfcId,
    name,
    description,
    image,
    collectedOn,
    isFound,
  ];
  static const String id = 'id';
  static const String nfcId = 'nfc_id';
  static const String name = 'name';
  static const String description = 'description';
  static const String image = 'image';
  static const String collectedOn = 'collected_on';
  static const String isFound = 'is_found';
}

class TreasureItem {
  int? id;
  String nfcId;
  String name;
  String? description;
  String image;
  DateTime collectedOn;
  bool isFound;

  TreasureItem({
    this.id,
    required this.nfcId,
    required this.name,
    this.description,
    required this.image,
    required this.collectedOn,
    required this.isFound,
  });

  factory TreasureItem.fromJson(Map<String, dynamic> json) {
    return TreasureItem(
      id: json[TreasureItemFields.id] as int?,
      nfcId: json[TreasureItemFields.nfcId] as String,
      name: json[TreasureItemFields.name] as String,
      description: json[TreasureItemFields.description] as String?,
      image: json[TreasureItemFields.image] as String,
      collectedOn:
          DateTime.parse(json[TreasureItemFields.collectedOn] as String),
      isFound: json[TreasureItemFields.isFound] == 1 ? true : false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      TreasureItemFields.id: id,
      TreasureItemFields.nfcId: nfcId,
      TreasureItemFields.name: name,
      TreasureItemFields.description: description,
      TreasureItemFields.image: image,
      TreasureItemFields.collectedOn: collectedOn.toIso8601String(),
      TreasureItemFields.isFound: isFound ? 1 : 0, // Fix for SQLite
    };
  }

  TreasureItem copy({
    int? id,
    String? nfcId,
    String? name,
    String? description,
    String? image,
    DateTime? collectedOn,
    bool? isFound,
  }) =>
      TreasureItem(
        id: id ?? this.id,
        nfcId: nfcId ?? this.nfcId,
        name: name ?? this.name,
        description: description ?? this.description,
        image: image ?? this.image,
        collectedOn: collectedOn ?? this.collectedOn,
        isFound: isFound ?? this.isFound,
      );
}
