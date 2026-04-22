// lib/screens/events_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../providers/providers.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EventProvider>().fetchEvents();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildCategoryFilter(),
            Expanded(child: _buildEventList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DISCOVER',
            style: TextStyle(
              color: AppColors.neonCyan,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 3,
              fontFamily: 'Rajdhani',
            ),
          ),
          const Text(
            'Events',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.w900,
              fontFamily: 'Orbitron',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: TextField(
          controller: _searchCtrl,
          onChanged: (v) => context.read<EventProvider>().setSearchQuery(v),
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
          decoration: const InputDecoration(
            hintText: 'Search events, locations...',
            hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 15),
            prefixIcon: Icon(Icons.search, color: AppColors.textMuted),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Consumer<EventProvider>(
      builder: (context, provider, _) => SizedBox(
        height: 52,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: provider.categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, i) {
            final cat = provider.categories[i];
            return CategoryChip(
              label: cat,
              isSelected: provider.selectedCategory == cat,
              onTap: () => provider.setCategory(cat),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEventList() {
    return Consumer<EventProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: 4,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, __) => const ShimmerCard(height: 200),
          );
        }

        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off,
                    color: AppColors.textMuted, size: 48),
                const SizedBox(height: 12),
                Text(
                  provider.error!,
                  style: const TextStyle(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                NeonButton(
                  label: 'Retry',
                  onPressed: () => provider.fetchEvents(),
                  outlined: true,
                ),
              ],
            ),
          );
        }

        if (provider.events.isEmpty) {
          return const Center(
            child: Text(
              'No events found',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: provider.events.length,
          separatorBuilder: (_, __) => const SizedBox(height: 14),
          itemBuilder: (context, i) => EventCard(
            event: provider.events[i],
            onTap: () => _openDetail(context, provider.events[i]),
          ),
        );
      },
    );
  }

  void _openDetail(BuildContext context, EventModel event) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => EventDetailScreen(event: event),
        transitionsBuilder: (_, animation, __, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }
}

class EventCard extends StatelessWidget {
  final EventModel event;
  final VoidCallback onTap;

  const EventCard({super.key, required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final catColor = _categoryColor(event.category);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          color: AppColors.bgCard,
          boxShadow: [
            BoxShadow(
              color: catColor.withOpacity(0.05),
              blurRadius: 20,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Stack(
                children: [
                  CachedNetworkImage(
                    imageUrl: event.imageUrl,
                    height: 160,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const ShimmerCard(height: 160),
                    errorWidget: (_, __, ___) => Container(
                      height: 160,
                      color: AppColors.bgSurface,
                      child: const Icon(Icons.image_not_supported,
                          color: AppColors.textMuted),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: _CategoryBadge(
                        category: event.category, color: catColor),
                  ),
                  if (event.isRegistered)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.neonGreen.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'REGISTERED',
                          style: TextStyle(
                            color: AppColors.bg,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          size: 13, color: AppColors.textMuted),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.location,
                          style: const TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _InfoChip(
                        icon: Icons.calendar_today_outlined,
                        label: DateFormat('MMM d').format(event.date),
                      ),
                      const SizedBox(width: 8),
                      if (event.distance > 0)
                        _InfoChip(
                          icon: Icons.straighten,
                          label: '${event.distance.toStringAsFixed(0)}km',
                        ),
                      const SizedBox(width: 8),
                      _InfoChip(
                        icon: Icons.signal_cellular_alt,
                        label: event.difficulty,
                        color: _difficultyColor(event.difficulty),
                      ),
                      const Spacer(),
                      Text(
                        '${event.participants}/${event.maxParticipants}',
                        style: TextStyle(
                          color: catColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.group_outlined,
                          size: 14, color: AppColors.textMuted),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'Run':
        return AppColors.neonCyan;
      case 'Yoga':
        return AppColors.neonPurple;
      case 'Cycling':
        return AppColors.neonGreen;
      case 'HIIT':
        return AppColors.neonPink;
      default:
        return AppColors.neonBlue;
    }
  }

  Color _difficultyColor(String diff) {
    switch (diff) {
      case 'Beginner':
        return AppColors.neonGreen;
      case 'Intermediate':
        return AppColors.neonCyan;
      case 'Advanced':
        return AppColors.neonPink;
      default:
        return AppColors.textSecondary;
    }
  }
}

class _CategoryBadge extends StatelessWidget {
  final String category;
  final Color color;

  const _CategoryBadge({required this.category, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        category.toUpperCase(),
        style: TextStyle(
          color: color == AppColors.neonCyan ? AppColors.bg : Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _InfoChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 12, color: color ?? AppColors.textMuted),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            color: color ?? AppColors.textMuted,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// EVENT DETAIL SCREEN
class EventDetailScreen extends StatelessWidget {
  final EventModel event;

  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    final catColor = _categoryColor(event.category);

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, catColor),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildEventInfo(catColor),
                    const SizedBox(height: 16),
                    _buildDescription(),
                    const SizedBox(height: 16),
                    _buildDetails(),
                    const SizedBox(height: 100),
                  ]),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildRegisterButton(context),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context, Color catColor) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.bg,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.bg.withOpacity(0.8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.arrow_back_ios_new, size: 18),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: event.imageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => const ShimmerCard(height: 280),
              errorWidget: (_, __, ___) =>
                  Container(color: AppColors.bgSurface),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, AppColors.bg.withOpacity(0.9)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventInfo(Color catColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _CategoryBadge(category: event.category, color: catColor),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.bgCard,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                event.difficulty,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          event.title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 26,
            fontWeight: FontWeight.w800,
            fontFamily: 'Rajdhani',
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            const Icon(Icons.location_on,
                size: 14, color: AppColors.neonCyan),
            const SizedBox(width: 4),
            Text(
              event.location,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ABOUT THIS EVENT',
            style: TextStyle(
              color: AppColors.neonCyan,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            event.description,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetails() {
    return GlassCard(
      child: Column(
        children: [
          _DetailRow(
            icon: Icons.calendar_today_outlined,
            label: 'Date',
            value: DateFormat('EEEE, MMMM d, y').format(event.date),
          ),
          const Divider(color: AppColors.divider, height: 20),
          _DetailRow(
            icon: Icons.straighten,
            label: 'Distance',
            value: event.distance > 0
                ? '${event.distance.toStringAsFixed(1)} km'
                : 'N/A',
          ),
          const Divider(color: AppColors.divider, height: 20),
          _DetailRow(
            icon: Icons.group_outlined,
            label: 'Participants',
            value:
                '${event.participants} / ${event.maxParticipants} registered',
          ),
          const Divider(color: AppColors.divider, height: 20),
          _DetailRow(
            icon: Icons.access_time_outlined,
            label: 'Start Time',
            value: '7:00 AM',
          ),
        ],
      ),
    );
  }

  Widget _buildRegisterButton(BuildContext context) {
    return Consumer2<EventProvider, AuthProvider>(
      builder: (context, events, auth, _) {
        final isRegistered = event.isRegistered;
        return Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          decoration: BoxDecoration(
            color: AppColors.bg,
            boxShadow: [
              BoxShadow(
                color: AppColors.neonCyan.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: NeonButton(
            label: isRegistered ? 'Unregister' : 'Join Event',
            color: isRegistered ? AppColors.neonPink : AppColors.neonCyan,
            outlined: isRegistered,
            width: double.infinity,
            onPressed: () async {
              if (auth.user == null) return;
              try {
                await events.toggleRegistration(
                  userId: auth.user!.uid,
                  event: event,
                );
                if (context.mounted) {
                  showSuccessSnackBar(
                    context,
                    isRegistered
                        ? 'Unregistered from ${event.title}'
                        : 'Successfully joined ${event.title}!',
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  showErrorSnackBar(context, e.toString());
                }
              }
            },
          ),
        );
      },
    );
  }

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'Run':
        return AppColors.neonCyan;
      case 'Yoga':
        return AppColors.neonPurple;
      case 'Cycling':
        return AppColors.neonGreen;
      case 'HIIT':
        return AppColors.neonPink;
      default:
        return AppColors.neonBlue;
    }
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.neonCyan, size: 18),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                letterSpacing: 1,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
