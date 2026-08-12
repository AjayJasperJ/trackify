// AddTaskXpCard — TASK SIZE picker.
// Commented out: task size option removed from the add-task screen
// (2026-08-06, pre-production). Tasks default to TaskSize.medium.
// May be reused later, so kept rather than deleted.
// import 'package:flutter/material.dart';
// import 'package:trackify/features/task/domain/entities/task_size.dart';
// import 'package:trackify/theme/app_form_styles.dart';
// import 'package:trackify/widgets/form_section_card.dart';
//
// class AddTaskXpCard extends StatelessWidget {
//   final TaskSize selectedTaskSize;
//   final VoidCallback onDecrease;
//   final VoidCallback onIncrease;
//
//   const AddTaskXpCard({
//     super.key,
//     required this.selectedTaskSize,
//     required this.onDecrease,
//     required this.onIncrease,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     // Real XP values from ProgressionService (tiny=5 … huge=75).
//     int xp = 20;
//     switch (selectedTaskSize) {
//       case TaskSize.tiny:
//         xp = 5;
//         break;
//       case TaskSize.small:
//         xp = 10;
//         break;
//       case TaskSize.medium:
//         xp = 20;
//         break;
//       case TaskSize.large:
//         xp = 40;
//         break;
//       case TaskSize.huge:
//         xp = 75;
//         break;
//     }
//
//     return FormSectionCard(
//       icon: Icons.stars,
//       title: 'TASK SIZE',
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   selectedTaskSize.name[0].toUpperCase() +
//                       selectedTaskSize.name.substring(1),
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.w600,
//                     color: AppFormStyles.textColor,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 8,
//                     vertical: 4,
//                   ),
//                   decoration: BoxDecoration(
//                     color: AppFormStyles.primary.withValues(alpha: 0.1),
//                     borderRadius: BorderRadius.circular(999),
//                   ),
//                   child: Text(
//                     '+$xp XP',
//                     style: TextStyle(
//                       fontSize: 10,
//                       fontWeight: FontWeight.w600,
//                       color: AppFormStyles.primary,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//             Row(
//               children: [
//                 _StepperButton(
//                   icon: Icons.remove,
//                   onTap: onDecrease,
//                 ),
//                 const SizedBox(width: 8),
//                 _StepperButton(
//                   icon: Icons.add,
//                   onTap: onIncrease,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }
//
// class _StepperButton extends StatelessWidget {
//   final IconData icon;
//   final VoidCallback onTap;
//
//   const _StepperButton({required this.icon, required this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 40,
//         height: 40,
//         decoration: BoxDecoration(
//           color: AppFormStyles.primary.withValues(alpha: 0.1),
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Icon(icon, color: AppFormStyles.primary, size: 20),
//       ),
//     );
//   }
// }
