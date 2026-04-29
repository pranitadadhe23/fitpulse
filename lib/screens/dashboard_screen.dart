// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/providers.dart';
import '../widgets/widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final now = DateTime.now();
    final greeting = now.hour < 12
        ? 'Good Morning'
        : now.hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context, greeting, user?.displayName ?? 'Athlete'),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildHeroCard(user),
                const SizedBox(height: 20),
                const _SectionHeader(title: 'Today\'s Stats'),
                const SizedBox(height: 12),
                _buildStatsGrid(user),
                const SizedBox(height: 20),
                const _SectionHeader(title: 'Weekly Progress'),
                const SizedBox(height: 12),
                _buildWeeklyBar(),
                const SizedBox(height: 20),
                const _SectionHeader(title: 'Quick Actions'),
                const SizedBox(height: 12),
                _buildQuickActions(context),
                const SizedBox(height: 20),
                const _SectionHeader(title: 'Upcoming Events'),
                const SizedBox(height: 12),
                _buildUpcomingEvents(context),
                const SizedBox(height: 80),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(
      BuildContext context, String greeting, String name) {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppColors.bg,
      expandedHeight: 80,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          padding: const EdgeInsets.fromLTRB(16, 50, 16, 0),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    greeting,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    name,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Rajdhani',
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonCyan.withOpacity(0.3),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: const CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.bgCard,
                  child: Icon(Icons.person, color: AppColors.neonCyan, size: 24),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(user) {
    return GlassCard(
      glowColor: AppColors.neonCyan,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.neonGreen.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.neonGreen.withOpacity(0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.neonGreen,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.neonGreen.withOpacity(0.8),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'ACTIVE STREAK',
                      style: TextStyle(
                        color: AppColors.neonGreen,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${user?.streak ?? 7}',
                style: const TextStyle(
                  color: AppColors.neonCyan,
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Orbitron',
                  height: 1,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 8, left: 8),
                child: Text(
                  'DAYS\nSTREAK',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _miniStat('${user?.totalWorkouts ?? 42}', 'Workouts'),
                  const SizedBox(height: 8),
                  _miniStat(
                    '${(user?.totalDistance ?? 187.3).toStringAsFixed(0)} km',
                    'Total',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: 0.65,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.neonCyan),
              minHeight: 4,
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            children: [
              Text(
                'Weekly goal: 65% complete',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
              Spacer(),
              Text(
                '13/20 km',
                style: TextStyle(
                  color: AppColors.neonCyan,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _miniStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            fontFamily: 'Orbitron',
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textMuted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid(user) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.25,
      children: [
        StatCard(
          label: 'Distance',
          value: '7.4',
          unit: 'km',
          icon: Icons.directions_run,
          accentColor: AppColors.neonCyan,
        ),
        StatCard(
          label: 'Calories',
          value: '486',
          unit: 'kcal',
          icon: Icons.local_fire_department,
          accentColor: AppColors.neonPink,
        ),
        StatCard(
          label: 'Duration',
          value: '42',
          unit: 'min',
          icon: Icons.timer_outlined,
          accentColor: AppColors.neonPurple,
        ),
        StatCard(
          label: 'Avg Pace',
          value: '5:42',
          unit: '/km',
          icon: Icons.speed,
          accentColor: AppColors.neonGreen,
        ),
      ],
    );
  }

  Widget _buildWeeklyBar() {
    final data = ActivityProvider.weeklyData;
    final maxDist = data.map((d) => (d['distance'] as num).toDouble()).reduce(
          (a, b) => a > b ? a : b,
        );

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: data.map((d) {
              final dist = (d['distance'] as num).toDouble();
              final height = maxDist > 0 ? (dist / maxDist) : 0.0;
              final isToday = d['day'] == _getDayName();
              return _buildBarColumn(
                d['day'] as String,
                height,
                dist,
                isToday,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBarColumn(
      String day, double heightRatio, double dist, bool isToday) {
    return Column(
      children: [
        Text(
          dist > 0 ? '${dist.toStringAsFixed(1)}' : '',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 9),
        ),
        const SizedBox(height: 4),
        Container(
          width: 32,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4),
            color: AppColors.bgSurface,
          ),
          alignment: Alignment.bottomCenter,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            curve: Curves.elasticOut,
            height: 80 * heightRatio,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: isToday ? AppColors.cyanGradient : const LinearGradient(
                colors: [Color(0xFF1A3050), Color(0xFF0F2040)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: isToday
                  ? [
                      BoxShadow(
                        color: AppColors.neonCyan.withOpacity(0.4),
                        blurRadius: 8,
                      ),
                    ]
                  : [],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          day,
          style: TextStyle(
            color: isToday ? AppColors.neonCyan : AppColors.textMuted,
            fontSize: 11,
            fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  String _getDayName() {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[DateTime.now().weekday - 1];
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _QuickActionTile(
            icon: Icons.play_circle_filled,
            label: 'Start Run',
            color: AppColors.neonCyan,
            onTap: () => _navigateToTab(context, 2),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionTile(
            icon: Icons.event,
            label: 'Find Events',
            color: AppColors.neonPurple,
            onTap: () => _navigateToTab(context, 1),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionTile(
            icon: Icons.insights,
            label: 'My Stats',
            color: AppColors.neonPink,
            onTap: () => _navigateToTab(context, 3),
          ),
        ),
      ],
    );
  }

  void _navigateToTab(BuildContext context, int index) {
    // Communicated up to MainNav
    MainNavigationState.of(context)?.setTab(index);
  }

  Widget _buildUpcomingEvents(BuildContext context) {
    final events = [
      {'title': 'Neon Night 10K', 'date': 'Apr 27', 'type': 'Run'},
      {'title': 'Sunrise Yoga', 'date': 'Apr 23', 'type': 'Yoga'},
    ];

    return Column(
      children: events.map((e) => _UpcomingEventTile(event: e)).toList(),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

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
            boxShadow: [
              BoxShadow(
                color: AppColors.neonCyan.withOpacity(0.6),
                blurRadius: 6,
              ),
            ],
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

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      glowColor: color,
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpcomingEventTile extends StatelessWidget {
  final Map<String, String> event;

  const _UpcomingEventTile({required this.event});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.neonPurple.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.event, color: AppColors.neonPurple),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title']!,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                Text(
                  '${event['date']} • ${event['type']}',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textMuted),
        ],
      ),
    );
  }
}

// Placeholder class for navigation communication
class MainNavigationState {
  static MainNavigationState? of(BuildContext context) => null;
  void setTab(int index) {}
}
