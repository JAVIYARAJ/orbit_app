import 'package:flutter/material.dart';
import 'package:orbit_app/app/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

class GithubPage extends StatelessWidget {
  const GithubPage({super.key});

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
              'GitHub',
              style: TextStyle(
                color: AppColors.neutral50,
                fontSize: 24, // text-[28px] roughly
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              'Connected · github.com',
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
                Icons.code_rounded,
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
              'REPOSITORIES',
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
            child: _SearchBar(),
          ),
          SizedBox(height: 16),
          _FiltersRow(),
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                _RepoCard(
                  name: 'atlas-api-gateway',
                  stars: '128',
                  description:
                      'Central API gateway with routing, auth middleware, and rate limiting for all Orbit services.',
                  language: 'TypeScript',
                  languageColor: AppColors.indigo500,
                  forks: '3',
                  updatedAt: 'Updated 2h ago',
                ),
                SizedBox(height: 12),
                _RepoCard(
                  name: 'nebula-analytics',
                  stars: '86',
                  description:
                      'Real-time analytics pipeline and dashboarding engine for product usage metrics.',
                  language: 'TypeScript',
                  languageColor: AppColors.indigo500,
                  forks: '2',
                  updatedAt: 'Updated 5h ago',
                ),
                SizedBox(height: 12),
                _RepoCard(
                  name: 'forge-ci-runner',
                  stars: '204',
                  description:
                      'Self-hosted CI runner with parallel job execution and container caching support.',
                  language: 'Go',
                  languageColor: AppColors.cyan,
                  forks: '4',
                  updatedAt: 'Updated Yesterday',
                ),
                SizedBox(height: 12),
                _RepoCard(
                  name: 'orbit-dashboard',
                  stars: '52',
                  description:
                      'Main web dashboard UI for the Orbit self-hosted developer operating system.',
                  language: 'TypeScript',
                  languageColor: AppColors.indigo500,
                  forks: '1',
                  updatedAt: 'Updated Apr 10',
                ),
                SizedBox(height: 12),
                _RepoCard(
                  name: 'vault-secrets-manager',
                  stars: '97',
                  description:
                      'AES-256 encrypted secrets vault with environment scoping and sync support.',
                  language: 'JavaScript',
                  languageColor: AppColors.amber,
                  forks: '2',
                  updatedAt: 'Updated Apr 08',
                ),
              ],
            ),
          ),
          SizedBox(height: 32),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'RECENT ACTIVITY',
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
            child: _RecentActivityBox(),
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.person, color: AppColors.neutral50),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Alex Lambert',
                  style: TextStyle(
                    color: AppColors.neutral50,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  '@alexlambert',
                  style: TextStyle(
                    color: AppColors.neutral400,
                    fontSize: 14,
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
                        color: AppColors.emerald,
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
            child: const Text('Disconnect', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderCard),
      ),
      child: const Row(
        children: [
          Icon(Icons.search_rounded, color: AppColors.neutral500, size: 16),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              style: TextStyle(color: AppColors.neutral50, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search repos...',
                hintStyle: TextStyle(color: AppColors.neutral500, fontSize: 14),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
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
          _FilterChip(label: 'Starred', isSelected: false),
          SizedBox(width: 8),
          _FilterChip(label: 'Recent', isSelected: false),
          SizedBox(width: 8),
          _FilterChip(label: 'Forked', isSelected: false),
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
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _RepoCard extends StatelessWidget {
  const _RepoCard({
    required this.name,
    required this.stars,
    required this.description,
    required this.language,
    required this.languageColor,
    required this.forks,
    required this.updatedAt,
  });

  final String name;
  final String stars;
  final String description;
  final String language;
  final Color languageColor;
  final String forks;
  final String updatedAt;

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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                name,
                style: const TextStyle(
                  color: AppColors.neutral50,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                children: [
                  const Icon(Icons.star_border_rounded, color: AppColors.neutral400, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    stars,
                    style: const TextStyle(color: AppColors.neutral400, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: AppColors.neutral400,
              fontSize: 12,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: languageColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                language,
                style: const TextStyle(color: AppColors.neutral500, fontSize: 12),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.alt_route_rounded, color: AppColors.neutral500, size: 14), // Use alt_route for GitBranch roughly
              const SizedBox(width: 4),
              Text(
                forks,
                style: const TextStyle(color: AppColors.neutral500, fontSize: 12),
              ),
              const Spacer(),
              Text(
                updatedAt,
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
    );
  }
}

class _RecentActivityBox extends StatelessWidget {
  const _RecentActivityBox();

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
          _ActivityItem(
            icon: Icons.commit_rounded,
            title: 'Pushed 3 commits',
            subtitle: 'atlas-api-gateway',
            time: '2h ago',
            showDivider: true,
          ),
          _ActivityItem(
            icon: Icons.merge_type_rounded, // or wrap_text
            title: 'Opened pull request #42',
            subtitle: 'nebula-analytics',
            time: '5h ago',
            showDivider: true,
          ),
          _ActivityItem(
            icon: Icons.alt_route_rounded,
            title: 'Merged branch develop',
            subtitle: 'forge-ci-runner',
            time: 'Yesterday',
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.showDivider,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
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
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.neutral300, size: 16),
          ),
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.neutral400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
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
    );
  }
}
