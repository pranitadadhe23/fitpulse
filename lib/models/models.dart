// lib/models/user_model.dart
class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final double totalDistance;
  final int streak;
  final int totalWorkouts;
  final double totalCalories;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.totalDistance = 0,
    this.streak = 0,
    this.totalWorkouts = 0,
    this.totalCalories = 0,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? 'Athlete',
      photoUrl: map['photoUrl'],
      totalDistance: (map['totalDistance'] ?? 0).toDouble(),
      streak: map['streak'] ?? 0,
      totalWorkouts: map['totalWorkouts'] ?? 0,
      totalCalories: (map['totalCalories'] ?? 0).toDouble(),
      createdAt: map['createdAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'totalDistance': totalDistance,
      'streak': streak,
      'totalWorkouts': totalWorkouts,
      'totalCalories': totalCalories,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  UserModel copyWith({
    String? displayName,
    String? photoUrl,
    double? totalDistance,
    int? streak,
    int? totalWorkouts,
    double? totalCalories,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      totalDistance: totalDistance ?? this.totalDistance,
      streak: streak ?? this.streak,
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      totalCalories: totalCalories ?? this.totalCalories,
      createdAt: createdAt,
    );
  }
}

// lib/models/event_model.dart (append below in same concepts)
class EventModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String location;
  final DateTime date;
  final String imageUrl;
  final int participants;
  final int maxParticipants;
  final double distance;
  final String difficulty;
  bool isRegistered;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.date,
    required this.imageUrl,
    required this.participants,
    required this.maxParticipants,
    required this.distance,
    required this.difficulty,
    this.isRegistered = false,
  });

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id']?.toString() ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? 'Run',
      location: map['location'] ?? '',
      date: map['date'] != null
          ? DateTime.tryParse(map['date'].toString()) ?? DateTime.now()
          : DateTime.now(),
      imageUrl: map['imageUrl'] ?? map['image'] ?? '',
      participants: map['participants'] ?? 0,
      maxParticipants: map['maxParticipants'] ?? 100,
      distance: (map['distance'] ?? 5.0).toDouble(),
      difficulty: map['difficulty'] ?? 'Beginner',
      isRegistered: map['isRegistered'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'location': location,
      'date': date.toIso8601String(),
      'imageUrl': imageUrl,
      'participants': participants,
      'maxParticipants': maxParticipants,
      'distance': distance,
      'difficulty': difficulty,
      'isRegistered': isRegistered,
    };
  }
}

// Activity Session Model
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'distance': distance,
      'duration': duration.inSeconds,
      'calories': calories,
      'avgPace': avgPace,
      'date': date.toIso8601String(),
      'paceHistory': paceHistory,
    };
    
  }
  factory ActivitySession.fromMap(Map<String, dynamic> map) {
  return ActivitySession(
    id: map['id'] ?? '',
    type: map['type'] ?? '',
    distance: (map['distance'] ?? 0).toDouble(),
    duration: Duration(seconds: map['duration'] ?? 0),
    calories: (map['calories'] ?? 0).toDouble(),
    avgPace: (map['avgPace'] ?? 0).toDouble(),
    date: map['date'] != null
        ? DateTime.tryParse(map['date']) ?? DateTime.now()
        : DateTime.now(),
    paceHistory: List<double>.from(
      (map['paceHistory'] ?? []).map((e) => (e as num).toDouble()),
    ),
  );
}
}
