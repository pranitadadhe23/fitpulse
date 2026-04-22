class ActivitySession {
  final String id;
  final String type;
  final double distance;
  final Duration duration;
  final double calories;
  final double avgPace;
  final DateTime date;
  final List<double> paceHistory;

  ActivitySession({
    required this.id,
    required this.type,
    required this.distance,
    required this.duration,
    required this.calories,
    required this.avgPace,
    required this.date,
    required this.paceHistory,
  });
}