import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/task.dart';
import '../models/category.dart';
import '../providers/task_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/task_card.dart';
import '../widgets/category_chip.dart';
import '../widgets/capybara_mood.dart';
import 'add_edit_task_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  final TaskProvider taskProvider;
  final SettingsProvider settingsProvider;
  final ThemeProvider themeProvider;

  const HomeScreen({
    super.key,
    required this.taskProvider,
    required this.settingsProvider,
    required this.themeProvider,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _selectedCategory = 'All';
  bool _showCompleted = false;
  bool _hasShownSwipeTip = false;
  bool _hasShownClearTip = false;

  @override
  void initState() {
    super.initState();
    _loadSwipeTipFlag();
  }

  Future<void> _loadSwipeTipFlag() async {
    final prefs = await SharedPreferences.getInstance();
    _hasShownSwipeTip = prefs.getBool('hasShownSwipeTip') ?? false;
    _hasShownClearTip = prefs.getBool('hasShownClearTip') ?? false;
  }

  TaskProvider get _tasks => widget.taskProvider;

  CapybaraMoodState _mapMood(CapybaraMood mood) {
    switch (mood) {
      case CapybaraMood.noTasks:
        return CapybaraMoodState.noTasks;
      case CapybaraMood.hasTasks:
        return CapybaraMoodState.hasTasks;
      case CapybaraMood.almostDone:
        return CapybaraMoodState.almostDone;
      case CapybaraMood.allDone:
        return CapybaraMoodState.allDone;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListenableBuilder(
      listenable: _tasks,
      builder: (context, _) {
        final filteredPending = _tasks.tasksByCategory(_selectedCategory);
        final completedTasks = _tasks.completedTasks;
        final moodState = _mapMood(_tasks.mood);

        return Scaffold(
          body: SafeArea(
            child: CustomScrollView(
              slivers: [
                // ─── App Bar ─────────────────────────
                SliverAppBar(
                  floating: true,
                  snap: true,
                  elevation: 0,
                  backgroundColor: isDark
                      ? AppColors.darkBackground
                      : AppColors.background,
                  expandedHeight: 60,
                  flexibleSpace: FlexibleSpaceBar(
                    titlePadding: const EdgeInsets.only(left: 24, bottom: 14),
                    title: Text(
                      'TaskyBara',
                      style: GoogleFonts.nunito(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  actions: [
                    // Dark mode toggle
                    IconButton(
                      icon: Icon(
                        isDark
                            ? Icons.light_mode_rounded
                            : Icons.dark_mode_rounded,
                        color: colorScheme.primary,
                        size: 22,
                      ),
                      onPressed: widget.themeProvider.toggle,
                    ),
                    // Settings
                    IconButton(
                      icon: Icon(
                        Icons.settings_outlined,
                        color: colorScheme.primary,
                        size: 22,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SettingsScreen(
                              settingsProvider: widget.settingsProvider,
                              themeProvider: widget.themeProvider,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                ),

                // ─── Content ─────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Capybara mood card
                        CapybaraMoodWidget(
                          mood: moodState,
                          pendingCount: _tasks.totalPending,
                          completedCount: _tasks.totalCompleted,
                        ),

                        const SizedBox(height: 24),

                        // Category filters
                        SizedBox(
                          height: 42,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: TaskCategory.defaults.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (context, index) {
                              final cat = TaskCategory.defaults[index];
                              return CategoryChip(
                                category: cat,
                                isSelected: _selectedCategory == cat.name,
                                onTap: () {
                                  setState(() => _selectedCategory = cat.name);
                                },
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Section header — Pending
                        if (filteredPending.isNotEmpty)
                          _sectionHeader(
                            context,
                            'TASKS',
                            trailing: '${filteredPending.length}',
                          ),
                        if (filteredPending.isNotEmpty)
                          const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),

                // ─── Pending Tasks ────────────────────
                if (filteredPending.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final task = filteredPending[index];
                        return TaskCard(
                          task: task,
                          onToggle: () {
                            _tasks.toggleComplete(task.id);
                            if (!task.isCompleted) _showClearTipIfNeeded();
                          },
                          onDelete: () => _deleteTask(task),
                          onTap: () => _editTask(task),
                        );
                      }, childCount: filteredPending.length),
                    ),
                  ),

                // ─── Empty state ──────────────────────
                if (filteredPending.isEmpty && completedTasks.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 40,
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Text(
                              'No tasks yet!',
                              style: GoogleFonts.nunito(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Tap + to add your first task',
                              style: GoogleFonts.nunito(
                                fontSize: 14,
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // ─── Completed Section ────────────────
                if (completedTasks.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => setState(
                              () => _showCompleted = !_showCompleted,
                            ),
                            child: Row(
                              children: [
                                _sectionHeader(
                                  context,
                                  'COMPLETED',
                                  trailing: '${completedTasks.length}',
                                ),
                                const Spacer(),
                                AnimatedRotation(
                                  turns: _showCompleted ? 0.5 : 0,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  child: Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: colorScheme.primary,
                                  ),
                                ),
                                if (_showCompleted) ...[
                                  const SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: _clearCompleted,
                                    child: Text(
                                      'Clear',
                                      style: GoogleFonts.nunito(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.danger,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  ),

                if (completedTasks.isNotEmpty && _showCompleted)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final task = completedTasks[index];
                        return TaskCard(
                          task: task,
                          onToggle: () => _tasks.toggleComplete(task.id),
                          onDelete: () => _deleteTask(task),
                          onTap: () => _editTask(task),
                        );
                      }, childCount: completedTasks.length),
                    ),
                  ),

                // Bottom padding
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _addTask,
            icon: const Icon(Icons.add_rounded),
            label: Text(
              'Add Task',
              style: GoogleFonts.nunito(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _sectionHeader(BuildContext context, String text, {String? trailing}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: GoogleFonts.nunito(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Text(
              trailing,
              style: GoogleFonts.nunito(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _addTask() async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const AddEditTaskScreen()));

    if (result != null && result is Map<String, dynamic>) {
      await _tasks.addTask(
        title: result['title'] as String,
        description: result['description'] as String?,
        priority: result['priority'] as Priority,
        category: result['category'] as String,
        dueDate: result['dueDate'] as DateTime?,
      );
      _showSwipeTipIfNeeded();
    }
  }

  Future<void> _editTask(Task task) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => AddEditTaskScreen(existingTask: task)),
    );

    if (result != null && result is Task) {
      await _tasks.updateTask(result);
    }
  }

  void _deleteTask(Task task) {
    _tasks.deleteTask(task.id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Task deleted',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: SnackBarAction(
          label: 'Undo',
          textColor: AppColors.success,
          onPressed: () {
            _tasks.addTask(
              title: task.title,
              description: task.description,
              priority: task.priority,
              category: task.category,
              dueDate: task.dueDate,
            );
          },
        ),
      ),
    );
  }

  void _clearCompleted() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Clear completed tasks?',
          style: GoogleFonts.nunito(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'This will permanently remove all completed tasks.',
          style: GoogleFonts.nunito(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _tasks.clearCompleted();
              setState(() => _showCompleted = false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  Future<void> _showSwipeTipIfNeeded() async {
    if (_hasShownSwipeTip) return;
    _hasShownSwipeTip = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasShownSwipeTip', true);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const _AnimatedSwipeIcon(),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Tip: Swipe a task left to delete it!',
                style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Future<void> _showClearTipIfNeeded() async {
    if (_hasShownClearTip) return;
    _hasShownClearTip = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasShownClearTip', true);

    if (!mounted) return;
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(
              Icons.cleaning_services_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Tip: You can clear completed tasks from the Completed section!',
                style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _AnimatedSwipeIcon extends StatefulWidget {
  const _AnimatedSwipeIcon();

  @override
  State<_AnimatedSwipeIcon> createState() => _AnimatedSwipeIconState();
}

class _AnimatedSwipeIconState extends State<_AnimatedSwipeIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.5, 0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _animation,
      child: const Icon(
        Icons.swipe_left_rounded,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}
