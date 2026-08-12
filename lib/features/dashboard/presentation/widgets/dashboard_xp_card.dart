import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../progression/providers/progression_providers.dart';

class DashboardXpCard extends ConsumerWidget {
  const DashboardXpCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progression = ref.watch(currentProgressionProvider).value;
    final level = progression?.currentLevel ?? 0;
    final currentXp = progression?.currentXP ?? 0;
    final requiredXp = progression?.requiredXP ?? 0;
    final nextRank = progression?.nextRankName ?? '-';
    final xpUntilNext = requiredXp - currentXp;
    final progress = requiredXp > 0
        ? (currentXp / requiredXp).clamp(0.0, 1.0)
        : 0.0;

    final primaryContainer = const Color(0xFF0F6CBD);
    final onPrimaryContainer = const Color(0xFFE3ECFF);
    final outlineVariant = const Color(0xFFC1C7D3);

    return Container(
      decoration: BoxDecoration(
        color: primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: outlineVariant.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 2),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -50,
            top: -50,
            child: Transform.rotate(
              angle: 12 * math.pi / 180,
              child: Opacity(
                opacity: 0.1,
                child: CustomPaint(
                  size: const Size(200, 200),
                  painter: _BlobPainter(color: onPrimaryContainer),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CURRENT STANDING',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            color: onPrimaryContainer.withValues(alpha: 0.8),
                          ),
                        ),
                        Text(
                          'Level $level',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: onPrimaryContainer,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        '$currentXp / $requiredXp XP',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.24,
                          color: onPrimaryContainer,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(9999),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: progress),
                    duration: const Duration(milliseconds: 1000),
                    curve: Curves.easeOut,
                    builder: (context, value, _) {
                      return LinearProgressIndicator(
                        value: value,
                        minHeight: 12,
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          onPrimaryContainer,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                RichText(
                  text: TextSpan(
                    text: '$xpUntilNext XP until ',
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'Inter',
                      color: onPrimaryContainer.withValues(alpha: 0.9),
                    ),
                    children: [
                      TextSpan(
                        text: nextRank,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const TextSpan(text: ' rank'),
                    ],
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

class _BlobPainter extends CustomPainter {
  final Color color;
  _BlobPainter({required this.color});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path();
    path.moveTo(144.7, 23.6);
    path.cubicTo(158.3, 30.8, 170.1, 42.2, 178.8, 55.6);
    path.cubicTo(187.5, 68.9, 193.1, 84.5, 191.3, 99.1);
    path.cubicTo(189.6, 113.6, 180.5, 127.2, 170.9, 139.2);
    path.cubicTo(161.4, 151.3, 151.5, 161.8, 139.5, 170.5);
    path.cubicTo(127.5, 179.2, 113.8, 186.1, 100.5, 185.1);
    path.cubicTo(87.2, 184.1, 74.5, 175.2, 62.8, 165.8);
    path.cubicTo(51.1, 156.5, 40.5, 146.7, 31.8, 135.0);
    path.cubicTo(23.1, 123.3, 16.3, 109.7, 15.7, 95.8);
    path.cubicTo(15.1, 81.9, 20.7, 67.7, 30.2, 56.7);
    path.cubicTo(39.7, 45.7, 53.1, 38.0, 66.5, 30.7);
    path.cubicTo(80.0, 23.4, 90.0, 16.5, 102.4, 12.4);
    path.cubicTo(114.7, 8.3, 129.4, 7.1, 144.7, 23.6);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
