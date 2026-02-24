enum CharacterType {
  father,
  mother,
  son,
  daughter,
}

enum BackgroundType {
  house,
  car,
  park,
}

class Recording {
  final String id;
  final String filePath;
  final DateTime createdAt;
  final CharacterType character;
  final BackgroundType background;
  final int duration;

  Recording({
    required this.id,
    required this.filePath,
    required this.createdAt,
    required this.character,
    required this.background,
    required this.duration,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'filePath': filePath,
        'createdAt': createdAt.toIso8601String(),
        'character': character.name,
        'background': background.name,
        'duration': duration,
      };

  factory Recording.fromJson(Map<String, dynamic> json) => Recording(
        id: json['id'],
        filePath: json['filePath'],
        createdAt: DateTime.parse(json['createdAt']),
        character: CharacterType.values.byName(json['character']),
        background: BackgroundType.values.byName(json['background']),
        duration: json['duration'],
      );
}
