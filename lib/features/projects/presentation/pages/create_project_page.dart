import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:orbit_app/app/theme/app_colors.dart';
import 'package:orbit_app/app/di/injection.dart';
import 'package:orbit_app/features/projects/presentation/cubit/create_project_bloc.dart';
import 'package:orbit_app/features/projects/presentation/cubit/create_project_event.dart';
import 'package:orbit_app/features/projects/presentation/cubit/create_project_state.dart';
import 'package:orbit_app/features/workspaces/presentation/cubit/workspace_cubit.dart';

import 'package:orbit_app/features/projects/domain/entities/project_entity.dart';

class CreateProjectPage extends StatelessWidget {
  const CreateProjectPage({super.key, this.project});

  final ProjectEntity? project;

  @override
  Widget build(BuildContext context) {
    final wsId = context.read<WorkspaceCubit>().state.selectedWorkstation?.id;
    return BlocProvider(
      create: (context) {
        final bloc = sl<CreateProjectBloc>();
        if (project != null) {
          bloc.add(InitEditProjectEvent(project!));
        }
        if (wsId != null) {
          bloc.add(FetchMetadataEvent(wsId));
        }
        return bloc;
      },
      child: _CreateProjectView(project: project),
    );
  }
}

class _CreateProjectView extends StatefulWidget {
  const _CreateProjectView({this.project});
  final ProjectEntity? project;

  @override
  State<_CreateProjectView> createState() => _CreateProjectViewState();
}

class _CreateProjectViewState extends State<_CreateProjectView> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  late final TextEditingController _clientController;
  late final TextEditingController _stackController;
  late final TextEditingController _budgetController;
  late final TextEditingController _hoursController;
  late final TextEditingController _newRepoNameController;

  @override
  void initState() {
    super.initState();
    final project = widget.project;
    _nameController = TextEditingController(text: project?.name ?? '');
    _descController = TextEditingController(text: project?.description ?? '');
    _clientController = TextEditingController(text: project?.client ?? '');
    _stackController = TextEditingController(text: project?.stack.join(', ') ?? '');
    _budgetController = TextEditingController(text: project?.budget ?? '');
    _hoursController = TextEditingController(text: project?.hoursEst?.toString() ?? '');
    _newRepoNameController = TextEditingController();

    _nameController.addListener(() {
      context.read<CreateProjectBloc>().add(UpdateFieldEvent(name: _nameController.text));
    });
    _descController.addListener(() {
      context.read<CreateProjectBloc>().add(UpdateFieldEvent(description: _descController.text));
    });
    _clientController.addListener(() {
      context.read<CreateProjectBloc>().add(UpdateFieldEvent(client: _clientController.text));
    });
    _stackController.addListener(() {
      context.read<CreateProjectBloc>().add(UpdateFieldEvent(stack: _stackController.text));
    });
    _budgetController.addListener(() {
      context.read<CreateProjectBloc>().add(UpdateFieldEvent(budget: _budgetController.text));
    });
    _hoursController.addListener(() {
      context.read<CreateProjectBloc>().add(UpdateFieldEvent(hours: _hoursController.text));
    });
    _newRepoNameController.addListener(() {
      context.read<CreateProjectBloc>().add(UpdateFieldEvent(newRepoName: _newRepoNameController.text));
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _clientController.dispose();
    _stackController.dispose();
    _budgetController.dispose();
    _hoursController.dispose();
    _newRepoNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CreateProjectBloc, CreateProjectState>(
      listenWhen: (previous, current) => previous.isSuccess != current.isSuccess || previous.error != current.error,
      listener: (context, state) {
        if (state.isSuccess) {
          _showCustomSnackBar(
            context: context,
            message: state.isEdit ? 'Project updated successfully' : 'Project created successfully',
            isError: false,
          );
          context.pop(true);
        } else if (state.error != null && state.error!.isNotEmpty) {
          _showCustomSnackBar(
            context: context,
            message: state.error!,
            isError: true,
          );
          context.read<CreateProjectBloc>().add(ClearErrorEvent());
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          titleSpacing: 24,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.project == null ? 'New Project' : 'Edit Project', style: const TextStyle(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(widget.project == null ? 'WORKSPACE / PROJECTS / ADD' : 'WORKSPACE / PROJECTS / EDIT', style: const TextStyle(color: AppColors.neutral500, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 1.2)),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.neutral400),
              onPressed: () => context.pop(),
            )
          ],
        ),
        body: BlocBuilder<CreateProjectBloc, CreateProjectState>(
          builder: (context, state) {
            return Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      _buildTextField('PROJECT NAME *', _nameController, 'e.g. Kombi - Loyalty App'),
                      const SizedBox(height: 16),
                      _buildTextField('DESCRIPTION', _descController, 'Brief overview...', maxLines: 3),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildTextField('CLIENT / OWNER', _clientController, 'e.g. Roastery Co.')),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildSelectionField(
                              'TYPE',
                              state.typeId == null ? '' : _formatType(state.typeId!, state.types),
                              'Select type',
                              () => _showTypeSelectionSheet(context, state),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSelectionField(
                        'STATUS',
                        _formatStatus(state.status),
                        'Select status',
                        () => _showStatusSelectionSheet(context, state),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField('TECH STACK', _stackController, 'Flutter, Supabase (comma-separated)', hint: 'Separate technologies with commas'),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildDatePicker('START DATE', state.startDate, (d) => context.read<CreateProjectBloc>().add(UpdateFieldEvent(startDate: d)))),
                          const SizedBox(width: 16),
                          Expanded(child: _buildDatePicker('END DATE', state.endDate, (d) => context.read<CreateProjectBloc>().add(UpdateFieldEvent(endDate: d)))),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _buildTextField('BUDGET', _budgetController, 'e.g. €12,400')),
                          const SizedBox(width: 16),
                          Expanded(child: _buildTextField('EST. HOURS', _hoursController, '0', keyboardType: TextInputType.number)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text('REPOSITORY', style: TextStyle(color: AppColors.neutral500, fontSize: 10, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderCard),
                        ),
                        child: Column(
                          children: [
                            InkWell(
                              onTap: () => context.read<CreateProjectBloc>().add(const UpdateFieldEvent(isCreatingNewRepo: false)),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                child: Row(
                                  children: [
                                    Icon(state.isCreatingNewRepo ? Icons.radio_button_unchecked : Icons.radio_button_checked, color: state.isCreatingNewRepo ? AppColors.neutral500 : AppColors.brand, size: 20),
                                    const SizedBox(width: 12),
                                    const Text('Select existing repository', style: TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                            ),
                            if (!state.isCreatingNewRepo)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                child: InkWell(
                                  onTap: () => _showRepoSelectionSheet(context, state),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    height: 48,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: AppColors.surfaceAlt,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: AppColors.borderCard),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            state.repoUrl.isEmpty 
                                                ? (state.isLoading ? 'Loading repos...' : 'Select a repository')
                                                : _formatRepo(state.repoUrl, state.githubRepos),
                                            style: TextStyle(
                                              color: state.repoUrl.isEmpty ? AppColors.neutral500 : AppColors.white,
                                              fontSize: 14
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.neutral400),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            const Divider(color: AppColors.borderCard, height: 1),
                            InkWell(
                              onTap: () => context.read<CreateProjectBloc>().add(const UpdateFieldEvent(isCreatingNewRepo: true)),
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                child: Row(
                                  children: [
                                    Icon(state.isCreatingNewRepo ? Icons.radio_button_checked : Icons.radio_button_unchecked, color: state.isCreatingNewRepo ? AppColors.brand : AppColors.neutral500, size: 20),
                                    const SizedBox(width: 12),
                                    const Text('Create new repository', style: TextStyle(color: AppColors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                            ),
                            if (state.isCreatingNewRepo)
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('REPOSITORY NAME', style: TextStyle(color: AppColors.neutral500, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                                    const SizedBox(height: 8),
                                    TextField(
                                      controller: _newRepoNameController,
                                      style: const TextStyle(color: AppColors.white, fontSize: 14),
                                      decoration: InputDecoration(
                                        hintText: 'e.g. my-project',
                                        hintStyle: const TextStyle(color: AppColors.neutral600),
                                        filled: true,
                                        fillColor: AppColors.surfaceAlt,
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderCard)),
                                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderCard)),
                                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.brand)),
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    InkWell(
                                      onTap: () => context.read<CreateProjectBloc>().add(UpdateFieldEvent(isPrivateRepo: !state.isPrivateRepo)),
                                      borderRadius: BorderRadius.circular(8),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: Checkbox(
                                                value: state.isPrivateRepo,
                                                onChanged: (v) => context.read<CreateProjectBloc>().add(UpdateFieldEvent(isPrivateRepo: v ?? false)),
                                                fillColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? AppColors.brand : Colors.transparent),
                                                side: const BorderSide(color: AppColors.neutral400),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            const Text('Private repository', style: TextStyle(color: AppColors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(top: BorderSide(color: AppColors.borderCard)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: state.isSubmitting ? null : () => context.pop(),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.white,
                            side: const BorderSide(color: AppColors.borderCard),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Cancel', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: state.isSubmitting ? null : () {
                            final wsId = context.read<WorkspaceCubit>().state.selectedWorkstation?.id;
                            if (wsId != null) {
                              context.read<CreateProjectBloc>().add(SubmitProjectEvent(wsId));
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brand,
                            foregroundColor: AppColors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: state.isSubmitting 
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                            : Text(state.isEdit ? 'Update project' : '+ Create project', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hintText, {int maxLines = 1, TextInputType? keyboardType, String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.neutral500, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: const TextStyle(color: AppColors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: const TextStyle(color: AppColors.neutral600),
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderCard)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.borderCard)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.brand)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        if (hint != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(hint, style: const TextStyle(color: AppColors.neutral500, fontSize: 11)),
          ),
      ],
    );
  }

  Widget _buildDatePicker(String label, DateTime? date, ValueChanged<DateTime?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.neutral500, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final d = await showDatePicker(
              context: context,
              initialDate: date ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
              builder: (context, child) => Theme(
                data: ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: AppColors.brand,
                    onPrimary: AppColors.white,
                    surface: AppColors.surfaceAlt,
                    onSurface: AppColors.white,
                  ),
                ),
                child: child!,
              ),
            );
            if (d != null) onChanged(d);
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderCard),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    date != null ? "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}" : 'DD/MM/YYYY',
                    style: TextStyle(color: date != null ? AppColors.white : AppColors.neutral500, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.calendar_today_rounded, size: 18, color: AppColors.neutral400),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionField(String label, String value, String hint, VoidCallback onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.neutral500, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderCard),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value.isEmpty ? hint : value,
                    style: TextStyle(color: value.isEmpty ? AppColors.neutral500 : AppColors.white, fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.neutral400),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'planning': return 'Planning';
      case 'in_progress': return 'In Progress';
      case 'on_hold': return 'On Hold';
      case 'completed': return 'Completed';
      case 'cancelled': return 'Cancelled';
      default: return status;
    }
  }

  String _formatRepo(String url, List<dynamic> repos) {
    for (final repo in repos) {
      if (repo['html_url'] == url) {
        return repo['full_name'] as String;
      }
    }
    return url;
  }

  String _formatType(String id, List<dynamic> types) {
    for (final t in types) {
      if (t['id'] == id) {
        return t['label'] as String;
      }
    }
    return id.toUpperCase();
  }

  void _showTypeSelectionSheet(BuildContext context, CreateProjectState state) {
    final bloc = context.read<CreateProjectBloc>();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) {
        return BlocProvider.value(
          value: bloc,
          child: FractionallySizedBox(
            heightFactor: 0.5,
            child: SafeArea(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Select Type', style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  if (state.isLoading)
                    const Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: AppColors.brand))
                  else if (state.types.isEmpty)
                    const Padding(padding: EdgeInsets.all(32), child: Text('No types found', style: TextStyle(color: AppColors.neutral400)))
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: state.types.length,
                        itemBuilder: (context, index) {
                          final typeData = state.types[index];
                          final id = typeData['id'] as String;
                          final name = typeData['label'] as String;
                          return ListTile(
                            title: Text(name, style: const TextStyle(color: AppColors.white)),
                            trailing: state.typeId == id ? const Icon(Icons.check, color: AppColors.brand) : null,
                            onTap: () {
                              bloc.add(UpdateFieldEvent(typeId: id));
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showStatusSelectionSheet(BuildContext context, CreateProjectState state) {
    final bloc = context.read<CreateProjectBloc>();
    final statuses = [
      {'id': 'planning', 'label': 'Planning'},
      {'id': 'in_progress', 'label': 'In Progress'},
      {'id': 'on_hold', 'label': 'On Hold'},
      {'id': 'completed', 'label': 'Completed'},
      {'id': 'cancelled', 'label': 'Cancelled'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) {
        return BlocProvider.value(
          value: bloc,
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('Select Status', style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                ...statuses.map((s) => ListTile(
                  title: Text(s['label']!, style: const TextStyle(color: AppColors.white)),
                  trailing: state.status == s['id'] ? const Icon(Icons.check, color: AppColors.brand) : null,
                  onTap: () {
                    bloc.add(UpdateFieldEvent(status: s['id']));
                    Navigator.pop(context);
                  },
                )),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRepoSelectionSheet(BuildContext context, CreateProjectState state) {
    final bloc = context.read<CreateProjectBloc>();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) {
        return BlocProvider.value(
          value: bloc,
          child: FractionallySizedBox(
            heightFactor: 0.7,
            child: SafeArea(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('Select Repository', style: TextStyle(color: AppColors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  if (state.isLoading)
                    const Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator(color: AppColors.brand))
                  else if (state.githubRepos.isEmpty)
                    const Padding(padding: EdgeInsets.all(32), child: Text('No repositories found', style: TextStyle(color: AppColors.neutral400)))
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: state.githubRepos.length,
                        itemBuilder: (context, index) {
                          final repo = state.githubRepos[index];
                          final url = repo['html_url'] as String;
                          final name = repo['full_name'] as String;
                          return ListTile(
                            title: Text(name, style: const TextStyle(color: AppColors.white)),
                            trailing: state.repoUrl == url ? const Icon(Icons.check, color: AppColors.brand) : null,
                            onTap: () {
                              bloc.add(UpdateFieldEvent(repoUrl: url));
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

void _showCustomSnackBar({
  required BuildContext context,
  required String message,
  required bool isError,
}) {
  final borderColor = isError ? AppColors.rose.withValues(alpha: 0.3) : AppColors.emerald.withValues(alpha: 0.3);
  final iconBgColor = isError ? AppColors.rose.withValues(alpha: 0.1) : AppColors.emerald.withValues(alpha: 0.1);
  final iconColor = isError ? AppColors.rose : AppColors.emerald;
  final icon = isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded;

  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      elevation: 0,
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF0F1014),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
