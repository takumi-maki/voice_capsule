enum HeatmapIntensity { none, low, medium, high }

class DailyEmotionSummary {
  final DateTime date;
  final int laughCount;
  final int cryCount;
  final int totalPoints;

  const DailyEmotionSummary({
    required this.date,
    required this.laughCount,
    required this.cryCount,
    required this.totalPoints,
  });

  int get totalEvents => laughCount + cryCount;

  HeatmapIntensity get intensity {
    if (totalEvents == 0) return HeatmapIntensity.none;
    if (totalEvents <= 2) return HeatmapIntensity.low;
    if (totalEvents <= 5) return HeatmapIntensity.medium;
    return HeatmapIntensity.high;
  }
}
