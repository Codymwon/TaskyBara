import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';
import 'package:uuid/uuid.dart';

class TaskProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  static const _storageKey = 'taskybara_tasks';
  static const _uuid = Uuid();

  List<Task> _tasks = [];
  Timer? _allDoneTimer;
  bool _isAllDoneExpired = false;

  List<Task> get tasks => List.unmodifiable(_tasks);

  List<Task> get pendingTasks =>
      _tasks.where((t) => !t.isCompleted).toList()..sort((a, b) {
        // Sort by priority (high first), then by creation date (newest first)
        final priorityCompare = b.priority.index.compareTo(a.priority.index);
        if (priorityCompare != 0) return priorityCompare;
        return b.createdAt.compareTo(a.createdAt);
      });

  List<Task> get completedTasks =>
      _tasks.where((t) => t.isCompleted).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<Task> tasksByCategory(String category) {
    if (category == 'All') return pendingTasks;
    return pendingTasks.where((t) => t.category == category).toList();
  }

  int get completedTodayCount {
    final now = DateTime.now();
    return _tasks
        .where(
          (t) =>
              t.isCompleted &&
              t.createdAt.year == now.year &&
              t.createdAt.month == now.month &&
              t.createdAt.day == now.day,
        )
        .length;
  }

  int get totalPending => pendingTasks.length;
  int get totalCompleted => completedTasks.length;

  /// Capybara mood based on task completion state
  CapybaraMood get mood {
    if (_tasks.isEmpty) return CapybaraMood.noTasks;
    if (pendingTasks.isEmpty && completedTasks.isNotEmpty) {
      return _isAllDoneExpired ? CapybaraMood.noTasks : CapybaraMood.allDone;
    }
    final total = _tasks.length;
    final completed = completedTasks.length;
    if (total > 0 && completed / total > 0.5) {
      return CapybaraMood.almostDone;
    }
    return CapybaraMood.hasTasks;
  }

  TaskProvider(this._prefs) {
    _loadTasks();
  }

  void _loadTasks() {
    final data = _prefs.getString(_storageKey);
    if (data != null && data.isNotEmpty) {
      _tasks = Task.decode(data);
    }
    _checkAllDoneTimer();
  }

  void _checkAllDoneTimer() {
    if (pendingTasks.isEmpty && completedTasks.isNotEmpty) {
      if (_allDoneTimer == null || !_allDoneTimer!.isActive) {
        _isAllDoneExpired = false;
        // 3 minute hold time for the "All Done" celebration before reverting
        _allDoneTimer = Timer(const Duration(minutes: 3), () {
          _isAllDoneExpired = true;
          notifyListeners();
        });
      }
    } else {
      _allDoneTimer?.cancel();
      _isAllDoneExpired = false;
    }
  }

  void _notifyAndCheck() {
    _checkAllDoneTimer();
    notifyListeners();
  }

  Future<void> _saveTasks() async {
    await _prefs.setString(_storageKey, Task.encode(_tasks));
  }

  Future<void> addTask({
    required String title,
    String? description,
    Priority priority = Priority.medium,
    String category = 'General',
    DateTime? dueDate,
  }) async {
    final task = Task(
      id: _uuid.v4(),
      title: title,
      description: description,
      priority: priority,
      category: category,
      createdAt: DateTime.now(),
      dueDate: dueDate,
    );
    _tasks.add(task);
    await _saveTasks();
    _notifyAndCheck();
  }

  Future<void> updateTask(Task updated) async {
    final index = _tasks.indexWhere((t) => t.id == updated.id);
    if (index != -1) {
      _tasks[index] = updated;
      await _saveTasks();
      _notifyAndCheck();
    }
  }

  Future<void> toggleComplete(String taskId) async {
    final index = _tasks.indexWhere((t) => t.id == taskId);
    if (index != -1) {
      _tasks[index] = _tasks[index].copyWith(
        isCompleted: !_tasks[index].isCompleted,
      );
      await _saveTasks();
      _notifyAndCheck();
    }
  }

  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((t) => t.id == taskId);
    await _saveTasks();
    _notifyAndCheck();
  }

  Future<void> clearCompleted() async {
    _tasks.removeWhere((t) => t.isCompleted);
    await _saveTasks();
    _notifyAndCheck();
  }
}

enum CapybaraMood { noTasks, hasTasks, almostDone, allDone }
