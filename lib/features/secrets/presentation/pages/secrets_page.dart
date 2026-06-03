import 'package:flutter/material.dart';
import 'package:orbit_app/app/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

class SecretsPage extends StatelessWidget {
  const SecretsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading:
            false, // We'll add custom back if needed, but the design doesn't have a back button. Wait, if it's pushed from drawer, it should have one. Let's add a back button to match standard push behaviour, or maybe just close button? I'll add a back button since it's pushed.
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Header & Search ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Secrets',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 28, // text-3xl
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Encrypted · Self-hosted · AES-256',
                            style: TextStyle(
                              color: AppColors.neutral500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: AppColors.neutral200,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: AppColors.black,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Search Bar
                  Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.chip),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          color: AppColors.neutral500,
                          size: 16,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Search secrets...',
                          style: TextStyle(
                            color: AppColors.neutral500,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Filters Row
                  SizedBox(
                    height: 32,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      // We use negative margin equivalent in Flutter by wrapping ListView in SizedBox and using no padding or slightly shifting
                      children: const [
                        _FilterChip(label: 'All', isActive: true),
                        SizedBox(width: 8),
                        _FilterChip(label: 'API Keys'),
                        SizedBox(width: 8),
                        _FilterChip(label: 'Tokens'),
                        SizedBox(width: 8),
                        _FilterChip(label: 'Passwords'),
                        SizedBox(width: 8),
                        _FilterChip(label: 'Env Vars'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Secrets List ──────────────────────────────────────────────
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                children: const [
                  _SecretItem(
                    title: 'STRIPE_SECRET_KEY',
                    type: 'API Key',
                    iconColor: AppColors.indigo400,
                  ),
                  SizedBox(height: 8),
                  _SecretItem(
                    title: 'GITHUB_ACCESS_TOKEN',
                    type: 'Token',
                    iconColor: AppColors.amber400,
                  ),
                  SizedBox(height: 8),
                  _SecretItem(
                    title: 'DATABASE_URL',
                    type: 'Env Var',
                    iconColor: AppColors.emerald400,
                  ),
                  SizedBox(height: 8),
                  _SecretItem(
                    title: 'SENDGRID_API_KEY',
                    type: 'API Key',
                    iconColor: AppColors.indigo400,
                  ),
                  SizedBox(height: 8),
                  _SecretItem(
                    title: 'JWT_SECRET',
                    type: 'Password',
                    iconColor: AppColors.rose400,
                  ),
                  SizedBox(height: 8),
                  _SecretItem(
                    title: 'REDIS_PASSWORD',
                    type: 'Password',
                    iconColor: AppColors.rose400,
                  ),
                  SizedBox(height: 8),
                  _SecretItem(
                    title: 'AWS_ACCESS_KEY_ID',
                    type: 'API Key',
                    iconColor: AppColors.indigo400,
                  ),

                  SizedBox(height: 24),
                  // Last synced
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.autorenew_rounded,
                        color: AppColors.neutral500,
                        size: 12,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Last synced: Today 10:41',
                        style: TextStyle(
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
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, this.isActive = false});

  final String label;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? AppColors.neutral200 : AppColors.transparent,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isActive ? AppColors.transparent : AppColors.chip,
        ),
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? AppColors.black : AppColors.neutral400,
            fontSize: 12,
            fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _SecretItem extends StatelessWidget {
  const _SecretItem({
    required this.title,
    required this.type,
    required this.iconColor,
  });

  final String title;
  final String type;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.chip),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.chip,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.lock_outline_rounded, color: iconColor, size: 16),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      type,
                      style: const TextStyle(
                        color: AppColors.neutral500,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        '••••••••••••',
                        style: TextStyle(
                          color: AppColors.neutral600,
                          fontSize: 12,
                          fontFamily: 'monospace',
                          letterSpacing: 2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                icon: const Icon(
                  Icons.visibility_outlined,
                  color: AppColors.neutral400,
                  size: 16,
                ),
                onPressed: () {},
              ),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                icon: const Icon(
                  Icons.copy_rounded,
                  color: AppColors.neutral400,
                  size: 16,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
