import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trackify/features/authentication/providers/auth_provider.dart';
import 'package:trackify/theme/app_colors.dart';
import '../data/onboarding_seeder.dart';
import '../providers/onboarding_providers.dart';

/// 3-step onboarding for brand-new users (Issue 2):
/// 1. Pick a starter goal (preset with icon + starter tasks)
/// 2. Set your weekly rhythm (weekday chips + reminder time)
/// 3. Done → seeds goal + tasks, lands on dashboard
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _step = 0;
  OnboardingGoalPreset? _selectedPreset;
  final Set<int> _selectedWeekdays = {};
  TimeOfDay _reminderTime = const TimeOfDay(hour: 8, minute: 0);
  bool _seeding = false;

  static const List<String> _weekdayLabels = [
    'M', 'T', 'W', 'T', 'F', 'S', 'S',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final user = ref.read(currentUserProvider);
    if (user == null || _selectedPreset == null) return;

    setState(() => _seeding = true);
    try {
      final seeder = ref.read(onboardingSeederProvider);
      await seeder.seed(
        user.uid,
        _selectedPreset!,
        _selectedWeekdays.toList()..sort(),
        DateTime(
          DateTime.now().year,
          DateTime.now().month,
          DateTime.now().day,
          _reminderTime.hour,
          _reminderTime.minute,
        ),
      );
      if (!mounted) return;
      context.go('/dashboard');
    } catch (_) {
      if (!mounted) return;
      setState(() => _seeding = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not set up your starter goal. Please try again.'),
        ),
      );
    }
  }

  void _goToStep(int step) {
    setState(() => _step = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) => setState(() => _step = index),
                children: [
                  _buildGoalStep(),
                  _buildRhythmStep(),
                  _buildDoneStep(),
                ],
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (_step > 0)
                IconButton(
                  onPressed: _seeding ? null : () => _goToStep(_step - 1),
                  icon: const Icon(Icons.arrow_back),
                  color: AppColors.onSurfaceVariant,
                )
              else
                const SizedBox(width: 48),
              const Spacer(),
              Text(
                'Step ${_step + 1} of 3',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_step + 1) / 3,
              minHeight: 4,
              backgroundColor: AppColors.surfaceContainerHighest,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalStep() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Text(
          'Pick a starter goal',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'We\'ll pre-fill some tasks so your dashboard, streaks and XP start working right away. You can change everything later.',
          style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 20),
        ...onboardingGoalPresets.map((preset) {
          final selected = _selectedPreset == preset;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => setState(() => _selectedPreset = preset),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.primary.withValues(alpha: 0.06)
                      : AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: selected ? AppColors.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        preset.icon,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            preset.title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onSurface,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${preset.tasks.length} starter tasks',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      selected
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      color: selected ? AppColors.primary : AppColors.outlineVariant,
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRhythmStep() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        Text(
          'Set your weekly rhythm',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Which days do you want your starter tasks to repeat on?',
          style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (index) {
            final selected = _selectedWeekdays.contains(index + 1);
            return InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () {
                setState(() {
                  if (selected) {
                    _selectedWeekdays.remove(index + 1);
                  } else {
                    _selectedWeekdays.add(index + 1);
                  }
                });
              },
              child: Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : AppColors.surfaceContainerLow,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.outlineVariant,
                  ),
                ),
                child: Text(
                  _weekdayLabels[index],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: selected ? Colors.white : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 8),
        Text(
          _selectedWeekdays.isEmpty
              ? 'None selected — tasks will repeat daily.'
              : 'Selected: ${_selectedWeekdays.map((d) => _weekdayLabels[d - 1]).join(', ')}',
          style: const TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 28),
        Text(
          'Reminder time',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: _seeding
              ? null
              : () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _reminderTime,
                  );
                  if (picked != null) {
                    setState(() => _reminderTime = picked);
                  }
                },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.notifications_outlined,
                    color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  _reminderTime.format(context),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right,
                    color: AppColors.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDoneStep() {
    final preset = _selectedPreset;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      children: [
        const SizedBox(height: 24),
        Center(
          child: Container(
            width: 88,
            height: 88,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Text('🎉', style: TextStyle(fontSize: 40)),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'You\'re all set!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          preset == null
              ? 'Your dashboard is ready.'
              : 'We created "${preset.title}" with ${preset.tasks.length} starter tasks. Complete them to build your streak and earn XP!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
        ),
        const SizedBox(height: 20),
        if (preset != null) ...[
          Center(
            child: Wrap(
              spacing: 6,
              children: preset.tasks
                  .map(
                    (t) => Chip(
                      label: Text(
                        t.title,
                        style: const TextStyle(fontSize: 12),
                      ),
                      backgroundColor: AppColors.surfaceContainerLow,
                      side: BorderSide.none,
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Center(
          child: Text(
            'You can edit or delete everything from the Goals and Tasks tabs later.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    final canProceed = _step == 0
        ? _selectedPreset != null
        : _step == 1
            ? true
            : true;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        children: [
          if (_step == 2)
            Expanded(
              child: OutlinedButton(
                onPressed: _seeding ? null : () => _goToStep(1),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  side: const BorderSide(color: AppColors.outlineVariant),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text('Back'),
              ),
            )
          else
            const SizedBox.shrink(),
          if (_step == 2) const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: _seeding || !canProceed ? null : () {
                if (_step < 2) {
                  _goToStep(_step + 1);
                } else {
                  _finish();
                }
              },
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _seeding
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _step == 0
                          ? 'Continue'
                          : _step == 1
                              ? 'Continue'
                              : 'Start using Trackify',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
