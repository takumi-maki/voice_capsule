enum BackgroundType { house, car, park }

extension BackgroundTypeExtension on BackgroundType {
  String get displayName {
    switch (this) {
      case BackgroundType.house:
        return '家';
      case BackgroundType.car:
        return '車';
      case BackgroundType.park:
        return '公園';
    }
  }
}

class Recording {
  final String id;
  final String filePath;
  final DateTime createdAt;
  final String title;
  final BackgroundType location;
  final String childId;
  final int duration;

  Recording({
    required this.id,
    required this.filePath,
    required this.createdAt,
    required this.title,
    required this.location,
    required this.childId,
    required this.duration,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'filePath': filePath,
    'createdAt': createdAt.toIso8601String(),
    'title': title,
    'location': location.name,
    'childId': childId,
    'duration': duration,
  };

  factory Recording.fromJson(Map<String, dynamic> json) => Recording(
    id: json['id'],
    filePath: json['filePath'],
    createdAt: DateTime.parse(json['createdAt']),
    title: json['title'],
    location: BackgroundType.values.byName(json['location']),
    childId: json['childId'],
    duration: json['duration'],
  );
}
