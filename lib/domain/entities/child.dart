class Child {
  final String id;
  final String name;
  final String? photoPath;
  final DateTime createdAt;

  Child({
    required this.id,
    required this.name,
    this.photoPath,
    required this.createdAt,
  });

  // photoPathをnullにクリアしたい場合は clearPhoto: true を渡す
  Child copyWith({String? name, String? photoPath, bool clearPhoto = false}) =>
      Child(
        id: id,
        name: name ?? this.name,
        photoPath: clearPhoto ? null : (photoPath ?? this.photoPath),
        createdAt: createdAt,
      );

  String get initials {
    if (name.isEmpty) return '?';
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'photoPath': photoPath,
    'createdAt': createdAt.toIso8601String(),
  };

  factory Child.fromJson(Map<String, dynamic> json) => Child(
    id: json['id'],
    name: json['name'],
    photoPath: json['photoPath'],
    createdAt: DateTime.parse(json['createdAt']),
  );
}
