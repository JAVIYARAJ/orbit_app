import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:orbit_app/app/theme/app_colors.dart';
import 'package:orbit_app/core/widgets/orbit_icon.dart';
import 'package:orbit_app/features/workspaces/presentation/cubit/workspace_cubit.dart';

class CreateWorkspaceSheet extends StatefulWidget {
  const CreateWorkspaceSheet({super.key, this.onSuccess});
  
  final VoidCallback? onSuccess;

  static Future<void> show(BuildContext context, {VoidCallback? onSuccess}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateWorkspaceSheet(onSuccess: onSuccess),
    );
  }

  @override
  State<CreateWorkspaceSheet> createState() => _CreateWorkspaceSheetState();
}

class _CreateWorkspaceSheetState extends State<CreateWorkspaceSheet> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  final List<Color> _colors = [
    const Color(0xFF1EA1F2), // Blue
    const Color(0xFF8B5CF6), // Purple
    const Color(0xFF10B981), // Green
    const Color(0xFFF59E0B), // Orange
    const Color(0xFFE11D48), // Red
    const Color(0xFFEC4899), // Pink
  ];

  late Color _selectedColor;

  @override
  void initState() {
    super.initState();
    _selectedColor = _colors.first;
    _nameController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  void _createWorkspace() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    
    context.read<WorkspaceCubit>().createWorkstation(name, _colorToHex(_selectedColor));
    Navigator.of(context).pop();
    widget.onSuccess?.call();
  }

  @override
  Widget build(BuildContext context) {
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    
    return Container(
      margin: EdgeInsets.only(bottom: viewInsets),
      decoration: const BoxDecoration(
        color: Color(0xFF0F1014),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Logo
              Row(
                children: [
                  const OrbitIcon(size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Orbit',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              
              // Title
              const Text(
                'New workspace',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Each workspace has its own projects, tasks, and data.',
                style: TextStyle(
                  color: AppColors.neutral400,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              
              // Name Field
              const Text(
                'WORKSPACE NAME',
                style: TextStyle(
                  color: AppColors.neutral500,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                focusNode: _focusNode,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'My Projects, Work, Side hustles...',
                  hintStyle: const TextStyle(
                    color: AppColors.neutral600,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: const Color(0xFF13141A),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.chip),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.chip),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: kOrbitIndigo),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Color Picker
              const Text(
                'COLOR',
                style: TextStyle(
                  color: AppColors.neutral500,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: _colors.map((color) {
                  final isSelected = _selectedColor == color;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedColor = color),
                    child: Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(color: AppColors.white, width: 2.5)
                            : null,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              
              // Preview Box
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF13141A),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.chip),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: _selectedColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _nameController.text.trim().isEmpty
                            ? 'Workspace name'
                            : _nameController.text,
                        style: TextStyle(
                          color: _nameController.text.trim().isEmpty ? AppColors.neutral400 : AppColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              // Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nameController.text.trim().isNotEmpty ? _createWorkspace : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F6292),
                    disabledBackgroundColor: const Color(0xFF0F6292).withValues(alpha: 0.5),
                    foregroundColor: AppColors.white,
                    disabledForegroundColor: AppColors.white.withValues(alpha: 0.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Create workspace',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: AppColors.chip),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      color: AppColors.neutral400,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}
