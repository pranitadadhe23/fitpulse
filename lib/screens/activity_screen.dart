// lib/screens/activity_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../theme/app_theme.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';
// import '../models/activity_session.dart';
import '../models/models.dart';

class ActivityScreen extends StatefulWidget {
  const ActivityScreen({super.key});

  @override
  State<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _ringController;
  late Animation<double> _pulseAnim;
  late Animation<double> _ringAnim;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _ringAnim = Tween<double>(begin: 0, end: 1).animate(_ringController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<ActivityProvider>(
          builder: (context, activity, _) => SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                _buildHeader(activity),
                const SizedBox(height: 24),
                _buildTrackingDisplay(activity),
                const SizedBox(height: 28),
                _buildLiveStats(activity),
                const SizedBox(height: 28),
                if (!activity.isTracking) ...[
                  const _SectionTitle(title: 'Recent Sessions'),
                  const SizedBox(height: 12),
                  _buildSessionHistory(activity),
                ],
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ActivityProvider activity) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'TRACKER',
          style: TextStyle(
            color: AppColors.neonCyan,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 3,
            fontFamily: 'Rajdhani',
          ),
        ),
        Row(
          children: [
            const Text(
              'Activity',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                fontFamily: 'Orbitron',
              ),
            ),
            const Spacer(),
            if (activity.isTracking)
              _LiveBadge(),
          ],
        ),
      ],
    );
  }

  Widget _buildTrackingDisplay(ActivityProvider activity) {
    return Center(
      child: Column(
        children: [
          // Main timer display
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer decorative rings
              AnimatedBuilder(
                animation: _ringAnim,
                builder: (context, _) => CustomPaint(
                  size: const Size(240, 240),
                  painter: _RingPainter(
                    progress: _ringAnim.value,
                    isActive: activity.isTracking,
                  ),
                ),
              ),
              // Timer circle
              Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.bgCard,
                  border: Border.all(
                    color: activity.isTracking
                        ? AppColors.neonCyan
                        : AppColors.border,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: activity.isTracking
                          ? AppColors.neonCyan.withOpacity(0.2)
                          : Colors.transparent,
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      activity.formatDuration(activity.elapsed),
                      style: TextStyle(
                        color: activity.isTracking
                            ? AppColors.neonCyan
                            : AppColors.textPrimary,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Orbitron',
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activity.isTracking ? 'RUNNING' : 'READY',
                      style: TextStyle(
                        color: activity.isTracking
                            ? AppColors.neonGreen
                            : AppColors.textMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Start/Stop button with pulse animation
          ScaleTransition(
            scale: activity.isTracking ? _pulseAnim : const AlwaysStoppedAnimation(1.0),
            child: GestureDetector(
              onTap: () {
                if (activity.isTracking) {
                  activity.stopTracking();
                  _pulseController.stop();
                  showSuccessSnackBar(
                    context,
                    'Workout saved! Great job! 🎉',
                  );
                } else {
                  activity.startTracking();
                  _pulseController.repeat(reverse: true);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.elasticOut,
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: activity.isTracking
                        ? [AppColors.neonPink, const Color(0xFF8B0037)]
                        : [AppColors.neonCyan, AppColors.neonBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (activity.isTracking
                              ? AppColors.neonPink
                              : AppColors.neonCyan)
                          .withOpacity(0.5),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  activity.isTracking ? Icons.stop_rounded : Icons.play_arrow_rounded,
                  color: AppColors.bg,
                  size: 40,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            activity.isTracking ? 'Tap to stop' : 'Tap to start',
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveStats(ActivityProvider activity) {
    return Row(
      children: [
        Expanded(
          child: _TrackStat(
            label: 'Distance',
            value: activity.distance.toStringAsFixed(2),
            unit: 'km',
            icon: Icons.directions_run,
            color: AppColors.neonCyan,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TrackStat(
            label: 'Calories',
            value: activity.calories.toStringAsFixed(0),
            unit: 'kcal',
            icon: Icons.local_fire_department,
            color: AppColors.neonPink,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TrackStat(
            label: 'Pace',
            value: activity.formatPace(activity.currentPace),
            unit: '/km',
            icon: Icons.speed,
            color: AppColors.neonPurple,
          ),
        ),
      ],
    );
  }

  Widget _buildSessionHistory(ActivityProvider activity) {
    final List<ActivitySession> sessions =
    activity.sessions.isEmpty
        ? _dummySessions()
        : activity.sessions.cast<ActivitySession>();

    if (sessions.isEmpty) {
      return const Center(
        child: Text(
          'No sessions yet. Start your first workout!',
          style: TextStyle(color: AppColors.textMuted),
        ),
      );
    }

    return Column(
      children: sessions
          .take(5)
          .map((s) => _SessionTile(session: s))
          .toList(),
    );
  }

  List<ActivitySession> _dummySessions() {
    return [
      ActivitySession(
        id: '1',
        type: 'Run',
        distance: 7.4,
        duration: const Duration(minutes: 42, seconds: 18),
        calories: 486,
        avgPace: 5.72,
        date: DateTime.now().subtract(const Duration(days: 1)),
        paceHistory: [5.2, 5.0, 4.8, 4.9, 4.7, 5.1],
      ),
      ActivitySession(
        id: '2',
        type: 'Run',
        distance: 10.1,
        duration: const Duration(minutes: 58, seconds: 44),
        calories: 720,
        avgPace: 5.82,
        date: DateTime.now().subtract(const Duration(days: 3)),
        paceHistory: [5.5, 5.3, 5.1, 5.0, 4.9, 5.2],
      ),
      ActivitySession(
        id: '3',
        type: 'Run',
        distance: 5.0,
        duration: const Duration(minutes: 28, seconds: 12),
        calories: 340,
        avgPace: 5.64,
        date: DateTime.now().subtract(const Duration(days: 5)),
        paceHistory: [5.8, 5.5, 5.3, 5.2, 5.4],
      ),
    ];
  }
}

class _LiveBadge extends StatefulWidget {
  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.4, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.neonPink.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.neonPink.withOpacity(_anim.value),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: AppColors.neonPink.withOpacity(_anim.value),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'LIVE',
              style: TextStyle(
                color: AppColors.neonPink,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final bool isActive;

  _RingPainter({required this.progress, required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    if (!isActive) return;

    // Spinning arc
    final paint = Paint()
      ..color = AppColors.neonCyan.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 5),
      -math.pi / 2 + (progress * 2 * math.pi),
      math.pi * 0.8,
      false,
      paint,
    );

    // Dashed outer ring
    final dashPaint = Paint()
      ..color = AppColors.neonCyan.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 0; i < 24; i++) {
      final angle = (i / 24) * 2 * math.pi;
      final start = Offset(
        center.dx + (radius - 12) * math.cos(angle),
        center.dy + (radius - 12) * math.sin(angle),
      );
      final end = Offset(
        center.dx + (radius - 6) * math.cos(angle),
        center.dy + (radius - 6) * math.sin(angle),
      );
      canvas.drawLine(start, end, dashPaint);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.isActive != isActive;
}

class _TrackStat extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final IconData icon;
  final Color color;

  const _TrackStat({
    required this.label,
    required this.value,
    required this.unit,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      glowColor: color,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 16),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              fontFamily: 'Orbitron',
            ),
          ),
          Text(
            unit,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final ActivitySession session;

  const _SessionTile({required this.session});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.neonCyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.directions_run,
                color: AppColors.neonCyan, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${session.distance.toStringAsFixed(2)} km run',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  _formatDate(session.date),
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _formatDuration(session.duration),
                style: const TextStyle(
                  color: AppColors.neonCyan,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  fontFamily: 'Orbitron',
                ),
              ),
              Text(
                '${session.calories.toStringAsFixed(0)} kcal',
                style: const TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '$diff days ago';
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '${m}:${s.toString().padLeft(2, '0')}';
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.neonCyan,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            fontFamily: 'Rajdhani',
          ),
        ),
      ],
    );
  }
}
