import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:orbit_app/app/di/injection.dart';
import 'package:orbit_app/app/theme/app_colors.dart';
import 'package:orbit_app/features/notes/presentation/cubit/note_folders_cubit.dart';
import 'package:orbit_app/features/notes/presentation/cubit/note_folders_state.dart';
import 'package:orbit_app/features/notes/domain/entities/note_folder_entity.dart';
import 'package:orbit_app/features/workspaces/presentation/cubit/workspace_cubit.dart';
import 'package:orbit_app/features/workspaces/presentation/cubit/workspace_state.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final workstationId = context.read<WorkspaceCubit>().state.selectedWorkstation?.id;
    return BlocProvider(
      create: (context) {
        final cubit = sl<NoteFoldersCubit>();
        if (workstationId != null) {
          cubit.fetchNoteFolders(workstationId);
        }
        return cubit;
      },
      child: BlocListener<WorkspaceCubit, WorkspaceState>(
        listenWhen: (previous, current) =>
            previous.selectedWorkstation?.id != current.selectedWorkstation?.id,
        listener: (context, state) {
          final newWsId = state.selectedWorkstation?.id;
          if (newWsId != null) {
            context.read<NoteFoldersCubit>().fetchNoteFolders(newWsId);
          }
        },
        child: const _NotesView(),
      ),
    );
  }
}

class _NotesView extends StatefulWidget {
  const _NotesView();

  @override
  State<_NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<_NotesView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _Header(),
            _SearchBar(
              controller: _searchController,
              onChanged: (val) => context.read<NoteFoldersCubit>().searchFolders(val),
            ),
            Expanded(
              child: BlocBuilder<NoteFoldersCubit, NoteFoldersState>(
                builder: (context, state) {
                  if (state.status == NoteFoldersStatus.initial ||
                      (state.status == NoteFoldersStatus.loading && state.folders.isEmpty)) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.brand));
                  }

                  if (state.status == NoteFoldersStatus.failure) {
                    return Center(
                      child: Text(
                        state.errorMessage ?? 'Failed to load folders',
                        style: const TextStyle(color: AppColors.rose500),
                      ),
                    );
                  }

                  final allFolders = state.folders;
                  final isSearching = state.searchQuery.isNotEmpty;
                  final queryLower = state.searchQuery.toLowerCase();

                  final folders = isSearching
                      ? allFolders.where((f) => f.name.toLowerCase().contains(queryLower)).toList()
                      : allFolders;

                  if (allFolders.isEmpty && !isSearching) {
                    return const Center(
                      child: Text(
                        'No folders found',
                        style: TextStyle(color: AppColors.neutral500),
                      ),
                    );
                  }

                  if (folders.isEmpty && isSearching) {
                    return const Center(
                      child: Text(
                        'No folders match your search',
                        style: TextStyle(color: AppColors.neutral500),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      final wsId = context.read<WorkspaceCubit>().state.selectedWorkstation?.id;
                      if (wsId != null) {
                        await context.read<NoteFoldersCubit>().fetchNoteFolders(wsId);
                      }
                    },
                    color: AppColors.brand,
                    backgroundColor: AppColors.surfaceAlt,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                      itemCount: folders.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final folder = folders[index];
                        return _FolderCard(folder: folder);
                      },
                    ),
                  );
                },
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
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Notes',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Folders',
                style: TextStyle(
                  color: AppColors.neutral500,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.brand,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add_rounded,
              color: AppColors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderCard),
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: AppColors.neutral500, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                style: const TextStyle(color: AppColors.white, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Search folders...',
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
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, child) {
                if (value.text.isEmpty) return const SizedBox.shrink();
                return GestureDetector(
                  onTap: () {
                    controller.clear();
                    onChanged('');
                  },
                  child: const Icon(Icons.close_rounded, color: AppColors.neutral500, size: 18),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _FolderCard extends StatelessWidget {
  const _FolderCard({required this.folder});

  final NoteFolderEntity folder;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/notes/folder/${folder.id}?name=${Uri.encodeComponent(folder.name)}');
      },
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderCard),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.brand.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.folder_open_rounded,
                color: AppColors.brand,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    folder.name,
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${folder.notesCount} note${folder.notesCount == 1 ? '' : 's'}',
                    style: const TextStyle(
                      color: AppColors.neutral500,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.neutral500,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
