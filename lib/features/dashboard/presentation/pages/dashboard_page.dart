import 'package:flutter/material.dart';
import 'package:orbit_app/app/theme/app_colors.dart';
import 'package:orbit_app/core/widgets/orbit_icon.dart';

/// Home / Dashboard screen.
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _TopBar()),
            SliverToBoxAdapter(child: _Greeting()),
            SliverToBoxAdapter(child: _StatsRow()),
            SliverToBoxAdapter(child: _RecentActivity()),
            SliverToBoxAdapter(child: _PinnedNotes()),
            SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top app bar
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: Row(
        children: [
          // ── Orbit logo badge ──────────────────────────────────────────────
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: kOrbitIndigo.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kOrbitIndigo.withValues(alpha: 0.40)),
            ),
            child: const Center(child: OrbitIcon(size: 20, strokeWidth: 1.5)),
          ),
          const SizedBox(width: 8),
          const Text(
            'Orbit',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              height: 1.4,
            ),
          ),
          const Spacer(),

          // ── Bell button ───────────────────────────────────────────────────
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                  border: Border.all(color: AppColors.borderNeutral),
                ),
                child: const Center(
                  child: Icon(
                    Icons.notifications_none_rounded,
                    size: 16,
                    color: AppColors.neutral400,
                  ),
                ),
              ),
              // Red notification dot
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.rose,
                    border: Border.all(color: AppColors.background, width: 1.5),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 12),

          // ── Avatar ────────────────────────────────────────────────────────
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: kOrbitIndigo.withValues(alpha: 0.30),
              border: Border.all(color: kOrbitIndigo.withValues(alpha: 0.40)),
            ),
            child: const Center(
              child: Text(
                'AL',
                style: TextStyle(
                  color: AppColors.amber600,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Greeting
// ─────────────────────────────────────────────────────────────────────────────

class _Greeting extends StatelessWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good morning, Alex',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
              height: 1.33,
            ),
          ),
          SizedBox(height: 4),
          Text(
            "Here's what's happening.",
            style: TextStyle(color: AppColors.neutral400, fontSize: 14, height: 1.4),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Stats row (horizontal scrolling cards)
// ─────────────────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
        children: const [
          _StatCard(
            icon: Icons.folder_open_rounded,
            iconColor: kOrbitIndigo,
            value: '6',
            label: 'Active Projects',
          ),
          SizedBox(width: 16),
          _StatCard(
            icon: Icons.check_box_outlined,
            iconColor: AppColors.amber600,
            value: '14',
            label: 'Open Tasks',
          ),
          SizedBox(width: 16),
          _StatCard(
            icon: Icons.timer_outlined,
            iconColor: AppColors.teal,
            value: '2h 45m',
            label: 'Tracked Today',
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderNeutral),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon badge
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Icon(icon, size: 18, color: iconColor)),
          ),
          const SizedBox(height: 10),
          // Value
          Text(
            value,
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              height: 1.33,
            ),
          ),
          const SizedBox(height: 2),
          // Label
          Text(
            label,
            style: const TextStyle(
              color: AppColors.neutral400,
              fontSize: 12,
              height: 1.33,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Recent Activity
// ─────────────────────────────────────────────────────────────────────────────

class _RecentActivity extends StatelessWidget {
  const _RecentActivity();

  static const List<_ActivityItem> _items = [
    _ActivityItem(
      icon: Icons.commit_rounded,
      text: 'Pushed commit to orbit-core',
      time: '08:42',
    ),
    _ActivityItem(
      icon: Icons.description_outlined,
      text: 'Added note: API Rate Limits',
      time: '09:15',
    ),
    _ActivityItem(
      icon: Icons.timer_outlined,
      text: 'Logged 1h 20m on Project Nexus',
      time: '10:03',
    ),
    _ActivityItem(
      icon: Icons.check_circle_outline_rounded,
      text: 'Completed task: Refactor auth flow',
      time: '10:41',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        children: [
          // Section header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Activity',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'See all',
                  style: TextStyle(
                    color: kOrbitIndigo,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Activity card
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderNeutral),
            ),
            child: Column(
              children: [
                for (int i = 0; i < _items.length; i++) ...[
                  _ActivityRow(item: _items[i]),
                  if (i < _items.length - 1)
                    Container(height: 1, color: AppColors.borderNeutral),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem {
  const _ActivityItem({
    required this.icon,
    required this.text,
    required this.time,
  });

  final IconData icon;
  final String text;
  final String time;
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({required this.item});
  final _ActivityItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(item.icon, size: 16, color: AppColors.neutral400),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            item.time,
            style: const TextStyle(
              color: AppColors.neutral550,
              fontSize: 12,
              fontFamily: 'monospace',
              height: 1.33,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Pinned Notes
// ─────────────────────────────────────────────────────────────────────────────

class _PinnedNotes extends StatelessWidget {
  const _PinnedNotes();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pinned Notes',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
          ),
          SizedBox(height: 12),
          _NoteCard(
            title: 'API Rate Limits',
            tag: 'api',
            tagColor: kOrbitIndigo,
            body:
                'Standard tier allows 1000 req/min. Burst capacity caps at 5000 with token bucket refill every 60s.',
          ),
          SizedBox(height: 12),
          _NoteCard(
            title: 'Deploy Checklist',
            tag: 'ops',
            tagColor: AppColors.amber600,
            body:
                'Run migrations, verify env vars, smoke test staging, then promote build to production via CI pipeline.',
          ),
        ],
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.title,
    required this.tag,
    required this.tagColor,
    required this.body,
  });

  final String title;
  final String tag;
  final Color tagColor;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderNeutral),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + tag
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: tagColor.withValues(alpha: 0.20),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  tag,
                  style: TextStyle(
                    color: tagColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Body text — max 2 lines
          Text(
            body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.neutral400,
              fontSize: 12,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
