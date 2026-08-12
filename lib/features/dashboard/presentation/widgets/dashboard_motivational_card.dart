import 'package:flutter/material.dart';

class DashboardMotivationalCard extends StatelessWidget {
  const DashboardMotivationalCard({super.key});

  @override
  Widget build(BuildContext context) {
    final surfaceContainer = const Color(0xFFF0EDED);
    final onSurfaceVariant = const Color(0xFF414751);

    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            children: [
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "You're doing great!",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Take a 5-minute breather. Your focus score is up 12% today.",
                      style: TextStyle(
                        fontSize: 14,
                        color: onSurfaceVariant.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const Expanded(flex: 4, child: SizedBox()),
            ],
          ),
          Positioned(
            right: -10,
            top: -10,
            child: Opacity(
              opacity: 0.2,
              child: IgnorePointer(
                child: Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuDXywPsPEFyCO9oygMiVbbUtYx-Pp7zGAKC4BnjlY7dfqCQxDVzLHJwS2i04ix9JslvoxtEpObD4nwZrPdiXTpN_LO9lPCoFIEk-s3UyRsjaBXn7IQESaE5GHFcohkP5Kh3ObudPfyAQCTgtm6UwDWM-GM00YT-Szm5HJveE5ms8odscUVWhjDVvM-bdhe7Yo10QcLKb55xfU3P2uxL4_6-gRWQA3Uee_c9fM8Bxe8IDeqwOlPvxul9',
                  width: 128,
                  height: 128,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
