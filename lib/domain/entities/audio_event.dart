enum EventType { laugh, cry }

class AudioEvent {
  final String id;
  final String recordingId;
  final EventType type;
  final double timestamp;
  final double score;

  AudioEvent({
    required this.id,
    required this.recordingId,
    required this.type,
    required this.timestamp,
    required this.score,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'recordingId': recordingId,
    'type': type.name,
    'timestamp': timestamp,
    'score': score,
  };

  factory AudioEvent.fromJson(Map<String, dynamic> json) => AudioEvent(
    id: json['id'] as String,
    recordingId: json['recordingId'] as String,
    type: EventType.values.byName(json['type'] as String),
    timestamp: (json['timestamp'] as num).toDouble(),
    score: (json['score'] as num).toDouble(),
  );
}
