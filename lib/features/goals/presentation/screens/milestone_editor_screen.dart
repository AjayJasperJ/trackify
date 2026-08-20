import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../authentication/providers/auth_provider.dart';
import '../../domain/entities/milestone_entity.dart';
import '../../providers/goal_providers.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_form_styles.dart';
import '../../../../widgets/dashboard_app_bar.dart';
import '../../../../widgets/form_primary_button.dart';
import '../../../../widgets/form_section_card.dart';
import '../controllers/milestone_editor_controller.dart';

class MilestoneEditorScreen extends ConsumerStatefulWidget {
  final String goalId;
  final MilestoneEntity? milestoneToEdit;

  const MilestoneEditorScreen({
    super.key,
    required this.goalId,
    this.milestoneToEdit,
  });

  @override
  ConsumerState<MilestoneEditorScreen> createState() =>
      _MilestoneEditorScreenState();
}

class _MilestoneEditorScreenState extends ConsumerState<MilestoneEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final MilestoneEditorController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MilestoneEditorController(
      repo: ref.read(milestoneRepositoryProvider),
      goalId: widget.goalId,
      milestoneToEdit: widget.milestoneToEdit,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _selectDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate:
          _controller.deadline ?? DateTime.now().add(const Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) _controller.setDeadline(picked);
  }

  Future<void> _saveMilestone() async {
    if (!_formKey.currentState!.validate()) return;

    final user = ref.read(currentUserProvider);
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in')),
      );
      return;
    }

    _controller.setLoading(true);
    try {
      await _controller.save(user.uid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
            _controller.isEditing
                ? 'Milestone updated'
                : 'Milestone created',
          ),
        ));
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) _controller.setLoading(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = _controller.isEditing;
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: ListenableBuilder(
        listenable: _controller,
        builder: (context, _) => _controller.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsets.only(
                      top: topPadding + 56 + 24,
                      bottom: bottomPadding + 64 + 80,
                      left: 16.0,
                      right: 16.0,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FormSectionCard(
                            icon: Icons.star_outline,
                            title: 'MILESTONE DETAILS',
                            children: [
                              TextFormField(
                                controller: _controller.title,
                                style: const TextStyle(
                                  color: AppFormStyles.textColor,
                                ),
                                decoration: AppFormStyles.input(
                                  label: 'Title',
                                ),
                                validator: (val) =>
                                    val == null || val.isEmpty
                                        ? 'Required'
                                        : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _controller.description,
                                style: const TextStyle(
                                  color: AppFormStyles.textColor,
                                ),
                                decoration: AppFormStyles.input(
                                  label: 'Description',
                                ),
                                maxLines: 3,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _controller.targetValue,
                                style: const TextStyle(
                                  color: AppFormStyles.textColor,
                                ),
                                decoration: AppFormStyles.input(
                                  label: 'Target Value',
                                  hint: 'Optional, e.g. 10 tasks',
                                ),
                                keyboardType: TextInputType.number,
                              ),
                              const SizedBox(height: 16),
                              InkWell(
                                onTap: _selectDeadline,
                                borderRadius: BorderRadius.circular(
                                  AppFormStyles.inputRadius,
                                ),
                                child: InputDecorator(
                                  decoration: AppFormStyles.input(
                                    label: 'Deadline',
                                  ),
                                  child: Text(
                                    _controller.deadline == null
                                        ? 'Not set'
                                        : '${_controller.deadline!.year}-${_controller.deadline!.month.toString().padLeft(2, '0')}-${_controller.deadline!.day.toString().padLeft(2, '0')}',
                                    style: const TextStyle(
                                      color: AppFormStyles.textColor,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  DashboardAppBar(
                    title: isEditing
                        ? 'Edit Milestone'
                        : 'Add Milestone',
                    topPadding: topPadding,
                    isInnerScreen: true,
                    showAvatar: false,
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: ClipRect(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          color: AppColors.surface.withValues(alpha: 0.8),
                          padding: EdgeInsets.only(
                            left: 16.0,
                            right: 16.0,
                            top: 16.0,
                            bottom: 16.0 + bottomPadding,
                          ),
                          child: FormPrimaryButton(
                            text: isEditing
                                ? 'Update Milestone'
                                : 'Create Milestone',
                            onPressed: _saveMilestone,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
