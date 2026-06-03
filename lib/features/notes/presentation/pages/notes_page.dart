import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:orbit_app/app/theme/app_colors.dart';
import 'package:orbit_app/core/widgets/orbit_icon.dart';

class _Note {
  const _Note({
    required this.title,
    required this.body,
    required this.tag,
    required this.tagColor,
    required this.date,
    this.pinned = false,
  });

  final String title;
  final String body;
  final String tag;
  final Color tagColor;
  final String date;
  final bool pinned;
}

const List<_Note> _notes = [
  _Note(
    title: 'API Rate Limits',
    body:
        'Standard tier allows 1000 req/min. Burst capacity caps at 5000 '
        'with token bucket refill every 60s.',
    tag: 'api',
    tagColor: AppColors.brandSoft,
    date: 'Today 09:15',
    pinned: true,
  ),
  _Note(
    title: 'Deploy Checklist',
    body:
        'Run migrations, verify env vars, smoke test staging, then promote '
        'build to production via CI pipeline.',
    tag: 'ops',
    tagColor: AppColors.amber,
    date: 'Today 08:42',
    pinned: true,
  ),
  _Note(
    title: 'Redis Caching Strategy',
    body:
        'Set TTL of 300s for hot keys and use LRU eviction policy. '
        'Invalidate on write to keep cache coherent.',
    tag: 'infra',
    tagColor: AppColors.rose500,
    date: 'Yesterday',
  ),
  _Note(
    title: 'Component Library Notes',
    body:
        'Define design tokens for color, spacing and radius. Document each '
        'component in Storybook with variants.',
    tag: 'docs',
    tagColor: AppColors.purple,
    date: 'Apr 10',
  ),
  _Note(
    title: 'Onboarding Flow Ideas',
    body:
        'Use progressive disclosure to reveal features gradually. Avoid '
        'overwhelming new users on first launch.',
    tag: 'ux',
    tagColor: AppColors.emerald,
    date: 'Apr 09',
  ),
  _Note(
    title: 'Database Migration Plan',
    body:
        'Apply schema changes in backward-compatible steps for zero-downtime. '
        'Dual-write, backfill, then cutover.',
    tag: 'ops',
    tagColor: AppColors.amber,
    date: 'Apr 07',
  ),
];

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Header(),
            const _SearchBar(),
            const _FilterChips(),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                itemCount: _notes.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, i) => _NoteCard(
                  note: _notes[i],
                  onTap: () => context.push('/notes/detail'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Header ─────────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Notes',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 30,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
              height: 1.2,
            ),
          ),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.neutral200,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add_rounded,
              color: AppColors.surface,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Search bar ──────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderFaint),
        ),
        child: const Row(
          children: [
            Icon(Icons.search_rounded, color: AppColors.neutral400, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: TextField(
                style: TextStyle(color: AppColors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search notes...',
                  hintStyle: TextStyle(
                    color: AppColors.neutral400,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Filter chips ────────────────────────────────────────────────────────────────

class _FilterChips extends StatelessWidget {
  const _FilterChips();

  @override
  Widget build(BuildContext context) {
    const labels = ['All', 'Pinned', 'Work', 'Personal', 'Archived'];
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) => _Chip(label: labels[i], active: i == 0),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.active});
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? kOrbitIndigo : AppColors.transparent,
        borderRadius: BorderRadius.circular(999),
        border: active ? null : Border.all(color: AppColors.borderFaint),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: active ? AppColors.white : AppColors.neutral400,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ── Note card ──────────────────────────────────────────────────────────────────

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note, required this.onTap});
  final _Note note;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    note.title,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),
                ),
                if (note.pinned)
                  const Icon(Icons.push_pin, color: kOrbitIndigo, size: 16),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              note.body,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.neutral400,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: note.tagColor.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    note.tag,
                    style: TextStyle(color: note.tagColor, fontSize: 12),
                  ),
                ),
                Text(
                  note.date,
                  style: const TextStyle(
                    color: AppColors.neutral400,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
