import 'package:flutter/material.dart';

class GoalDetailActivityHistory extends StatelessWidget {
  final Color surfaceContainerLowest;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color secondaryContainer;
  final Color onSecondaryContainer;
  final Color primary;

  const GoalDetailActivityHistory({
    super.key,
    required this.surfaceContainerLowest,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.primary,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Activity", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: onSurface)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: surfaceContainerLowest, borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuAvV3QD5fbPe_4tQ1CfVi08118K5zMQ3GuT4gipE2E44DF899qu3VYrFuhcqm0WOMN8GSLT1RvV7FNVNVhRo6_I-xh7mZVqAdiJkLJ27qJuAtrrjvJr2CWIiNGhiNZPFOQQpS0wra0sc4kKiAUXTxLxF9pIEK2EEyhW1eGBGtpiEEYaNqnWhC4LuvXyj7LwKjawFGF1A0UU9tFSObY_OVz8JrQLhbSe2pEEVS1gCMamAuwJqkVPm6-y',
                        width: 32, height: 32, fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: TextStyle(fontSize: 14, fontFamily: 'Inter', color: onSurface),
                              children: const [
                                TextSpan(text: 'Sarah Jenkins ', style: TextStyle(fontWeight: FontWeight.w600)),
                                TextSpan(text: 'uploaded new territory maps.'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('2 hours ago', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5, color: onSurfaceVariant)),
                        ],
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(color: secondaryContainer, shape: BoxShape.circle),
                      child: Center(child: Icon(Icons.trending_up, size: 18, color: onSecondaryContainer)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: TextStyle(fontSize: 14, fontFamily: 'Inter', color: onSurface),
                              children: [
                                const TextSpan(text: 'Goal progress increased by '),
                                TextSpan(text: '12%', style: TextStyle(fontWeight: FontWeight.w600, color: primary)),
                                const TextSpan(text: '.'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('Yesterday', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, letterSpacing: 0.5, color: onSurfaceVariant)),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
