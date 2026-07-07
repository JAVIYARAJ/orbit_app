import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:orbit_app/app/di/injection.dart';
import 'package:orbit_app/app/theme/app_colors.dart';
import 'package:orbit_app/features/notes/domain/entities/note_entity.dart';
import 'package:orbit_app/features/notes/presentation/cubit/folder_notes_cubit.dart';
import 'package:orbit_app/features/notes/presentation/cubit/folder_notes_state.dart';
import 'package:orbit_app/features/workspaces/presentation/cubit/workspace_cubit.dart';
import 'package:orbit_app/features/workspaces/presentation/cubit/workspace_state.dart';
import 'package:timeago/timeago.dart' as timeago;

class FolderNotesPage extends StatelessWidget {
  const FolderNotesPage({
    super.key,
    required this.folderId,
    required this.folderName,
  });

  final String folderId;
  final String folderName;

  @override
  Widget build(BuildContext context) {
    final workstationId = context.read<WorkspaceCubit>().state.selectedWorkstation?.id;
    return BlocProvider(
      create: (context) {
        final cubit = sl<FolderNotesCubit>();
        if (workstationId != null) {
          cubit.fetchFolderNotes(workstationId, folderId);
        }
        return cubit;
      },
      child: BlocListener<WorkspaceCubit, WorkspaceState>(
        listenWhen: (previous, current) =>
            previous.selectedWorkstation?.id != current.selectedWorkstation?.id,
        listener: (context, state) {
          final newWsId = state.selectedWorkstation?.id;
          if (newWsId != null) {
            context.read<FolderNotesCubit>().fetchFolderNotes(newWsId, folderId);
          }
        },
        child: _FolderNotesView(folderName: folderName, folderId: folderId),
      ),
    );
  }
}

class _FolderNotesView extends StatefulWidget {
  const _FolderNotesView({required this.folderName, required this.folderId});

  final String folderName;
  final String folderId;

  @override
  State<_FolderNotesView> createState() => _FolderNotesViewState();
}

class _FolderNotesViewState extends State<_FolderNotesView> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(folderName: widget.folderName),
            _SearchBar(
              controller: _searchController,
              onChanged: (val) => context.read<FolderNotesCubit>().searchNotes(val),
            ),
            _FilterChips(
              selectedFilter: _selectedFilter,
              onFilterChanged: (filter) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: BlocBuilder<FolderNotesCubit, FolderNotesState>(
                builder: (context, state) {
                  if (state.status == FolderNotesStatus.initial ||
                      (state.status == FolderNotesStatus.loading && state.notes.isEmpty)) {
                    return const Center(child: CircularProgressIndicator(color: AppColors.brand));
                  }

                  if (state.status == FolderNotesStatus.failure) {
                    return Center(
                      child: Text(
                        state.errorMessage ?? 'Failed to load notes',
                        style: const TextStyle(color: AppColors.rose500),
                      ),
                    );
                  }

                  final allNotes = state.notes;
                  final isSearching = state.searchQuery.isNotEmpty;
                  final queryLower = state.searchQuery.toLowerCase();

                  // Apply search filter
                  var notes = isSearching
                      ? allNotes.where((n) => n.title.toLowerCase().contains(queryLower) || n.body.toLowerCase().contains(queryLower)).toList()
                      : allNotes;

                  // Apply filter chips
                  if (_selectedFilter == 'Pinned') {
                    notes = notes.where((n) => n.pinned).toList();
                  }

                  if (allNotes.isEmpty && !isSearching) {
                    return const Center(
                      child: Text(
                        'No notes found in this folder',
                        style: TextStyle(color: AppColors.neutral500),
                      ),
                    );
                  }

                  if (notes.isEmpty) {
                    return const Center(
                      child: Text(
                        'No notes match your criteria',
                        style: TextStyle(color: AppColors.neutral500),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      final wsId = context.read<WorkspaceCubit>().state.selectedWorkstation?.id;
                      if (wsId != null) {
                        await context.read<FolderNotesCubit>().fetchFolderNotes(wsId, widget.folderId);
                      }
                    },
                    color: AppColors.brand,
                    backgroundColor: AppColors.surfaceAlt,
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                      itemCount: notes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final note = notes[index];
                        return _NoteCard(
                          note: note,
                          onTap: () {
                            // Detail navigation
                            context.push('/notes/detail', extra: note);
                          },
                        );
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
  const _Header({required this.folderName});

  final String folderName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 24, 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderCard),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  folderName,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                const Text(
                  'Notes',
                  style: TextStyle(
                    color: AppColors.neutral500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
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
                  hintText: 'Search notes...',
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

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final String selectedFilter;
  final ValueChanged<String> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final filters = ['All', 'Pinned'];
    return SizedBox(
      height: 34,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final filter = filters[i];
          final active = filter == selectedFilter;
          return GestureDetector(
            onTap: () => onFilterChanged(filter),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: active ? AppColors.brand : AppColors.transparent,
                borderRadius: BorderRadius.circular(999),
                border: active ? null : Border.all(color: AppColors.borderCard),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  color: active ? AppColors.white : AppColors.neutral400,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note, required this.onTap});

  final NoteEntity note;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Map database color string to AppColors
    final Color tagColor;
    final String tagLabel;
    
    switch (note.color.toLowerCase()) {
      case 'blue':
        tagColor = AppColors.brandSoft;
        tagLabel = 'API';
        break;
      case 'orange':
      case 'amber':
      case 'yellow':
        tagColor = AppColors.amber;
        tagLabel = 'Ops';
        break;
      case 'rose':
      case 'red':
        tagColor = AppColors.rose500;
        tagLabel = 'Infra';
        break;
      case 'purple':
        tagColor = AppColors.purple;
        tagLabel = 'Docs';
        break;
      case 'green':
        tagColor = AppColors.emerald;
        tagLabel = 'UX';
        break;
      default:
        tagColor = AppColors.brandSoft;
        tagLabel = 'General';
    }

    String formattedDate = '';
    if (note.updatedAt != null) {
      final parsed = DateTime.tryParse(note.updatedAt!);
      if (parsed != null) {
        formattedDate = timeago.format(parsed);
      }
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderCard),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    note.title.isNotEmpty ? note.title : 'Untitled Note',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.4,
                    ),
                  ),
                ),
                if (note.pinned) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.push_pin, color: AppColors.brand, size: 16),
                ],
              ],
            ),
            if (note.body.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                note.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.neutral400,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: tagColor.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    tagLabel,
                    style: TextStyle(color: tagColor, fontSize: 12),
                  ),
                ),
                if (formattedDate.isNotEmpty)
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      color: AppColors.neutral400,
                      fontSize: 11,
                      fontFamily: 'monospace',
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
