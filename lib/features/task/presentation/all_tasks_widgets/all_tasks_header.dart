import 'package:flutter/material.dart';
import 'package:trackify/widgets/dashboard_app_bar.dart';

class AllTasksHeader extends StatelessWidget {
  final double topPadding;

  const AllTasksHeader({super.key, required this.topPadding});

  @override
  Widget build(BuildContext context) {
    return DashboardAppBar(
      topPadding: topPadding,
      showAvatar: false,
      title: 'Tasks',
    );
  }
}
