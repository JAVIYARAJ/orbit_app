import 'package:cached_network_image/cached_network_image.dart';
import 'package:feature_gate_pro/feature_gate_pro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:orbit_app/app/router/app_router.dart';
import 'package:orbit_app/app/theme/app_colors.dart';
import 'package:orbit_app/core/widgets/orbit_icon.dart';
import 'package:orbit_app/features/dashboard/domain/entities/dashboard_entity.dart';
import 'package:orbit_app/features/dashboard/presentation/cubit/dashboard_cubit.dart';
import 'package:orbit_app/features/dashboard/presentation/cubit/dashboard_state.dart';
import 'package:orbit_app/features/workspaces/presentation/cubit/workspace_cubit.dart';
import 'package:orbit_app/features/workspaces/presentation/cubit/workspace_state.dart';
import 'package:orbit_app/features/workspaces/presentation/widgets/workspace_switcher_sheet.dart';

/// Home / Dashboard screen.
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    final wsState = context.read<WorkspaceCubit>().state;
    if (wsState.status == WorkspaceStatus.loaded && wsState.selectedWorkstation != null) {
      context.read<DashboardCubit>().fetchDashboard(wsState.selectedWorkstation!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WorkspaceCubit, WorkspaceState>(
      listenWhen: (previous, current) {
        final prevWs = previous.selectedWorkstation?.id;
        final currWs = current.selectedWorkstation?.id;
        return prevWs != currWs && currWs != null;
      },
      listener: (context, state) {
        if (state.status == WorkspaceStatus.loaded && state.selectedWorkstation != null) {
          context.read<DashboardCubit>().fetchDashboard(state.selectedWorkstation!.id);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<DashboardCubit, DashboardState>(
            builder: (context, state) {
              if (state is DashboardInitial || state is DashboardLoading) {
                return const Center(child: CircularProgressIndicator(color: kOrbitIndigo));
              }

              if (state is DashboardError) {
                return Center(
                  child: Text(
                    'Failed to load dashboard: ${state.message}',
                    style: const TextStyle(color: AppColors.rose),
                  ),
                );
              }

              if (state is DashboardLoaded) {
                final data = state.dashboard;
                return CustomScrollView(
                  slivers: [
                    const SliverAppBar(
                      pinned: true,
                      backgroundColor: AppColors.background,
                      surfaceTintColor: Colors.transparent,
                      elevation: 0,
                      scrolledUnderElevation: 0,
                      systemOverlayStyle: SystemUiOverlayStyle(
                        statusBarColor: Colors.transparent,
                        statusBarIconBrightness: Brightness.light,
                      ),
                      automaticallyImplyLeading: false,
                      titleSpacing: 0,
                      title: _TopBar(),
                    ),
                    SliverToBoxAdapter(child: _Greeting(user: data.user)),
                    const SliverToBoxAdapter(child: _ActionButtonsRow()),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                    SliverToBoxAdapter(
                      child: FeatureFlagWidget(
                        defaultValue: true,
                        flagKey: "dashboard_timer_tracker",
                        fallback: const SizedBox(),
                        child: _TelemetryGrid(
                          stats: data.quickStats,
                          timeTracker: data.timeTracker,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 32)),
                    SliverToBoxAdapter(child: _SprintRadar(radar: data.sprintRadar)),
                    const SliverToBoxAdapter(child: SizedBox(height: 32)),
                    SliverToBoxAdapter(child: _ActiveProjects(projects: data.projects)),
                    const SliverToBoxAdapter(child: SizedBox(height: 32)),
                    SliverToBoxAdapter(child: _TelemetryNotes(notes: data.notes)),
                    const SliverToBoxAdapter(child: SizedBox(height: 32)),
                    SliverToBoxAdapter(child: _PreconfiguredTemplates(templates: data.templates)),
                    const SliverToBoxAdapter(child: SizedBox(height: 48)),
                  ],
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Top app bar
// ─────────────────────────────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // ── Orbit logo badge ──────────────────────────────────────────────
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: kOrbitIndigo.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kOrbitIndigo.withValues(alpha: 0.40)),
            ),
            child: const Center(child: OrbitIcon(size: 20, strokeWidth: 1.5)),
          ),
          const SizedBox(width: 8),
          const SizedBox(width: 8),
          BlocBuilder<WorkspaceCubit, WorkspaceState>(
            builder: (context, state) {
              final wsName = state.selectedWorkstation?.name ?? 'Orbit';
              return GestureDetector(
                onTap: () => WorkspaceSwitcherSheet.show(context),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      wsName,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.neutral400,
                      size: 20,
                    ),
                  ],
                ),
              );
            },
          ),
          const Spacer(),

          // ── Bell button ───────────────────────────────────────────────────
          GestureDetector(
            onTap: () => context.push(AppRoutes.notifications),
            behavior: HitTestBehavior.opaque,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.surfaceAlt, AppColors.surface],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    border: Border.all(
                      color: AppColors.neutral500.withValues(alpha: 0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.notifications_rounded,
                      size: 18,
                      color: AppColors.neutral200,
                    ),
                  ),
                ),
                // Red notification dot
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.rose,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.rose.withValues(alpha: 0.6),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // ── Avatar ────────────────────────────────────────────────────────
          BlocBuilder<WorkspaceCubit, WorkspaceState>(
            builder: (context, state) {
              final user = state.contextEntity?.user;
              final name = user?.name ?? user?.email ?? 'Alex';
              final initials = name.isNotEmpty
                  ? name.substring(0, 1).toUpperCase()
                  : 'A';
              final avatarUrl = user?.avatarUrl;

              return GestureDetector(
                onLongPress: () => WorkspaceSwitcherSheet.show(context),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: kOrbitIndigo.withValues(alpha: 0.30),
                    border: Border.all(
                      color: kOrbitIndigo.withValues(alpha: 0.40),
                    ),
                    image: avatarUrl != null && avatarUrl.isNotEmpty
                        ? DecorationImage(
                            image: CachedNetworkImageProvider(avatarUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: avatarUrl == null || avatarUrl.isEmpty
                      ? Center(
                          child: Text(
                            initials,
                            style: const TextStyle(
                              color: AppColors.amber600,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              height: 1,
                            ),
                          ),
                        )
                      : null,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Greeting
// ─────────────────────────────────────────────────────────────────────────────

class _Greeting extends StatelessWidget {
  const _Greeting({required this.user});

  final DashboardUser user;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = user.name.split(' ').firstOrNull ?? 'Guest';
    final greeting = _getGreeting();

    return Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // SYSTEM ONLINE Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: AppColors.teal.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.teal,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'SYSTEM ONLINE',
                      style: TextStyle(
                        color: AppColors.teal,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Greeting
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.white, Color(0xFF81D4FA)],
                  // White to light blue
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: Text(
                  '$greeting, $name.',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.0,
                    height: 1.1,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Subtext
              const Text(
                'Today — No tasks due today.',
                style: TextStyle(
                  color: AppColors.neutral400,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Action Buttons Row
// ─────────────────────────────────────────────────────────────────────────────

class _ActionButtonsRow extends StatelessWidget {
  const _ActionButtonsRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        physics: const BouncingScrollPhysics(),
        children: const [
          _ActionButton(
            title: 'Time Tracker',
            subtitle: 'Start tracking',
            icon: Icons.timer_outlined,
            iconBg: kOrbitIndigo,
          ),
          SizedBox(width: 12),
          _ActionButton(
            title: 'Create Task',
            subtitle: 'Add to sprint backlog',
            icon: Icons.add,
            iconColor: AppColors.white,
            iconBg: kOrbitIndigo,
          ),
          SizedBox(width: 12),
          _ActionButton(
            title: 'Capture Thought',
            subtitle: 'Quick text pad note',
            icon: Icons.note_add_outlined,
            iconBg: kOrbitIndigo,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.iconColor = AppColors.neutral300,
    this.iconBg,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color? iconBg;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderNeutral, width: 1.0),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg ?? AppColors.neutral500.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: Icon(icon, color: iconColor, size: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.neutral400,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Telemetry Grid
// ─────────────────────────────────────────────────────────────────────────────

class _TelemetryGrid extends StatelessWidget {
  const _TelemetryGrid({
    required this.stats,
    required this.timeTracker,
  });

  final DashboardQuickStats stats;
  final DashboardTimeTracker timeTracker;

  String _formatElapsed(int seconds) {
    final h = (seconds ~/ 3600).toString().padLeft(2, '0');
    final m = ((seconds % 3600) ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Large Telemetry Tracker
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderNeutral),
            ),
            child: Row(
              children: [
                // Start button circle
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.neutral500.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: AppColors.neutral200,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'ACTIVE TELEMETRY TRACKER',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: AppColors.neutral500,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatElapsed(timeTracker.elapsedSeconds),
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'monospace',
                          letterSpacing: -1.0,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: timeTracker.running ? AppColors.emerald : AppColors.amber600,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              timeTracker.running
                                  ? '${timeTracker.taskTitle ?? 'Unknown Task'}'
                                  : 'System Idle — Waiting for launch',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: timeTracker.running ? AppColors.emerald : AppColors.amber600,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
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
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SmallStatCard(
                  title: 'HOURS LOGGED',
                  value: '${stats.hoursLoggedThisWeek}h',
                  subtext: 'vs last week: ${stats.weekDifferenceMinutes}m',
                  subtextColor: AppColors.teal,
                  icon: Icons.timer_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SmallStatCard(
                  title: 'DEV STREAK',
                  value: '${stats.devStreak}d',
                  subtext: 'Personal record: ${stats.personalBest} days',
                  icon: Icons.local_fire_department_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SmallStatCard(
                  title: 'ACTIVE PROJECTS',
                  value: '${stats.activeProjects}',
                  subtext: 'Ready to start projects',
                  icon: Icons.folder_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SmallStatCard(
                  title: 'SPRINT BACKLOG',
                  value: '${stats.backlogTasks}',
                  subtext: 'Zero overdue items',
                  icon: Icons.format_list_bulleted_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SmallStatCard extends StatelessWidget {
  const _SmallStatCard({
    required this.title,
    required this.value,
    required this.subtext,
    this.subtextColor = AppColors.neutral400,
    required this.icon,
  });

  final String title;
  final String value;
  final String subtext;
  final Color subtextColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 116, // Fixed height ensures all 4 cards are perfectly identical
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderNeutral),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.neutral400,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(icon, size: 14, color: AppColors.neutral500),
            ],
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                height: 1.0,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            subtext,
            style: TextStyle(
              color: subtextColor,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sprint Radar
// ─────────────────────────────────────────────────────────────────────────────

class _SprintRadar extends StatelessWidget {
  const _SprintRadar({required this.radar});
  
  final DashboardSprintRadar radar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'Sprint Radar',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: kOrbitIndigo.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${radar.count} tasks',
                  style: const TextStyle(
                    color: kOrbitIndigo,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
              const Row(
                children: [
                  Text(
                    'View All',
                    style: TextStyle(
                      color: AppColors.neutral400,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: AppColors.neutral400,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderNeutral),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: radar.tasks.take(6).length,
              separatorBuilder: (context, index) => Container(
                height: 1,
                color: AppColors.borderNeutral,
              ),
              itemBuilder: (context, index) {
                final task = radar.tasks[index];
                return _RadarTask(task: task);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RadarTask extends StatelessWidget {
  const _RadarTask({required this.task});

  final DashboardSprintTask task;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.neutral500),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              task.title,
              style: const TextStyle(color: AppColors.white, fontSize: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Badges
          if (task.project != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.amber600.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: AppColors.amber600.withValues(alpha: 0.3),
                ),
            ),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.amber600,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    task.project!.shortId,
                    style: const TextStyle(
                      color: AppColors.amber600,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
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

// ─────────────────────────────────────────────────────────────────────────────
// Active Projects
// ─────────────────────────────────────────────────────────────────────────────

class _ActiveProjects extends StatelessWidget {
  const _ActiveProjects({required this.projects});

  final List<DashboardProject> projects;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Active Projects',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                children: [
                  const Text(
                    'All',
                    style: TextStyle(
                      color: AppColors.neutral400,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: AppColors.neutral400,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderNeutral),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: projects.take(3).length,
              separatorBuilder: (context, index) => Container(
                height: 1,
                color: AppColors.borderNeutral,
              ),
              itemBuilder: (context, index) {
                final project = projects[index];
                final progressDouble = (project.progress / 100).clamp(0.0, 1.0);
                return _ProjectItem(
                  id: project.id,
                  title: project.name,
                  subtitle: project.projectType?.label.toUpperCase() ?? 'PROJECT',
                  openCount: '${project.openTasks}',
                  loggedTime: '${project.hoursLogged.toStringAsFixed(1)}h logged',
                  progress: progressDouble,
                  progressText: '${project.progress.toInt()}%',
                  status: project.status.toUpperCase(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProjectItem extends StatelessWidget {
  const _ProjectItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.openCount,
    required this.loggedTime,
    required this.progress,
    required this.progressText,
    required this.status,
  });

  final String id;
  final String title;
  final String subtitle;
  final String openCount;
  final String loggedTime;
  final double progress;
  final String progressText;
  final String status;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.push('/projects/detail/$id');
      },
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.neutral500,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$openCount open  •  $loggedTime',
                    style: const TextStyle(
                      color: AppColors.neutral400,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: kOrbitIndigo.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: kOrbitIndigo.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: kOrbitIndigo,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        status.isNotEmpty ? status : 'IN PROGRESS',
                        style: const TextStyle(
                          color: kOrbitIndigo,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Progress
                Row(
                  children: [
                    Text(
                      progressText,
                      style: const TextStyle(
                        color: AppColors.neutral400,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.neutral700,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: progress,
                        child: Container(
                          decoration: BoxDecoration(
                            color: kOrbitIndigo,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Telemetry Notes
// ─────────────────────────────────────────────────────────────────────────────

class _TelemetryNotes extends StatelessWidget {
  const _TelemetryNotes({required this.notes});

  final List<DashboardNote> notes;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Telemetry Notes',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                children: [
                  const Text(
                    'All',
                    style: TextStyle(
                      color: AppColors.neutral400,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: AppColors.neutral400,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderNeutral),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: notes.take(3).length,
              separatorBuilder: (context, index) => Container(
                height: 1,
                color: AppColors.borderNeutral,
              ),
              itemBuilder: (context, index) {
                final note = notes[index];
                return _NoteRow(
                  text: note.title,
                  isPinned: note.pinned,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteRow extends StatelessWidget {
  const _NoteRow({required this.text, this.isPinned = false});
  final String text;
  final bool isPinned;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            isPinned ? Icons.star_rounded : Icons.star_border_rounded,
            size: 16,
            color: isPinned ? AppColors.amber600 : AppColors.neutral300,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Preconfigured Templates
// ─────────────────────────────────────────────────────────────────────────────

class _PreconfiguredTemplates extends StatelessWidget {
  const _PreconfiguredTemplates({required this.templates});

  final List<DashboardTemplate> templates;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Preconfigured Templates',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Row(
                children: [
                  const Text(
                    'All',
                    style: TextStyle(
                      color: AppColors.neutral400,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 16,
                    color: AppColors.neutral400,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderNeutral),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: templates.take(3).length,
              separatorBuilder: (context, index) => Container(
                height: 1,
                color: AppColors.borderNeutral,
              ),
              itemBuilder: (context, index) {
                final template = templates[index];
                return _TemplateRow(
                  title: template.name,
                  subtitle: template.category,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TemplateRow extends StatelessWidget {
  const _TemplateRow({required this.title, required this.subtitle});
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.neutral500,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.neutral500.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.description_outlined,
              size: 16,
              color: AppColors.neutral400,
            ),
          ),
        ],
      ),
    );
  }
}
