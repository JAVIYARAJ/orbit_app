import 'package:flutter/material.dart';
import 'package:orbit_app/app/theme/app_colors.dart';
import 'package:orbit_app/core/widgets/orbit_detail_app_bar.dart';
import 'package:orbit_app/core/widgets/orbit_square_button.dart';

class NoteDetailPage extends StatelessWidget {
  const NoteDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: OrbitDetailAppBar(
        title: 'Note',
        actions: [
          OrbitSquareButton(
            icon: Icons.push_pin,
            iconColor: AppColors.brand,
            onTap: () {},
          ),
          OrbitSquareButton(icon: Icons.more_horiz_rounded, onTap: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
              children: [
                // ── Title ─────────────────────────────────────────────────
                const Text(
                  'API Rate Limits',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 12),

                // ── Meta row ──────────────────────────────────────────────
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.brand.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: const Text(
                        'api',
                        style: TextStyle(
                          color: AppColors.brandSoft,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Text(
                      'Edited Today 09:15',
                      style: TextStyle(
                        color: AppColors.neutral400,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.borderFaint),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Add tag',
                            style: TextStyle(
                              color: AppColors.neutral400,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.add_rounded,
                            color: AppColors.neutral400,
                            size: 12,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(color: AppColors.borderFaint, height: 1),
                const SizedBox(height: 20),

                // ── Body ──────────────────────────────────────────────────
                const Text(
                  'The standard tier allows 1000 req/min per API key. '
                  'Requests beyond the limit return a 429 status code and are '
                  'throttled until the window resets.',
                  style: TextStyle(
                    color: AppColors.neutral300,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 16),
                const _Heading('## Burst Capacity'),
                const SizedBox(height: 16),
                const _Bullet(
                  'Token bucket refills automatically every 60s with fresh '
                  'allowance.',
                ),
                const SizedBox(height: 8),
                const _Bullet(
                  'Burst capacity is capped at 5000 req before hard '
                  'throttling kicks in.',
                ),
                const SizedBox(height: 16),
                const _Heading('## Headers'),
                const SizedBox(height: 16),
                const _CodeBlock('X-RateLimit-Limit: 1000'),
                const SizedBox(height: 12),
                const _CodeBlock('X-RateLimit-Remaining: 847'),
                const SizedBox(height: 16),
                const Text(
                  'On 429 responses, clients should respect the Retry-After '
                  'header before sending additional requests.',
                  style: TextStyle(
                    color: AppColors.neutral400,
                    fontSize: 14,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 24),
                const Row(
                  children: [
                    Icon(
                      Icons.add_rounded,
                      color: AppColors.neutral400,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Add block',
                      style: TextStyle(
                        color: AppColors.neutral400,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Formatting toolbar (sits above the shell's bottom nav) ───────
          const _FormatToolbar(),
        ],
      ),
    );
  }
}

// ── Content widgets ───────────────────────────────────────────────────────────

class _Heading extends StatelessWidget {
  const _Heading(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.neutral400,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Text(
              '•',
              style: TextStyle(
                color: AppColors.brand,
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.neutral400,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CodeBlock extends StatelessWidget {
  const _CodeBlock(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.cyan,
          fontSize: 14,
          fontFamily: 'monospace',
          height: 1.4,
        ),
      ),
    );
  }
}

// ── Formatting toolbar ────────────────────────────────────────────────────────

class _FormatToolbar extends StatelessWidget {
  const _FormatToolbar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.borderFaint)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _ToolButton(icon: Icons.format_bold_rounded),
          _ToolButton(icon: Icons.format_italic_rounded),
          _ToolButton(icon: Icons.code_rounded, active: true),
          _ToolButton(icon: Icons.title_rounded),
          _ToolButton(icon: Icons.format_list_bulleted_rounded),
          _ToolButton(icon: Icons.link_rounded),
        ],
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({required this.icon, this.active = false});
  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: active
            ? AppColors.brand.withValues(alpha: 0.20)
            : AppColors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        icon,
        size: 18,
        color: active ? AppColors.brandSoft : AppColors.neutral400,
      ),
    );
  }
}
