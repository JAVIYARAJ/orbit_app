import 'package:flutter/material.dart';
import 'package:orbit_app/app/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

class LearningDetailPage extends StatelessWidget {
  const LearningDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leadingWidth: 200,
        leading: InkWell(
          onTap: () => context.pop(),
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          child: const Row(
            children: const [
              SizedBox(width: 24),
              Icon(Icons.arrow_back_rounded, color: AppColors.neutral400, size: 20),
              SizedBox(width: 8),
              Text(
                'Learning Path',
                style: TextStyle(
                  color: AppColors.neutral400,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surface, // bg-neutral-800
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.bar_chart_rounded,
                color: AppColors.neutral300,
                size: 16,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: const [
          _HeaderCard(),
          SizedBox(height: 24),
          _ProgressSection(),
          SizedBox(height: 24),
          Text(
            'MODULES',
            style: TextStyle(
              color: AppColors.neutral400,
              fontSize: 12,
              fontFamily: 'monospace',
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 12),
          _ModulesList(),
          SizedBox(height: 24),
          Text(
            'WHAT YOU\'LL LEARN',
            style: TextStyle(
              color: AppColors.neutral400,
              fontSize: 12,
              fontFamily: 'monospace',
              letterSpacing: 1.5,
            ),
          ),
          SizedBox(height: 12),
          _WhatYouWillLearnBox(),
          SizedBox(height: 24),
          _ContinueButton(),
        ],
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  const _HeaderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt, // #161A1F
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderCard), // white/10
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withValues(alpha: 0.15), // violet-500/15
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.code_rounded, color: Color(0xFFA78BFA), size: 24), // violet-400
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Expanded(
                      child: Text(
                        'Frontend Mastery',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.amber.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'In Progress',
                        style: TextStyle(
                          color: AppColors.amber,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'React, TypeScript, state management and modern UI patterns',
                  style: TextStyle(
                    color: AppColors.neutral400,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressSection extends StatelessWidget {
  const _ProgressSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: const [
            Text(
              '60% Complete',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            Spacer(),
            Text(
              '4/7 modules',
              style: TextStyle(
                color: AppColors.neutral400,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface, // neutral-700 roughly
            borderRadius: BorderRadius.circular(999),
          ),
          alignment: Alignment.centerLeft,
          child: FractionallySizedBox(
            widthFactor: 0.6,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.indigo500,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Row(
          children: const [
            Icon(Icons.access_time_rounded, color: AppColors.neutral400, size: 14),
            SizedBox(width: 6),
            Text(
              '~3h left',
              style: TextStyle(color: AppColors.neutral400, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}

class _ModulesList extends StatelessWidget {
  const _ModulesList();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: const [
        _ModuleItem(
          status: _ModuleStatus.completed,
          title: 'React Fundamentals',
          duration: '45 min',
        ),
        SizedBox(height: 8),
        _ModuleItem(
          status: _ModuleStatus.completed,
          title: 'TypeScript Basics',
          duration: '50 min',
        ),
        SizedBox(height: 8),
        _ModuleItem(
          status: _ModuleStatus.completed,
          title: 'State Management',
          duration: '1h 10 min',
        ),
        SizedBox(height: 8),
        _ModuleItem(
          status: _ModuleStatus.completed,
          title: 'Component Patterns',
          duration: '40 min',
        ),
        SizedBox(height: 8),
        _ModuleItem(
          status: _ModuleStatus.active,
          title: 'Advanced Hooks',
          duration: '55 min',
        ),
        SizedBox(height: 8),
        _ModuleItem(
          status: _ModuleStatus.pending,
          title: 'Performance Optimization',
          duration: '1h 05 min',
        ),
        SizedBox(height: 8),
        _ModuleItem(
          status: _ModuleStatus.pending,
          title: 'Testing Strategies',
          duration: '50 min',
        ),
      ],
    );
  }
}

enum _ModuleStatus { completed, active, pending }

class _ModuleItem extends StatelessWidget {
  const _ModuleItem({
    required this.status,
    required this.title,
    required this.duration,
  });

  final _ModuleStatus status;
  final String title;
  final String duration;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt, // #161A1F
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: status == _ModuleStatus.active
              ? AppColors.indigo500.withValues(alpha: 0.4)
              : AppColors.borderCard,
        ),
      ),
      child: Row(
        children: [
          if (status == _ModuleStatus.completed)
            const Icon(Icons.check_circle_outline_rounded, color: AppColors.emerald, size: 20)
          else if (status == _ModuleStatus.active)
            const Icon(Icons.play_circle_outline_rounded, color: AppColors.indigo400, size: 20)
          else
            const Icon(Icons.radio_button_unchecked_rounded, color: AppColors.neutral600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: status == _ModuleStatus.pending ? AppColors.neutral500 : AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  duration,
                  style: TextStyle(
                    color: status == _ModuleStatus.pending ? AppColors.neutral500 : AppColors.neutral400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (status == _ModuleStatus.completed)
            const Icon(Icons.chevron_right_rounded, color: AppColors.neutral500, size: 16)
          else if (status == _ModuleStatus.active)
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.indigo500,
                foregroundColor: AppColors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                minimumSize: const Size(0, 28),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: const Row(
                children: [
                  Text('Continue', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward_rounded, size: 12),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _WhatYouWillLearnBox extends StatelessWidget {
  const _WhatYouWillLearnBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderCard),
      ),
      child: const Column(
        children: const [
          _LearnItem('Build scalable React applications'),
          SizedBox(height: 12),
          _LearnItem('Master TypeScript generics'),
          SizedBox(height: 12),
          _LearnItem('Implement complex state patterns'),
          SizedBox(height: 12),
          _LearnItem('Write maintainable component tests'),
        ],
      ),
    );
  }
}

class _LearnItem extends StatelessWidget {
  const _LearnItem(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: AppColors.indigo500,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.neutral300,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class _ContinueButton extends StatelessWidget {
  const _ContinueButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.indigo500, // wait, React code says bg-indigo-500 but icon is maybe different, wait, in React code: bg-indigo-500 text-white gap-2 w-full h-12. Wait, screenshot 2 shows a violet looking button or indigo.
        foregroundColor: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        minimumSize: const Size(double.infinity, 48),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Text('Continue Learning', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          SizedBox(width: 8),
          Icon(Icons.arrow_forward_rounded, size: 16),
        ],
      ),
    );
  }
}
