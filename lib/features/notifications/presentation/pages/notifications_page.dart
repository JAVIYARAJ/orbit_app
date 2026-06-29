import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orbit_app/app/theme/app_colors.dart';
import 'package:orbit_app/features/notifications/presentation/bloc/notifications_bloc.dart';
import 'package:orbit_app/features/notifications/presentation/bloc/notifications_event.dart';
import 'package:orbit_app/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:orbit_app/app/di/injection.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NotificationsBloc>()..add(const FetchNotificationsEvent()),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatefulWidget {
  const _NotificationsView();

  @override
  State<_NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<_NotificationsView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<NotificationsBloc>().add(const LoadMoreNotificationsEvent());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll - 200);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.borderCard, height: 1),
        ),
      ),
      body: BlocBuilder<NotificationsBloc, NotificationsState>(
        builder: (context, state) {
          if (state.status == NotificationsStatus.initial ||
              (state.status == NotificationsStatus.loading && state.notifications.isEmpty)) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.brand),
            );
          }

          if (state.status == NotificationsStatus.failure && state.notifications.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Error loading notifications:\n${state.errorMessage}',
                  style: const TextStyle(color: AppColors.rose),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final notifications = state.notifications;
          if (notifications.isEmpty) {
            return const Center(
              child: Text(
                'No notifications',
                style: TextStyle(color: AppColors.neutral400, fontSize: 16),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<NotificationsBloc>().add(const FetchNotificationsEvent());
            },
            color: AppColors.brand,
            backgroundColor: AppColors.surfaceAlt,
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length + (state.hasReachedMax ? 0 : 1),
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index >= notifications.length) {
                  return const Padding(
                    padding: EdgeInsets.all(24.0),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.brand,
                        ),
                      ),
                    ),
                  );
                }

                final item = notifications[index];
                
                final isStale = item.type == 'task_automation';
                final iconColor = isStale ? const Color(0xFF1E90FF) : AppColors.brand;
                final iconData = isStale ? Icons.bolt_rounded : Icons.notifications_rounded;
                
                return Container(
                  decoration: BoxDecoration(
                    color: item.isRead 
                        ? AppColors.surface 
                        : AppColors.surfaceAlt.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: item.isRead 
                          ? AppColors.borderCard 
                          : AppColors.brand.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    boxShadow: item.isRead ? null : [
                      BoxShadow(
                        color: AppColors.brand.withValues(alpha: 0.05),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () {},
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Icon / Avatar
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: item.actorAvatarUrl == null ? LinearGradient(
                                colors: [
                                  iconColor.withValues(alpha: 0.8),
                                  iconColor,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ) : null,
                              image: item.actorAvatarUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(item.actorAvatarUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                              border: Border.all(
                                color: item.actorAvatarUrl != null 
                                    ? AppColors.borderNeutral 
                                    : Colors.transparent,
                              ),
                            ),
                            child: item.actorAvatarUrl == null
                                ? Icon(iconData, color: AppColors.white, size: 20)
                                : null,
                          ),
                          const SizedBox(width: 16),
                          
                          // Content
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: TextStyle(
                                    color: item.isRead ? AppColors.neutral300 : AppColors.white,
                                    fontSize: 14,
                                    fontWeight: item.isRead ? FontWeight.w500 : FontWeight.w600,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item.preview,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppColors.neutral400,
                                    fontSize: 13,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.access_time_rounded, 
                                      size: 12, 
                                      color: AppColors.neutral500,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      timeago.format(item.createdAt),
                                      style: const TextStyle(
                                        color: AppColors.neutral500,
                                        fontSize: 11,
                                        fontFamily: 'monospace',
                                        letterSpacing: 0.2,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          
                          // Unread indicator
                          if (!item.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(top: 6, left: 12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.brand,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.brand.withValues(alpha: 0.6),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
