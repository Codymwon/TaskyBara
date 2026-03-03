import 'package:flutter/material.dart';

class TaskCategory {
  final String name;
  final IconData icon;

  const TaskCategory({required this.name, required this.icon});

  static const List<TaskCategory> defaults = [
    TaskCategory(name: 'All', icon: Icons.all_inclusive_rounded),
    TaskCategory(name: 'General', icon: Icons.checklist_rounded),
    TaskCategory(name: 'Work', icon: Icons.work_outline_rounded),
    TaskCategory(name: 'Personal', icon: Icons.person_outline_rounded),
    TaskCategory(name: 'Shopping', icon: Icons.shopping_bag_outlined),
    TaskCategory(name: 'Health', icon: Icons.favorite_outline_rounded),
  ];

  static TaskCategory fromName(String name) {
    return defaults.firstWhere(
      (c) => c.name == name,
      orElse: () =>
          TaskCategory(name: name, icon: Icons.folder_special_rounded),
    );
  }
}
