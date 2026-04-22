// lib/services/event_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fetch events from a public API + supplement with mock data
  Future<List<EventModel>> fetchEvents() async {
    try {
      // Using a public API for demo; swap with real fitness events API
      final response = await http
          .get(
            Uri.parse('https://jsonplaceholder.typicode.com/posts?_limit=8'),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return _mapApiToEvents(data);
      }
      return _getMockEvents();
    } catch (e) {
      // Fallback to mock data if API fails
      return _getMockEvents();
    }
  }

  // Register for an event
  Future<void> registerForEvent({
    required String userId,
    required EventModel event,
  }) async {
    try {
      final registrationRef = _firestore
          .collection('registrations')
          .doc('${userId}_${event.id}');

      await registrationRef.set({
        'userId': userId,
        'eventId': event.id,
        'eventTitle': event.title,
        'eventDate': event.date.toIso8601String(),
        'category': event.category,
        'registeredAt': DateTime.now().toIso8601String(),
      });

      // Update event participant count
      await _firestore
          .collection('events')
          .doc(event.id)
          .set({'participants': FieldValue.increment(1)}, SetOptions(merge: true));
    } catch (e) {
      throw 'Failed to register. Please try again.';
    }
  }

  // Unregister from event
  Future<void> unregisterFromEvent({
    required String userId,
    required String eventId,
  }) async {
    try {
      await _firestore
          .collection('registrations')
          .doc('${userId}_$eventId')
          .delete();
    } catch (e) {
      throw 'Failed to unregister. Please try again.';
    }
  }

  // Check if user is registered
  Future<bool> isRegistered({
    required String userId,
    required String eventId,
  }) async {
    try {
      final doc = await _firestore
          .collection('registrations')
          .doc('${userId}_$eventId')
          .get();
      return doc.exists;
    } catch (e) {
      return false;
    }
  }

  // Get user's registered events
  Future<List<String>> getUserRegistrations(String userId) async {
    try {
      final query = await _firestore
          .collection('registrations')
          .where('userId', isEqualTo: userId)
          .get();
      return query.docs.map((d) => d.data()['eventId'] as String).toList();
    } catch (e) {
      return [];
    }
  }

  List<EventModel> _mapApiToEvents(List<dynamic> data) {
    final categories = ['Run', 'Yoga', 'Cycling', 'Triathlon', 'HIIT'];
    final difficulties = ['Beginner', 'Intermediate', 'Advanced'];
    final locations = [
      'Central Park, NYC',
      'Riverside Trail, LA',
      'Golden Gate, SF',
      'Millennium Park, Chicago',
      'South Beach, Miami',
      'Town Lake, Austin',
      'Discovery Park, Seattle',
      'Memorial Park, Houston',
    ];
    final images = [
      'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800',
      'https://images.unsplash.com/photo-1552196563-55cd4e45efb3?w=800',
      'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800',
      'https://images.unsplash.com/photo-1517963879433-6ad2b056d712?w=800',
      'https://images.unsplash.com/photo-1608138278561-033d0b7b4e9c?w=800',
      'https://images.unsplash.com/photo-1606889464198-fcb18894cf50?w=800',
      'https://images.unsplash.com/photo-1571731956672-f2b94d7dd0cb?w=800',
      'https://images.unsplash.com/photo-1518611012118-696072aa579a?w=800',
    ];

    return data.asMap().entries.map((entry) {
      final i = entry.key;
      final item = entry.value as Map<String, dynamic>;
      final category = categories[i % categories.length];
      return EventModel(
        id: item['id'].toString(),
        title: _getEventTitle(category, i),
        description:
            'Join us for an incredible ${category.toLowerCase()} experience. '
            'Whether you\'re a seasoned athlete or just starting your fitness journey, '
            'this event is designed to challenge and inspire you. Connect with fellow '
            'fitness enthusiasts and push your limits.',
        category: category,
        location: locations[i % locations.length],
        date: DateTime.now().add(Duration(days: 3 + i * 5)),
        imageUrl: images[i % images.length],
        participants: 20 + (i * 13),
        maxParticipants: 100 + (i * 20),
        distance: 5.0 + (i * 2.5),
        difficulty: difficulties[i % difficulties.length],
      );
    }).toList();
  }

  String _getEventTitle(String category, int index) {
    final titles = {
      'Run': ['5K Dawn Dash', 'Neon Night Run', 'Marathon Elite'],
      'Yoga': ['Sunrise Flow', 'Power Yoga Session', 'Zen Master Class'],
      'Cycling': ['Century Ride', 'Urban Cycle Sprint', 'Mountain Challenge'],
      'Triathlon': ['Iron Challenge', 'Sprint Tri', 'Olympic Distance'],
      'HIIT': ['Burn Zone HIIT', 'Circuit Blast', 'Metabolic Rush'],
    };
    final list = titles[category] ?? ['Fitness Event'];
    return list[index % list.length];
  }

  List<EventModel> _getMockEvents() {
    return [
      EventModel(
        id: '1',
        title: 'Neon Night 10K Run',
        description:
            'Experience running under the city lights in this spectacular night race. '
            'Glow accessories provided. Join hundreds of runners for an unforgettable evening.',
        category: 'Run',
        location: 'Central Park, NYC',
        date: DateTime.now().add(const Duration(days: 7)),
        imageUrl:
            'https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=800',
        participants: 245,
        maxParticipants: 500,
        distance: 10.0,
        difficulty: 'Intermediate',
      ),
      EventModel(
        id: '2',
        title: 'Sunrise Power Yoga',
        description:
            'Start your day with an energizing yoga session as the sun rises over the horizon. '
            'All skill levels welcome. Mats provided.',
        category: 'Yoga',
        location: 'Riverside Park, LA',
        date: DateTime.now().add(const Duration(days: 3)),
        imageUrl:
            'https://images.unsplash.com/photo-1552196563-55cd4e45efb3?w=800',
        participants: 45,
        maxParticipants: 60,
        distance: 0,
        difficulty: 'Beginner',
      ),
      EventModel(
        id: '3',
        title: 'Century Cycling Challenge',
        description:
            'Complete 100 miles of scenic cycling through beautiful countryside. '
            'Support stations every 20 miles. A true test of endurance.',
        category: 'Cycling',
        location: 'Golden Gate, SF',
        date: DateTime.now().add(const Duration(days: 14)),
        imageUrl:
            'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=800',
        participants: 88,
        maxParticipants: 150,
        distance: 160.0,
        difficulty: 'Advanced',
      ),
      EventModel(
        id: '4',
        title: 'HIIT Burn Zone',
        description:
            'Push your limits with our high-intensity interval training session. '
            '45 minutes of pure cardio and strength conditioning.',
        category: 'HIIT',
        location: 'Millennium Park, Chicago',
        date: DateTime.now().add(const Duration(days: 5)),
        imageUrl:
            'https://images.unsplash.com/photo-1517963879433-6ad2b056d712?w=800',
        participants: 32,
        maxParticipants: 40,
        distance: 0,
        difficulty: 'Advanced',
      ),
    ];
  }
}
