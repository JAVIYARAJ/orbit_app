import 'package:flutter/material.dart';
import 'package:orbit_app/app/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

class VercelPage extends StatelessWidget {
  const VercelPage({super.key});

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
          children: const [
            Text(
              'Vercel',
              style: TextStyle(
                color: AppColors.neutral50,
                fontSize: 24, // text-[28px] roughly
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'Connected · vercel.com',
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
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.settings_outlined,
                color: AppColors.neutral400,
                size: 20,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: const [
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: _ProfileCard(),
          ),
          SizedBox(height: 24),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'DEPLOYMENTS',
              style: TextStyle(
                color: AppColors.neutral400,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
          ),
          SizedBox(height: 12),
          _FiltersRow(),
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                _DeploymentCard(
                  statusColor: AppColors.emerald,
                  repo: 'atlas-api-gateway',
                  deployId: 'dpl_a3f9c12',
                  branch: 'main',
                  commitHash: 'a3f9c12',
                  environment: 'Production',
                  time: '12m ago',
                  url: 'atlas-api-gateway.vercel.app',
                ),
                SizedBox(height: 12),
                _DeploymentCard(
                  statusColor: AppColors.amber,
                  repo: 'nebula-analytics',
                  deployId: 'dpl_b7e2d45',
                  branch: 'feat/dashboard',
                  commitHash: 'b7e2d45',
                  environment: 'Preview',
                  time: 'Just now',
                  url: 'nebula-analytics-git-feat.vercel.app',
                ),
                SizedBox(height: 12),
                _DeploymentCard(
                  statusColor: AppColors.emerald,
                  repo: 'orbit-dashboard',
                  deployId: 'dpl_c1a8f33',
                  branch: 'main',
                  commitHash: 'c1a8f33',
                  environment: 'Production',
                  time: '2h ago',
                  url: 'orbit-dashboard.vercel.app',
                ),
                SizedBox(height: 12),
                _DeploymentCard(
                  statusColor: AppColors.rose600,
                  repo: 'forge-ci-runner',
                  deployId: 'dpl_d4b6e21',
                  branch: 'fix/auth',
                  commitHash: 'd4b6e21',
                  environment: 'Preview',
                  time: '3h ago',
                  url: 'forge-ci-runner-git-fix.vercel.app',
                ),
                SizedBox(height: 12),
                _DeploymentCard(
                  statusColor: AppColors.emerald,
                  repo: 'vault-secrets',
                  deployId: 'dpl_e9c3a17',
                  branch: 'main',
                  commitHash: 'e9c3a17',
                  environment: 'Production',
                  time: 'Yesterday',
                  url: 'vault-secrets.vercel.app',
                ),
              ],
            ),
          ),
          SizedBox(height: 32),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'USAGE THIS MONTH',
              style: TextStyle(
                color: AppColors.neutral400,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
          ),
          SizedBox(height: 12),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: _UsageBox(),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderCard),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            child: const Icon(Icons.change_history_rounded, color: AppColors.white, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'alexlambert',
                  style: TextStyle(
                    color: AppColors.neutral50,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Pro Plan',
                  style: TextStyle(
                    color: AppColors.neutral400,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.emerald,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Connected',
                      style: TextStyle(
                        color: AppColors.emerald, // actually emerald-400 in React
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.neutral300,
              side: const BorderSide(color: AppColors.chip),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              minimumSize: Size.zero,
            ),
            child: const Text('Manage', style: TextStyle(fontSize: 12)),
          ),
        ],
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
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _FilterChip(label: 'All', isSelected: true),
          SizedBox(width: 8),
          _FilterChip(label: 'Production', isSelected: false),
          SizedBox(width: 8),
          _FilterChip(label: 'Preview', isSelected: false),
          SizedBox(width: 8),
          _FilterChip(label: 'Failed', isSelected: false),
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
        color: isSelected ? AppColors.neutral200 : Colors.transparent,
        borderRadius: BorderRadius.circular(999),
        border: isSelected ? null : Border.all(color: AppColors.borderCard),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.black : AppColors.neutral400,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
      ),
    );
  }
}

class _DeploymentCard extends StatelessWidget {
  const _DeploymentCard({
    required this.statusColor,
    required this.repo,
    required this.deployId,
    required this.branch,
    required this.commitHash,
    required this.environment,
    required this.time,
    required this.url,
  });

  final Color statusColor;
  final String repo;
  final String deployId;
  final String branch;
  final String commitHash;
  final String environment;
  final String time;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Container(
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
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  repo,
                  style: const TextStyle(
                    color: AppColors.neutral50,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                deployId,
                style: const TextStyle(
                  color: AppColors.neutral500,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.alt_route_rounded, color: AppColors.neutral400, size: 14),
              const SizedBox(width: 4),
              Text(
                branch,
                style: const TextStyle(color: AppColors.neutral400, fontSize: 12),
              ),
              const SizedBox(width: 8),
              Text(
                commitHash,
                style: const TextStyle(
                  color: AppColors.cyan,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                'Deployed to',
                style: TextStyle(color: AppColors.neutral500, fontSize: 12),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: environment == 'Production' ? AppColors.emerald : Colors.transparent,
                  border: environment == 'Production' ? null : Border.all(color: AppColors.chip),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  environment,
                  style: TextStyle(
                    color: environment == 'Production' ? AppColors.white : AppColors.neutral300,
                    fontSize: 10,
                    fontWeight: environment == 'Production' ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                time,
                style: const TextStyle(
                  color: AppColors.neutral500,
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.borderCard, height: 1),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.open_in_new_rounded, color: AppColors.neutral400, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  url,
                  style: const TextStyle(color: AppColors.neutral400, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _UsageBox extends StatelessWidget {
  const _UsageBox();

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
          _UsageItem(
            icon: Icons.bolt_rounded,
            title: 'Bandwidth',
            value: '42.3 GB / 100 GB',
            progress: 0.42,
            progressColor: AppColors.neutral200,
          ),
          SizedBox(height: 16),
          _UsageItem(
            icon: Icons.access_time_rounded,
            title: 'Build Minutes',
            value: '180 / 6000',
            progress: 0.03,
            progressColor: AppColors.emerald,
          ),
          SizedBox(height: 16),
          _UsageItem(
            icon: Icons.language_rounded,
            title: 'Deployments',
            value: '47 / ∞',
            progress: 0.3,
            progressColor: AppColors.cyan,
          ),
        ],
      ),
    );
  }
}

class _UsageItem extends StatelessWidget {
  const _UsageItem({
    required this.icon,
    required this.title,
    required this.value,
    required this.progress,
    required this.progressColor,
  });

  final IconData icon;
  final String title;
  final String value;
  final double progress;
  final Color progressColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.neutral400, size: 16),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.neutral300,
                  fontSize: 14,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.neutral400,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 6,
          width: double.infinity,
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
      ],
    );
  }
}
