import 'package:flutter/material.dart';
import '../../domain/entities/badge_entity.dart';
import '../../domain/entities/achievement_enums.dart';

class BadgeCard extends StatelessWidget {
  final BadgeEntity badge;

  const BadgeCard({super.key, required this.badge});

  Color _getRarityColor(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.common:
        return Colors.grey.shade400;
      case AchievementRarity.rare:
        return Colors.blue.shade400;
      case AchievementRarity.epic:
        return Colors.purple.shade400;
      case AchievementRarity.legendary:
        return Colors.orange.shade400;
      case AchievementRarity.mythic:
        return Colors.redAccent.shade400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rarityColor = _getRarityColor(badge.rarity);

    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: rarityColor.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shield, // Would normally use badge.icon string to map to real icon
            color: rarityColor,
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            badge.title,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
