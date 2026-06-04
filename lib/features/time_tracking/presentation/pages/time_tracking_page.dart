import 'package:flutter/material.dart';
import 'package:orbit_app/app/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

class TimeTrackingPage extends StatelessWidget {
  const TimeTrackingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.neutral50),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Time Tracking',
          style: TextStyle(
            color: AppColors.neutral50,
            fontSize: 24, // text-2xl
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        titleSpacing: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surface, // bg-neutral-800 roughly
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.bar_chart_rounded,
                color: AppColors.neutral400,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        children: const [
          _CurrentlyTrackingCard(),
          SizedBox(height: 24),
          _TodaysSummarySection(),
          SizedBox(height: 24),
          _TimeEntriesSection(),
        ],
      ),
    );
  }
}

class _CurrentlyTrackingCard extends StatelessWidget {
  const _CurrentlyTrackingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt, // bg-neutral-900
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              color: AppColors.indigo500,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'CURRENTLY TRACKING',
                      style: TextStyle(
                        color: AppColors.neutral400,
                        fontSize: 11,
                        fontFamily: 'monospace',
                        letterSpacing: 2.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '01:24:37',
                      style: TextStyle(
                        color: AppColors.neutral50,
                        fontSize: 40,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'monospace',
                        letterSpacing: -1.0,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Implement OAuth token refresh flow',
                      style: TextStyle(
                        color: AppColors.neutral400,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.indigo500.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'Auth API',
                        style: TextStyle(
                          color: AppColors.indigo400,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.stop_rounded, size: 16),
                            label: const Text('Stop'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.indigo500,
                              foregroundColor: AppColors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.pause_rounded, size: 16),
                            label: const Text('Pause'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.neutral50,
                              backgroundColor: AppColors.surfaceAlt,
                              side: const BorderSide(color: AppColors.chip, width: 1),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodaysSummarySection extends StatelessWidget {
  const _TodaysSummarySection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              "Today's Summary",
              style: TextStyle(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Total: 4h 12m',
              style: TextStyle(
                color: AppColors.neutral400,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // Progress Bar
              Container(
                height: 8,
                width: double.infinity,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Expanded(flex: 33, child: Container(color: AppColors.indigo500)),
                    Expanded(flex: 28, child: Container(color: AppColors.cyan)), // Atlas Gateway
                    Expanded(flex: 22, child: Container(color: AppColors.amber)), // Forge CI
                    Expanded(flex: 17, child: Container(color: AppColors.emerald)), // Vault
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Items
              const _SummaryItem(
                color: AppColors.indigo500,
                title: 'Auth API',
                duration: '1h 24m',
              ),
              const SizedBox(height: 12),
              const _SummaryItem(
                color: AppColors.cyan,
                title: 'Atlas Gateway',
                duration: '1h 10m',
              ),
              const SizedBox(height: 12),
              const _SummaryItem(
                color: AppColors.amber,
                title: 'Forge CI',
                duration: '55m',
              ),
              const SizedBox(height: 12),
              const _SummaryItem(
                color: AppColors.emerald,
                title: 'Vault',
                duration: '43m',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.color,
    required this.title,
    required this.duration,
  });

  final Color color;
  final String title;
  final String duration;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.neutral400,
                fontSize: 14,
              ),
            ),
          ],
        ),
        Text(
          duration,
          style: const TextStyle(
            color: AppColors.neutral50,
            fontSize: 14,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }
}

class _TimeEntriesSection extends StatelessWidget {
  const _TimeEntriesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text(
              "Time Entries",
              style: TextStyle(
                color: AppColors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Apr 12',
              style: TextStyle(
                color: AppColors.neutral400,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Column(
            children: [
              _TimeEntryItem(
                color: AppColors.cyan,
                title: 'Setup Redis caching',
                project: 'Atlas Gateway',
                duration: '1h 10m',
                showDivider: true,
              ),
              _TimeEntryItem(
                color: AppColors.amber,
                title: 'Write unit tests',
                project: 'Forge CI',
                duration: '55m',
                showDivider: true,
              ),
              _TimeEntryItem(
                color: AppColors.emerald,
                title: 'Review PR #42',
                project: 'Vault',
                duration: '43m',
                showDivider: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _TimeEntryItem extends StatelessWidget {
  const _TimeEntryItem({
    required this.color,
    required this.title,
    required this.project,
    required this.duration,
    required this.showDivider,
  });

  final Color color;
  final String title;
  final String project;
  final String duration;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: showDivider
            ? const Border(bottom: BorderSide(color: AppColors.borderCard))
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.neutral50,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        project,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.neutral400,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            duration,
            style: const TextStyle(
              color: AppColors.neutral300,
              fontSize: 14,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }
}
