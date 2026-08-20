import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../domain/entities/task_entity.dart';

class ViewTaskHeader extends StatelessWidget {
  final TaskEntity task;
  final Animation<double> pulseAnimation;
  final Color primary;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color surfaceContainerHigh;
  final bool isCompleted;
  final ValueChanged<bool> onToggle;

  const ViewTaskHeader({
    super.key,
    required this.task,
    required this.pulseAnimation,
    required this.primary,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.surfaceContainerHigh,
    required this.isCompleted,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    FadeTransition(
                      opacity: pulseAnimation,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isCompleted ? Colors.grey : primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isCompleted
                          ? 'COMPLETED'
                          : (task.category?.toUpperCase() ?? 'IN PROGRESS'),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.6,
                        color: isCompleted ? Colors.grey : primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: isCompleted ? Colors.grey : onSurface,
                    decoration: isCompleted ? TextDecoration.lineThrough : null,
                    height: 1.2,
                  ),
                ),
                if (task.description != null &&
                    task.description!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    task.description!,
                    style: TextStyle(
                      fontSize: 14,
                      color: isCompleted ? Colors.grey : onSurfaceVariant,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
          ParticleBurstButton(
            primaryColor: primary,
            surfaceContainerHighColor: surfaceContainerHigh,
            isCompleted: isCompleted,
            onChanged: onToggle,
          ),
        ],
      ),
    );
  }
}

class ParticleBurstButton extends StatefulWidget {
  final Color primaryColor;
  final Color surfaceContainerHighColor;
  final bool isCompleted;
  final ValueChanged<bool> onChanged;

  const ParticleBurstButton({
    super.key,
    required this.primaryColor,
    required this.surfaceContainerHighColor,
    required this.isCompleted,
    required this.onChanged,
  });

  @override
  State<ParticleBurstButton> createState() => _ParticleBurstButtonState();
}

class _ParticleBurstButtonState extends State<ParticleBurstButton>
    with TickerProviderStateMixin {
  bool isPressed = false;

  final List<_Particle> particles = [];
  late AnimationController _particleController;

  @override
  void initState() {
    super.initState();
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _particleController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _particleController.dispose();
    super.dispose();
  }

  void _triggerBurst() {
    widget.onChanged(!widget.isCompleted);
    if (!widget.isCompleted) {
      // That means we are transitioning to true
      particles.clear();
      final random = math.Random();
      for (int i = 0; i < 8; i++) {
        final angle = random.nextDouble() * math.pi * 2;
        final velocity = 20.0 + random.nextDouble() * 30.0;
        particles.add(_Particle(angle: angle, velocity: velocity));
      }
      _particleController.forward(from: 0.0);
    } else {
      _particleController.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => isPressed = true),
      onTapUp: (_) {
        setState(() => isPressed = false);
        _triggerBurst();
      },
      onTapCancel: () => setState(() => isPressed = false),
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          if (_particleController.isAnimating)
            ...particles.map((p) {
              final progress = _particleController.value;
              final dx = math.cos(p.angle) * p.velocity * progress;
              final dy = math.sin(p.angle) * p.velocity * progress;
              final opacity = (1.0 - progress).clamp(0.0, 1.0);

              return Positioned(
                left: 24 + dx - 4,
                top: 24 + dy - 4,
                child: Opacity(
                  opacity: opacity,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: widget.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              );
            }),
          AnimatedScale(
            scale: isPressed ? 0.95 : 1.0,
            duration: const Duration(milliseconds: 150),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isCompleted
                    ? widget.primaryColor
                    : widget.surfaceContainerHighColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  widget.isCompleted ? Icons.task_alt : Icons.check_circle,
                  color: widget.isCompleted
                      ? Colors.white
                      : widget.primaryColor,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Particle {
  final double angle;
  final double velocity;
  _Particle({required this.angle, required this.velocity});
}
