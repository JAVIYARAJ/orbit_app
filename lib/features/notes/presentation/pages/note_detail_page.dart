import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:orbit_app/app/theme/app_colors.dart';
import 'package:orbit_app/core/widgets/orbit_detail_app_bar.dart';
import 'package:orbit_app/core/widgets/orbit_square_button.dart';
import 'package:orbit_app/features/notes/domain/entities/note_entity.dart';

// ── Shared Helper Functions ──────────────────────────────────────────────────

Color _parseColor(String? colorCode) {
  if (colorCode == null) return AppColors.brand;
  try {
    if (colorCode.startsWith('#')) {
      return Color(int.parse(colorCode.substring(1, 7), radix: 16) + 0xFF000000);
    }
    return AppColors.brand;
  } catch (_) {
    return AppColors.brand;
  }
}

String _formatDateTime(String? dateStr) {
  if (dateStr == null) return 'Edited Today';
  try {
    final dt = DateTime.parse(dateStr);
    return 'Edited ${DateFormat('MMM d, HH:mm').format(dt)}';
  } catch (_) {
    return 'Edited Today';
  }
}

List<Widget> _parseBody(String body, double baseFontSize) {
  final List<Widget> widgets = [];
  final List<String> lines = body.split('\n');
  bool inCodeBlock = false;
  List<String> codeLines = [];

  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];
    final trimmed = line.trim();

    if (trimmed.startsWith('```')) {
      if (inCodeBlock) {
        widgets.add(_CodeBlock(codeLines.join('\n'), fontSize: baseFontSize * 0.9));
        codeLines = [];
        inCodeBlock = false;
      } else {
        inCodeBlock = true;
      }
      continue;
    }

    if (inCodeBlock) {
      codeLines.add(line);
      continue;
    }

    if (trimmed.isEmpty) {
      widgets.add(const SizedBox(height: 12));
      continue;
    }

    if (trimmed.startsWith('# ') || trimmed.startsWith('## ') || trimmed.startsWith('### ') || trimmed.startsWith('#### ')) {
      final cleanText = trimmed.replaceFirst(RegExp(r'^#+\s*'), '');
      widgets.add(_Heading(cleanText, fontSize: baseFontSize * 1.25));
      widgets.add(const SizedBox(height: 12));
    } else if (trimmed.startsWith('•') || trimmed.startsWith('-') || trimmed.startsWith('*')) {
      String cleanText = trimmed;
      if (cleanText.startsWith('•')) {
        cleanText = cleanText.substring(1).trim();
      } else if (cleanText.startsWith('-')) {
        cleanText = cleanText.substring(1).trim();
      } else if (cleanText.startsWith('*')) {
        cleanText = cleanText.substring(1).trim();
      }
      widgets.add(_Bullet(cleanText, fontSize: baseFontSize));
      widgets.add(const SizedBox(height: 8));
    } else {
      widgets.add(Text(
        line,
        style: TextStyle(
          color: AppColors.neutral300,
          fontSize: baseFontSize,
          height: 1.6,
        ),
      ));
      widgets.add(const SizedBox(height: 16));
    }
  }

  if (inCodeBlock && codeLines.isNotEmpty) {
    widgets.add(_CodeBlock(codeLines.join('\n'), fontSize: baseFontSize * 0.9));
  }

  return widgets;
}

// ── NoteDetailPage ───────────────────────────────────────────────────────────

class NoteDetailPage extends StatefulWidget {
  const NoteDetailPage({super.key, this.note});
  final NoteEntity? note;

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  final double _fontSize = 16.0;

  void _showFocusMode(BuildContext context, NoteEntity note) {
    Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => NoteFocusView(
          note: note,
          initialFontSize: _fontSize,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final note = widget.note;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: OrbitDetailAppBar(
        title: note?.title ?? 'Note',
        actions: [
          if (note != null)
            OrbitSquareButton(
              icon: Icons.visibility_rounded, // Eye icon to trigger full screen focus mode
              iconColor: AppColors.white,
              onTap: () => _showFocusMode(context, note),
            ),
          OrbitSquareButton(
            icon: Icons.push_pin,
            iconColor: note?.pinned == true ? AppColors.brand : AppColors.neutral400,
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
                Text(
                  note?.title ?? 'API Rate Limits',
                  style: const TextStyle(
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
                        color: _parseColor(note?.color).withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        note != null ? 'note' : 'api',
                        style: TextStyle(
                          color: _parseColor(note?.color),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Text(
                      note != null
                          ? _formatDateTime(note?.updatedAt ?? note?.createdAt)
                          : 'Edited Today 09:15',
                      style: const TextStyle(
                        color: AppColors.neutral400,
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                    ),
                    if (note == null)
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
                if (note != null)
                  ..._parseBody(note.body, 14.0)
                else ...[
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

// ── NoteFocusView ───────────────────────────────────────────────────────────

class NoteFocusView extends StatefulWidget {
  const NoteFocusView({
    super.key,
    required this.note,
    required this.initialFontSize,
  });

  final NoteEntity note;
  final double initialFontSize;

  @override
  State<NoteFocusView> createState() => _NoteFocusViewState();
}

class _NoteFocusViewState extends State<NoteFocusView> {
  late double _fontSize;
  bool _autoScrolling = false;
  double _scrollProgress = 0.0;
  
  late final ScrollController _focusScrollController;
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    _fontSize = widget.initialFontSize;
    _focusScrollController = ScrollController();
    _focusScrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _focusScrollController.removeListener(_onScroll);
    _focusScrollController.dispose();
    _autoScrollTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    if (_focusScrollController.hasClients) {
      final maxScroll = _focusScrollController.position.maxScrollExtent;
      final currentScroll = _focusScrollController.offset;
      if (maxScroll > 0) {
        setState(() {
          _scrollProgress = (currentScroll / maxScroll).clamp(0.0, 1.0);
        });
      }
    }
  }

  void _toggleAutoScroll() {
    if (_autoScrolling) {
      _stopAutoScroll();
    } else {
      _startAutoScroll();
    }
  }

  void _startAutoScroll() {
    setState(() {
      _autoScrolling = true;
    });
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_focusScrollController.hasClients) {
        final maxScroll = _focusScrollController.position.maxScrollExtent;
        final currentScroll = _focusScrollController.offset;
        if (currentScroll >= maxScroll) {
          _stopAutoScroll();
        } else {
          _focusScrollController.jumpTo(currentScroll + 0.8);
        }
      }
    });
  }

  void _stopAutoScroll() {
    _autoScrollTimer?.cancel();
    if (mounted) {
      setState(() {
        _autoScrolling = false;
      });
    }
  }

  int _getWordCount(String body) {
    if (body.isEmpty) return 0;
    return body.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  }

  String _getReadTime(int wordCount) {
    final minutes = (wordCount / 200).ceil();
    return '$minutes ${minutes == 1 ? 'MIN' : 'MINS'} READ';
  }

  @override
  Widget build(BuildContext context) {
    final note = widget.note;
    final wordCount = _getWordCount(note.body);
    final readTime = _getReadTime(wordCount);

    return Scaffold(
      backgroundColor: const Color(0xFF090A0C), // Minimalist focus mode background
      body: SafeArea(
        child: Column(
          children: [
            // Top Progress bar
            Container(
              width: double.infinity,
              height: 3,
              color: const Color(0xFF141518),
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: _scrollProgress,
                child: Container(
                  color: const Color(0xFF38BDF8), // Accent blue progress fill
                ),
              ),
            ),
            // Focus View App Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.title,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '$wordCount WORDS  ·  $readTime',
                          style: const TextStyle(
                            color: AppColors.neutral500,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.neutral400, size: 20),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFF141518), height: 1),
            
            // Scrolling content
            Expanded(
              child: ListView(
                controller: _focusScrollController,
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 80),
                children: [
                  Text(
                    note.title,
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: _fontSize * 1.5,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _parseColor(note.color).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'note',
                          style: TextStyle(
                            color: _parseColor(note.color),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        _formatDateTime(note.updatedAt ?? note.createdAt),
                        style: const TextStyle(
                          color: AppColors.neutral500,
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(color: Color(0xFF141518), height: 1),
                  const SizedBox(height: 24),
                  ..._parseBody(note.body, _fontSize),
                ],
              ),
            ),
            
            // Bottom Controls Bar
            Container(
              height: 56,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: const BoxDecoration(
                color: Color(0xFF0F1012),
                border: Border(top: BorderSide(color: Color(0xFF141518))),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Auto scroll toggle
                  GestureDetector(
                    onTap: _toggleAutoScroll,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: _autoScrolling ? const Color(0xFF38BDF8).withValues(alpha: 0.15) : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _autoScrolling ? const Color(0xFF38BDF8) : const Color(0xFF2C2D33),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _autoScrolling ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            color: _autoScrolling ? const Color(0xFF38BDF8) : AppColors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _autoScrolling ? 'Pause' : 'Auto Scroll',
                            style: TextStyle(
                              color: _autoScrolling ? const Color(0xFF38BDF8) : AppColors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Progress metric
                  Text(
                    '${(_scrollProgress * 100).toInt()}% READ',
                    style: const TextStyle(
                      color: AppColors.neutral500,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'monospace',
                    ),
                  ),
                  
                  // Sizing controls
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_rounded, color: AppColors.neutral400, size: 18),
                        onPressed: () {
                          setState(() {
                            _fontSize = (_fontSize - 1).clamp(12.0, 24.0);
                          });
                        },
                      ),
                      Text(
                        '${_fontSize.toInt()}',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_rounded, color: AppColors.neutral400, size: 18),
                        onPressed: () {
                          setState(() {
                            _fontSize = (_fontSize + 1).clamp(12.0, 24.0);
                          });
                        },
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

// ── Content widgets ───────────────────────────────────────────────────────────

class _Heading extends StatelessWidget {
  const _Heading(this.text, {this.fontSize});
  final String text;
  final double? fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: AppColors.neutral400,
        fontSize: fontSize ?? 16,
        fontWeight: FontWeight.w600,
        height: 1.4,
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet(this.text, {this.fontSize});
  final String text;
  final double? fontSize;

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
              style: TextStyle(
                color: AppColors.neutral400,
                fontSize: fontSize ?? 14,
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
  const _CodeBlock(this.text, {this.fontSize});
  final String text;
  final double? fontSize;

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
        style: TextStyle(
          color: AppColors.cyan,
          fontSize: fontSize ?? 14,
          fontFamily: 'monospace',
          height: 1.4,
          leadingDistribution: TextLeadingDistribution.proportional,
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
