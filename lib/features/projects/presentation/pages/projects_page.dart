import 'package:flutter/material.dart';
import 'package:orbit_app/app/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:orbit_app/core/widgets/orbit_icon.dart';

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _Header(),
            const _SearchBar(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                children: const [
                  _ProjectCard(
                    title: 'Atlas API Gateway',
                    description:
                        'Unified routing layer for internal microservices.',
                    color: AppColors.brand,
                    progress: 0.72,
                    tags: ['Node.js', 'PostgreSQL', 'Docker'],
                    updatedAt: '2h ago',
                    avatars: [
                      _Avatar(
                        label: 'A',
                        color: AppColors.brand,
                        isDarkText: false,
                      ),
                      _Avatar(
                        label: 'E',
                        color: AppColors.teal,
                        isDarkText: true,
                      ),
                      _Avatar(
                        label: '+3',
                        color: AppColors.chip,
                        isDarkText: false,
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  _ProjectCard(
                    title: 'Nebula Analytics',
                    description: 'Real-time event ingestion and dashboards.',
                    color: AppColors.teal,
                    progress: 0.45,
                    tags: ['Go', 'ClickHouse', 'Redis'],
                    updatedAt: '5h ago',
                    avatars: [
                      _Avatar(
                        label: 'C',
                        color: AppColors.teal,
                        isDarkText: true,
                      ),
                      _Avatar(
                        label: '+1',
                        color: AppColors.chip,
                        isDarkText: false,
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  _ProjectCard(
                    title: 'Forge CI Runner',
                    description: 'Self-hosted build and deployment pipelines.',
                    color: AppColors.amber600,
                    progress: 0.88,
                    tags: ['Rust', 'Docker', 'gRPC'],
                    updatedAt: '1d ago',
                    avatars: [
                      _Avatar(
                        label: 'D',
                        color: AppColors.amber600,
                        isDarkText: true,
                      ),
                      _Avatar(
                        label: 'E',
                        color: AppColors.chip,
                        isDarkText: false,
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  _ProjectCard(
                    title: 'Vault Secrets',
                    description: 'Encrypted secret storage and rotation.',
                    color: AppColors.teal,
                    progress: 0.60,
                    tags: ['Go', 'SQLite', 'AES'],
                    updatedAt: '3d ago',
                    avatars: [
                      _Avatar(
                        label: 'F',
                        color: AppColors.teal,
                        isDarkText: true,
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  _ProjectCard(
                    title: 'Pulse Monitoring',
                    description: 'Uptime checks and alerting for services.',
                    color: AppColors.rose600,
                    progress: 0.33,
                    tags: ['Python', 'Prometheus', 'Grafana'],
                    updatedAt: '6h ago',
                    avatars: [
                      _Avatar(
                        label: 'G',
                        color: AppColors.rose600,
                        isDarkText: false,
                      ),
                      _Avatar(
                        label: '+2',
                        color: AppColors.chip,
                        isDarkText: false,
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  _ProjectCard(
                    title: 'Comet Docs',
                    description: 'Internal documentation and knowledge base.',
                    color: AppColors.purple600,
                    progress: 0.95,
                    tags: ['Next.js', 'MDX', 'Tailwind'],
                    updatedAt: '30m ago',
                    avatars: [
                      _Avatar(
                        label: 'H',
                        color: AppColors.purple600,
                        isDarkText: false,
                      ),
                      _Avatar(
                        label: 'I',
                        color: AppColors.teal,
                        isDarkText: true,
                      ),
                      _Avatar(
                        label: '+4',
                        color: AppColors.chip,
                        isDarkText: false,
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  _ArchivedButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Projects',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '6 active · 2 archived',
                style: TextStyle(
                  color: AppColors.neutral500,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
          ),
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: kOrbitIndigo,
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.add_rounded, color: AppColors.white, size: 24),
            ),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surfaceAlt,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderCard),
        ),
        child: const Row(
          children: [
            Icon(Icons.search_rounded, color: AppColors.neutral500, size: 18),
            SizedBox(width: 8),
            Expanded(
              child: TextField(
                style: TextStyle(color: AppColors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Search projects…',
                  hintStyle: TextStyle(
                    color: AppColors.neutral500,
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

class _Avatar {
  const _Avatar({
    required this.label,
    required this.color,
    required this.isDarkText,
  });
  final String label;
  final Color color;
  final bool isDarkText;
}

class _ProjectCard extends StatelessWidget {
  const _ProjectCard({
    required this.title,
    required this.description,
    required this.color,
    required this.progress,
    required this.tags,
    required this.updatedAt,
    required this.avatars,
  });

  final String title;
  final String description;
  final Color color;
  final double progress;
  final List<String> tags;
  final String updatedAt;
  final List<_Avatar> avatars;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/projects/detail'),
      behavior: HitTestBehavior.opaque,
      child: Container(
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
              // Left color stripe
              Container(width: 4, color: color),

              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Description
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: const TextStyle(
                          color: AppColors.neutral400,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Tags
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: tags
                            .map((tag) => _TagChip(label: tag))
                            .toList(),
                      ),
                      const SizedBox(height: 16),

                      // Progress
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Progress',
                            style: TextStyle(
                              color: AppColors.neutral400,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: const TextStyle(
                              color: AppColors.neutral400,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 6,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.chip,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: progress,
                          child: Container(
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Footer: Avatars + Timestamp
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Avatars
                          Row(
                            children: [
                              for (int i = 0; i < avatars.length; i++)
                                Transform.translate(
                                  offset: Offset(i == 0 ? 0 : -8.0 * i, 0),
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: avatars[i].color,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColors.surfaceAlt,
                                        width: 2,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        avatars[i].label,
                                        style: TextStyle(
                                          color: avatars[i].isDarkText
                                              ? AppColors.black
                                              : AppColors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),

                          Text(
                            'Updated $updatedAt',
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.chip,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 12,
          height: 1.33,
        ),
      ),
    );
  }
}

class _ArchivedButton extends StatelessWidget {
  const _ArchivedButton();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderCard),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text(
                'Archived Projects',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.chip,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Text(
                  '2',
                  style: TextStyle(color: AppColors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: AppColors.neutral500,
            size: 18,
          ),
        ],
      ),
    );
  }
}
