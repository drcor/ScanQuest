/// Table name of the User model
const String tableUser = 'user';

/// User table fields
mixin UserFields {
  static final List<String> allValues = [
    id,
    name,
    lastModification,
    experience,
  ];
  static const String id = 'id';
  static const String name = 'name';
  static const String lastModification = 'last_modification';
  static const String experience = 'experience';
}

class User {
  int? id;
  String name;
  DateTime lastModification;
  int experience;

  User({
    this.id,
    required this.name,
    required this.lastModification,
    required this.experience,
  });

  /// Create a User from a json map
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json[UserFields.id] as int?,
      name: json[UserFields.name] as String,
      lastModification:
          DateTime.parse(json[UserFields.lastModification] as String),
      experience: json[UserFields.experience] as int,
    );
  }

  /// Create a json map from a User
  Map<String, dynamic> toJson() {
    return {
      UserFields.id: id,
      UserFields.name: name,
      UserFields.lastModification: lastModification.toIso8601String(),
      UserFields.experience: experience,
    };
  }
}
