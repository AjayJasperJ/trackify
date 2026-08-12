import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../theme/app_spacing.dart';

class DicebearAvatarPicker extends StatefulWidget {
  final String initialSeed;
  final Function(String url) onAvatarChanged;

  const DicebearAvatarPicker({
    super.key,
    required this.initialSeed,
    required this.onAvatarChanged,
  });

  @override
  State<DicebearAvatarPicker> createState() => _DicebearAvatarPickerState();
}

class _DicebearAvatarPickerState extends State<DicebearAvatarPicker> {
  final List<String> _styles = [
    'adventurer',
    'avataaars',
    'bottts',
    'fun-emoji',
    'lorelei',
    'micah',
    'miniavs',
  ];
  
  late String _currentStyle;
  late String _currentSeed;

  @override
  void initState() {
    super.initState();
    _currentStyle = _styles[0];
    _currentSeed = widget.initialSeed;
    // Initial call will be handled by the parent using the default, or we can push it:
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onAvatarChanged(_currentUrl);
    });
  }

  String get _currentUrl {
    return 'https://api.dicebear.com/7.x/$_currentStyle/png?seed=$_currentSeed';
  }

  void _randomizeSeed() {
    final random = Random();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final newSeed = String.fromCharCodes(Iterable.generate(
      8, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
    setState(() {
      _currentSeed = newSeed;
    });
    widget.onAvatarChanged(_currentUrl);
  }

  void _changeStyle(String style) {
    setState(() {
      _currentStyle = style;
    });
    widget.onAvatarChanged(_currentUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Choose your Avatar',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: AppSpacing.s12),
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            shape: BoxShape.circle,
            border: Border.all(
              color: Theme.of(context).colorScheme.primary,
              width: 2,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.network(
            _currentUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error, stackTrace) {
              return const Center(child: Icon(Icons.error));
            },
          ),
        ),
        const SizedBox(height: AppSpacing.s12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<String>(
              value: _currentStyle,
              items: _styles.map((String style) {
                return DropdownMenuItem<String>(
                  value: style,
                  child: Text(style),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) _changeStyle(value);
              },
            ),
            const SizedBox(width: AppSpacing.s16),
            ElevatedButton.icon(
              onPressed: _randomizeSeed,
              icon: const Icon(Icons.shuffle, size: 18),
              label: const Text('Randomize'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
