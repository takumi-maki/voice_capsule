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
  final List<String> childIds;
  final int duration;
  final List<double> waveformBars;

  Recording({
    required this.id,
    required this.filePath,
    required this.createdAt,
    required this.title,
    required this.location,
    required this.childIds,
    required this.duration,
    this.waveformBars = const [],
  });

  Recording copyWith({
    String? id,
    String? filePath,
    DateTime? createdAt,
    String? title,
    BackgroundType? location,
    List<String>? childIds,
    int? duration,
    List<double>? waveformBars,
  }) => Recording(
    id: id ?? this.id,
    filePath: filePath ?? this.filePath,
    createdAt: createdAt ?? this.createdAt,
    title: title ?? this.title,
    location: location ?? this.location,
    childIds: childIds ?? this.childIds,
    duration: duration ?? this.duration,
    waveformBars: waveformBars ?? this.waveformBars,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'filePath': filePath,
    'createdAt': createdAt.toIso8601String(),
    'title': title,
    'location': location.name,
    'childIds': childIds,
    'duration': duration,
    'waveformBars': waveformBars,
  };

  factory Recording.fromJson(Map<String, dynamic> json) {
    // 既存データの移行: childId → childIds
    List<String> ids;
    if (json.containsKey('childIds')) {
      ids = List<String>.from(json['childIds']);
    } else if (json.containsKey('childId')) {
      ids = [json['childId'] as String];
    } else {
      ids = [];
    }

    return Recording(
      id: json['id'],
      filePath: json['filePath'],
      createdAt: DateTime.parse(json['createdAt']),
      title: json['title'],
      location: BackgroundType.values.byName(json['location']),
      childIds: ids,
      duration: json['duration'],
      waveformBars: List<double>.from(json['waveformBars'] ?? []),
    );
  }
}
