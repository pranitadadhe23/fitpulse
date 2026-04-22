// lib/providers/auth_provider.dart
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';
import '../services/auth_service.dart';
import '../services/event_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  AuthProvider() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _status = AuthStatus.unauthenticated;
      _user = null;
    } else {
      final userModel = await _authService.getUserProfile(firebaseUser.uid);
      _user = userModel;
      _status = AuthStatus.authenticated;
    }
    notifyListeners();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _setLoading();
    try {
      _user = await _authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    _setLoading();
    try {
      _user = await _authService.signIn(email: email, password: password);
      _status = AuthStatus.authenticated;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> updateProfile(UserModel updated) async {
    try {
      await _authService.updateUserProfile(updated);
      _user = updated;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    }
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = _user != null ? AuthStatus.authenticated : AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}

// lib/providers/event_provider.dart
class EventProvider extends ChangeNotifier {
  final EventService _eventService = EventService();

  List<EventModel> _events = [];
  List<EventModel> _filteredEvents = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  List<EventModel> get events => _filteredEvents;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;

  final List<String> categories = ['All', 'Run', 'Yoga', 'Cycling', 'HIIT', 'Triathlon'];

  Future<void> fetchEvents() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _events = await _eventService.fetchEvents();
      _applyFilters();
    } catch (e) {
      _error = 'Failed to load events. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredEvents = _events.where((event) {
      final matchesCategory =
          _selectedCategory == 'All' || event.category == _selectedCategory;
      final matchesSearch = _searchQuery.isEmpty ||
          event.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          event.location.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }

  Future<void> toggleRegistration({
    required String userId,
    required EventModel event,
  }) async {
    try {
      final index = _events.indexWhere((e) => e.id == event.id);
      if (index == -1) return;

      if (event.isRegistered) {
        await _eventService.unregisterFromEvent(
          userId: userId,
          eventId: event.id,
        );
        _events[index].isRegistered = false;
      } else {
        await _eventService.registerForEvent(userId: userId, event: event);
        _events[index].isRegistered = true;
      }
      _applyFilters();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}

// lib/providers/activity_provider.dart
class ActivityProvider extends ChangeNotifier {
  bool _isTracking = false;
  Duration _elapsed = Duration.zero;
  double _distance = 0.0;
  double _calories = 0.0;
  double _currentPace = 0.0;
  List<ActivitySession> _sessions = [];

  bool get isTracking => _isTracking;
  Duration get elapsed => _elapsed;
  double get distance => _distance;
  double get calories => _calories;
  double get currentPace => _currentPace;
  List<ActivitySession> get sessions => _sessions;

  // Dummy stats for demo
  static const List<Map<String, dynamic>> weeklyData = [
    {'day': 'Mon', 'distance': 5.2, 'calories': 380},
    {'day': 'Tue', 'distance': 0, 'calories': 0},
    {'day': 'Wed', 'distance': 8.1, 'calories': 620},
    {'day': 'Thu', 'distance': 3.5, 'calories': 280},
    {'day': 'Fri', 'distance': 10.0, 'calories': 750},
    {'day': 'Sat', 'distance': 6.3, 'calories': 480},
    {'day': 'Sun', 'distance': 0, 'calories': 0},
  ];

  void startTracking() {
    _isTracking = true;
    _elapsed = Duration.zero;
    _distance = 0.0;
    _calories = 0.0;
    _currentPace = 0.0;
    notifyListeners();
    _simulateTracking();
  }

  void stopTracking() {
    _isTracking = false;
    if (_distance > 0) {
      _sessions.insert(
        0,
        ActivitySession(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          type: 'Run',
          distance: _distance,
          duration: _elapsed,
          calories: _calories,
          avgPace: _currentPace,
          date: DateTime.now(),
          paceHistory: [5.2, 5.0, 4.8, 4.9, 4.7, 5.1],
        ),
      );
    }
    notifyListeners();
  }

  void _simulateTracking() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_isTracking) {
        _elapsed += const Duration(seconds: 1);
        _distance += 0.003; // ~10.8 km/h pace simulation
        _calories = _distance * 65;
        _currentPace = _elapsed.inSeconds > 0
            ? (_elapsed.inMinutes / _distance)
            : 0;
        notifyListeners();
        _simulateTracking();
      }
    });
  }

  String formatPace(double pace) {
    if (pace <= 0 || pace.isNaN || pace.isInfinite) return '--:--';
    final mins = pace.floor();
    final secs = ((pace - mins) * 60).round();
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  String formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}

// Re-export event service for provider use

