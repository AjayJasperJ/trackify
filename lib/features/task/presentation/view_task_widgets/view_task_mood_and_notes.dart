import 'package:flutter/material.dart';

class ViewTaskMoodAndNotes extends StatefulWidget {
  final bool enabled;
  final bool saving;
  final Color onSurface;
  final Color surfaceContainerLow;
  final Color primary;
  final Color onSurfaceVariant;
  final void Function(int moodIndex, String note)? onSave;

  const ViewTaskMoodAndNotes({
    super.key,
    this.enabled = true,
    this.saving = false,
    required this.onSurface,
    required this.surfaceContainerLow,
    required this.primary,
    required this.onSurfaceVariant,
    this.onSave,
  });

  @override
  State<ViewTaskMoodAndNotes> createState() => _ViewTaskMoodAndNotesState();
}

class _ViewTaskMoodAndNotesState extends State<ViewTaskMoodAndNotes> {
  int _selectedMoodIndex = 2; // default to neutral
  final List<String> emojis = ['😫', '😕', '😐', '😊', '🤩'];
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _save() {
    widget.onSave?.call(_selectedMoodIndex, _noteController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How do you feel?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: widget.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(emojis.length, (index) {
                final isSelected = _selectedMoodIndex == index;
                return GestureDetector(
                  onTap: widget.enabled
                      ? () => setState(() => _selectedMoodIndex = index)
                      : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? widget.primary.withValues(alpha: 0.1)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(
                              color: widget.primary.withValues(alpha: 0.2),
                              width: 2,
                            )
                          : Border.all(color: Colors.transparent, width: 2),
                    ),
                    child: Center(
                      child: AnimatedScale(
                        scale: isSelected ? 1.2 : 1.0,
                        duration: const Duration(milliseconds: 200),
                        child: ColorFiltered(
                          colorFilter: isSelected
                              ? const ColorFilter.mode(
                                  Colors.transparent,
                                  BlendMode.multiply,
                                )
                              : const ColorFilter.matrix(<double>[
                                  0.2126, 0.7152, 0.0722, 0, 0,
                                  0.2126, 0.7152, 0.0722, 0, 0,
                                  0.2126, 0.7152, 0.0722, 0, 0,
                                  0,      0,      0,      1, 0,
                                ]), // Grayscale matrix
                          child: Text(
                            emojis[index],
                            style: const TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Reflections',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: widget.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: widget.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                TextField(
                  enabled: widget.enabled,
                  controller: _noteController,
                  minLines: 4,
                  maxLines: null,
                  style: TextStyle(fontSize: 14, color: widget.onSurface),
                  decoration: InputDecoration(
                    hintText: 'Jot down some thoughts about this task...',
                    hintStyle: TextStyle(
                      color: widget.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                    border: UnderlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: const BorderSide(
                        color: Colors.transparent,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: widget.primary, width: 2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                Positioned(
                  right: 12,
                  bottom: 12,
                  child: IgnorePointer(
                    child: Icon(
                      Icons.edit_note,
                      size: 20,
                      color: widget.enabled
                          ? widget.primary.withValues(alpha: 0.5)
                          : widget.onSurfaceVariant.withValues(alpha: 0.25),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed:
                  (widget.enabled && !widget.saving) ? _save : null,
              icon: widget.saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.cloud_upload, size: 18),
              label: Text(widget.saving ? 'Saving...' : 'Update to Server'),
              style: FilledButton.styleFrom(
                backgroundColor: widget.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
