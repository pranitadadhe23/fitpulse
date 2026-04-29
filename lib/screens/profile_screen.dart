// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildHeader(context),
              const SizedBox(height: 24),
              _buildProfileCard(context, user),
              const SizedBox(height: 20),
              _buildStatsSection(user),
              const SizedBox(height: 20),
              _buildAchievements(),
              const SizedBox(height: 20),
              _buildSettings(context),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PROFILE',
              style: TextStyle(
                color: AppColors.neonCyan,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 3,
                fontFamily: 'Rajdhani',
              ),
            ),
            Text(
              'My Account',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                fontFamily: 'Orbitron',
              ),
            ),
          ],
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => _showEditProfile(context),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.edit_outlined,
                color: AppColors.neonCyan, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(BuildContext context, UserModel? user) {
    return GlassCard(
      glowColor: AppColors.neonCyan,
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppColors.cyanGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonCyan.withOpacity(0.4),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    (user?.displayName ?? 'A').substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.bg,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'Orbitron',
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.neonGreen,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.bg, width: 2),
                  ),
                  child: const Icon(Icons.check, size: 12, color: AppColors.bg),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            user?.displayName ?? 'Athlete',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.w700,
              fontFamily: 'Rajdhani',
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? '',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ProfileStat(
                value: '${user?.streak ?? 7}',
                label: 'Day Streak',
                color: AppColors.neonGreen,
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.border,
              ),
              _ProfileStat(
                value: '${user?.totalWorkouts ?? 42}',
                label: 'Workouts',
                color: AppColors.neonCyan,
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.border,
              ),
              _ProfileStat(
                value: '${(user?.totalDistance ?? 187).toStringAsFixed(0)}',
                label: 'Total km',
                color: AppColors.neonPurple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(UserModel? user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'Performance Stats'),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: [
            StatCard(
              label: 'Total Distance',
              value: '${(user?.totalDistance ?? 187.3).toStringAsFixed(0)}',
              unit: 'km',
              icon: Icons.directions_run,
              accentColor: AppColors.neonCyan,
            ),
            StatCard(
              label: 'Calories Burned',
              value: '${(user?.totalCalories ?? 14280).toStringAsFixed(0)}',
              unit: 'kcal',
              icon: Icons.local_fire_department,
              accentColor: AppColors.neonPink,
            ),
            StatCard(
              label: 'Best Pace',
              value: '4:32',
              unit: '/km',
              icon: Icons.speed,
              accentColor: AppColors.neonGreen,
            ),
            StatCard(
              label: 'This Month',
              value: '38.5',
              unit: 'km',
              icon: Icons.calendar_month,
              accentColor: AppColors.neonPurple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAchievements() {
    final badges = [
      {'icon': Icons.emoji_events, 'label': 'First 5K', 'color': AppColors.neonGreen, 'earned': true},
      {'icon': Icons.bolt, 'label': 'Speed Demon', 'color': AppColors.neonCyan, 'earned': true},
      {'icon': Icons.whatshot, 'label': '7-Day Streak', 'color': AppColors.neonPink, 'earned': true},
      {'icon': Icons.stars, 'label': 'Marathon', 'color': AppColors.neonPurple, 'earned': false},
      {'icon': Icons.military_tech, 'label': 'Iron Man', 'color': AppColors.neonBlue, 'earned': false},
      {'icon': Icons.workspace_premium, 'label': 'Century', 'color': AppColors.neonGreen, 'earned': false},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'Achievements'),
        const SizedBox(height: 12),
        GlassCard(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: badges.map((b) => _AchievementBadge(
              icon: b['icon'] as IconData,
              label: b['label'] as String,
              color: b['color'] as Color,
              earned: b['earned'] as bool,
            )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSettings(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'Settings'),
        const SizedBox(height: 12),
        GlassCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _SettingsTile(
                icon: Icons.notifications_outlined,
                label: 'Notifications',
                onTap: () {},
              ),
              const Divider(color: AppColors.divider, height: 1),
              _SettingsTile(
                icon: Icons.privacy_tip_outlined,
                label: 'Privacy',
                onTap: () {},
              ),
              const Divider(color: AppColors.divider, height: 1),
              _SettingsTile(
                icon: Icons.help_outline,
                label: 'Help & Support',
                onTap: () {},
              ),
              const Divider(color: AppColors.divider, height: 1),
              _SettingsTile(
                icon: Icons.logout,
                label: 'Sign Out',
                color: AppColors.neonPink,
                onTap: () => _confirmSignOut(context),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showEditProfile(BuildContext context) {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;
    final nameCtrl = TextEditingController(text: user.displayName);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          20,
          20,
          MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit Profile',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontFamily: 'Rajdhani',
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: nameCtrl,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: 'Display Name',
                prefixIcon: Icon(Icons.person_outline, color: AppColors.textMuted),
              ),
            ),
            const SizedBox(height: 20),
            NeonButton(
              label: 'Save Changes',
              width: double.infinity,
              onPressed: () async {
                final updated = user.copyWith(displayName: nameCtrl.text);
                await context.read<AuthProvider>().updateProfile(updated);
                if (context.mounted) {
                  Navigator.pop(context);
                  showSuccessSnackBar(context, 'Profile updated!');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Sign Out',
          style: TextStyle(color: AppColors.textPrimary, fontFamily: 'Rajdhani'),
        ),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().signOut();
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: AppColors.neonPink),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _ProfileStat({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            fontFamily: 'Orbitron',
          ),
        ),
        const SizedBox(height: 2),
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
}

class _AchievementBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool earned;

  const _AchievementBadge({
    required this.icon,
    required this.label,
    required this.color,
    required this.earned,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: earned ? color.withOpacity(0.15) : AppColors.bgSurface,
            border: Border.all(
              color: earned ? color.withOpacity(0.5) : AppColors.border,
            ),
            boxShadow: earned
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.2),
                      blurRadius: 8,
                    ),
                  ]
                : [],
          ),
          child: Icon(
            icon,
            color: earned ? color : AppColors.textMuted,
            size: 22,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            color: earned ? color : AppColors.textMuted,
            fontSize: 9,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
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

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.textPrimary;
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: c, size: 20),
      title: Text(
        label,
        style: TextStyle(color: c, fontSize: 15, fontWeight: FontWeight.w500),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: color != null ? color!.withOpacity(0.5) : AppColors.textMuted,
        size: 18,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
