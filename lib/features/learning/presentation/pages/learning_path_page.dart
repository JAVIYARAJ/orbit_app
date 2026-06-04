import 'package:flutter/material.dart';
import 'package:orbit_app/app/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

class LearningPathPage extends StatelessWidget {
  const LearningPathPage({super.key});

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
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Learning Path',
              style: TextStyle(
                color: AppColors.neutral50,
                fontSize: 24, // text-[28px] roughly
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'Level up your dev skills',
              style: TextStyle(
                color: AppColors.neutral400,
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        titleSpacing: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surface, // bg-neutral-800
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
          _ProgressCard(),
          SizedBox(height: 28),
          Text(
            'CURRENT TRACKS',
            style: TextStyle(
              color: AppColors.neutral500,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 12),
          _FiltersRow(),
          SizedBox(height: 16),
          _TrackCard(
            title: 'Frontend Mastery',
            status: 'In Progress',
            statusColor: AppColors.amber, // bg-amber-500
            statusTextColor: Colors.black,
            description: 'React, TypeScript, state management and modern UI patterns.',
            progress: 0.6,
            progressText: '60%',
            progressColor: AppColors.indigo500,
            modulesText: '4/7 modules',
            timeLeftText: '~3h left',
            icon: Icons.code_rounded,
            iconColor: AppColors.indigo400,
          ),
          SizedBox(height: 12),
          _TrackCard(
            title: 'Backend Engineering',
            status: 'In Progress',
            statusColor: AppColors.amber,
            statusTextColor: Colors.black,
            description: 'APIs, databases, auth flows and scalable services.',
            progress: 0.45,
            progressText: '45%',
            progressColor: AppColors.cyan,
            modulesText: '5/11 modules',
            timeLeftText: '~6h left',
            icon: Icons.storage_rounded,
            iconColor: AppColors.cyan,
          ),
          SizedBox(height: 12),
          _TrackCard(
            title: 'DevOps & CI/CD',
            status: 'Not Started',
            statusColor: AppColors.surfaceAlt, // border-neutral-600 outline style roughly
            statusTextColor: AppColors.neutral400,
            statusOutline: true,
            description: 'Pipelines, containers, Kubernetes and deployment.',
            progress: 0.0,
            progressText: '0%',
            progressColor: AppColors.amber,
            modulesText: '0/9 modules',
            timeLeftText: '~8h left',
            icon: Icons.alt_route_rounded,
            iconColor: AppColors.amber,
          ),
          SizedBox(height: 12),
          _TrackCard(
            title: 'Security Essentials',
            status: 'In Progress',
            statusColor: AppColors.amber,
            statusTextColor: Colors.black,
            description: 'Auth, encryption, OWASP top 10 and secure coding.',
            progress: 0.33,
            progressText: '33%',
            progressColor: AppColors.rose400,
            modulesText: '2/6 modules',
            timeLeftText: '~4h left',
            icon: Icons.security_rounded,
            iconColor: AppColors.rose400,
          ),
          SizedBox(height: 28),
          Text(
            'CONTINUE LEARNING',
            style: TextStyle(
              color: AppColors.neutral500,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 12),
          _ContinueLearningCard(),
          SizedBox(height: 28),
          Text(
            'RECENTLY COMPLETED',
            style: TextStyle(
              color: AppColors.neutral500,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 12),
          _RecentlyCompletedBox(),
        ],
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderCard),
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
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'YOUR PROGRESS',
                      style: TextStyle(
                        color: AppColors.neutral500,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: const [
                        Text(
                          '68%',
                          style: TextStyle(
                            color: AppColors.neutral50,
                            fontSize: 40,
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                        ),
                        SizedBox(width: 8),
                        Padding(
                          padding: EdgeInsets.only(bottom: 4),
                          child: Text(
                            'Overall Completion',
                            style: TextStyle(
                              color: AppColors.neutral400,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 8,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.surface, // neutral-800
                        borderRadius: BorderRadius.circular(4),
                      ),
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: 0.68,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.indigo500,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Expanded(
                          child: Column(
                            children: [
                              Text(
                                '12',
                                style: TextStyle(
                                  color: AppColors.emerald,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Completed',
                                style: TextStyle(
                                  color: AppColors.neutral400,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 32, color: AppColors.surface), // neutral-700
                        const Expanded(
                          child: Column(
                            children: [
                              Text(
                                '5',
                                style: TextStyle(
                                  color: AppColors.amber,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'In Progress',
                                style: TextStyle(
                                  color: AppColors.neutral400,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(width: 1, height: 32, color: AppColors.surface),
                        const Expanded(
                          child: Column(
                            children: [
                              Text(
                                '8',
                                style: TextStyle(
                                  color: AppColors.neutral300,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Remaining',
                                style: TextStyle(
                                  color: AppColors.neutral400,
                                  fontSize: 12,
                                ),
                              ),
                            ],
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

class _FiltersRow extends StatelessWidget {
  const _FiltersRow();

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _FilterChip(label: 'All', isSelected: true),
          SizedBox(width: 8),
          _FilterChip(label: 'Frontend', isSelected: false),
          SizedBox(width: 8),
          _FilterChip(label: 'Backend', isSelected: false),
          SizedBox(width: 8),
          _FilterChip(label: 'DevOps', isSelected: false),
          SizedBox(width: 8),
          _FilterChip(label: 'Security', isSelected: false),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.isSelected});

  final String label;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.indigo500 : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        border: isSelected ? null : Border.all(color: AppColors.borderCard),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.white : AppColors.neutral400,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _TrackCard extends StatelessWidget {
  const _TrackCard({
    required this.title,
    required this.status,
    required this.statusColor,
    required this.statusTextColor,
    this.statusOutline = false,
    required this.description,
    required this.progress,
    required this.progressText,
    required this.progressColor,
    required this.modulesText,
    required this.timeLeftText,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final String status;
  final Color statusColor;
  final Color statusTextColor;
  final bool statusOutline;
  final String description;
  final double progress;
  final String progressText;
  final Color progressColor;
  final String modulesText;
  final String timeLeftText;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/profile/learning/detail'),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderCard),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.neutral50,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusOutline ? Colors.transparent : statusColor,
                    borderRadius: BorderRadius.circular(999),
                    border: statusOutline ? Border.all(color: AppColors.chip) : null,
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      color: statusTextColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(
                color: AppColors.neutral400,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.surface, // neutral-800
                      borderRadius: BorderRadius.circular(999),
                    ),
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: progressColor,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  progressText,
                  style: TextStyle(
                    color: progressColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  modulesText,
                  style: const TextStyle(color: AppColors.neutral500, fontSize: 12),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.access_time_rounded, color: AppColors.neutral500, size: 14),
                const SizedBox(width: 4),
                Text(
                  timeLeftText,
                  style: const TextStyle(
                    color: AppColors.neutral500,
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

class _ContinueLearningCard extends StatelessWidget {
  const _ContinueLearningCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.indigo500.withValues(alpha: 0.6)),
        boxShadow: [
          BoxShadow(
            color: AppColors.indigo500.withValues(alpha: 0.15),
            blurRadius: 24,
            spreadRadius: 0,
          ),
          BoxShadow(
            color: AppColors.indigo500.withValues(alpha: 0.3),
            blurRadius: 0,
            spreadRadius: 1, // simulates 0 0 0 1px shadow
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'JWT Authentication Deep Dive',
            style: TextStyle(
              color: AppColors.neutral50,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'Backend Security',
            style: TextStyle(color: AppColors.neutral400, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Tag(label: 'Security', color: AppColors.indigo500, textColor: AppColors.indigo400),
              const SizedBox(width: 8),
              _Tag(label: 'Auth', color: AppColors.amber, textColor: AppColors.amber),
              const SizedBox(width: 8),
              _Tag(label: 'JWT', color: AppColors.cyan, textColor: AppColors.cyan),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Learn how to issue, verify and refresh JSON Web Tokens securely, including signature validation and rotation strategies.',
            style: TextStyle(
              color: AppColors.neutral400,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 12),
          const Row(
            children: const [
              Icon(Icons.access_time_rounded, color: AppColors.neutral500, size: 14),
              SizedBox(width: 4),
              Text(
                '25 min',
                style: TextStyle(color: AppColors.neutral500, fontSize: 12),
              ),
              SizedBox(width: 16),
              Icon(Icons.menu_book_rounded, color: AppColors.neutral500, size: 14),
              SizedBox(width: 4),
              Text(
                '3 sections',
                style: TextStyle(color: AppColors.neutral500, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.indigo500,
              foregroundColor: AppColors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text('Continue', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, size: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color, required this.textColor});

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _RecentlyCompletedBox extends StatelessWidget {
  const _RecentlyCompletedBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderCard),
      ),
      child: const Column(
        children: const [
          _CompletedItem(
            title: 'REST API Design Principles',
            date: 'Apr 11',
            xp: '+50 XP',
            showDivider: true,
          ),
          _CompletedItem(
            title: 'React Hooks in Depth',
            date: 'Apr 09',
            xp: '+40 XP',
            showDivider: true,
          ),
          _CompletedItem(
            title: 'Password Hashing with Bcrypt',
            date: 'Apr 07',
            xp: '+35 XP',
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

class _CompletedItem extends StatelessWidget {
  const _CompletedItem({
    required this.title,
    required this.date,
    required this.xp,
    required this.showDivider,
  });

  final String title;
  final String date;
  final String xp;
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
        children: [
          const Icon(Icons.check_circle_outline_rounded, color: AppColors.emerald, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.neutral50,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: const TextStyle(
                    color: AppColors.neutral500,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.emerald.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              xp,
              style: const TextStyle(
                color: AppColors.emerald,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
