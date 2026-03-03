import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../models/category.dart';
import '../theme/app_colors.dart';

class AddEditTaskScreen extends StatefulWidget {
  final Task? existingTask;

  const AddEditTaskScreen({super.key, this.existingTask});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  Priority _priority = Priority.medium;
  String _category = 'General';
  DateTime? _dueDate;

  bool get _isEditing => widget.existingTask != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(
      text: widget.existingTask?.title ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.existingTask?.description ?? '',
    );
    if (widget.existingTask != null) {
      _priority = widget.existingTask!.priority;
      _category = widget.existingTask!.category;
      _dueDate = widget.existingTask!.dueDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _isEditing ? 'Edit Task' : 'New Task',
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Title Field ─────────────────────────
            _sectionHeader(context, 'TITLE'),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                hintText: 'What needs to be done?',
              ),
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: 24),

            // ─── Description Field ───────────────────
            _sectionHeader(context, 'DESCRIPTION'),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              style: GoogleFonts.nunito(
                fontSize: 14,
                color: isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.textPrimary,
              ),
              decoration: const InputDecoration(
                hintText: 'Add details (optional)',
              ),
              textCapitalization: TextCapitalization.sentences,
            ),

            const SizedBox(height: 28),

            // ─── Priority ────────────────────────────
            _sectionHeader(context, 'PRIORITY'),
            const SizedBox(height: 12),
            Row(
              children: Priority.values.map((p) {
                final isSelected = _priority == p;
                final color = _priorityColor(p);
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: p != Priority.high ? 10 : 0,
                    ),
                    child: GestureDetector(
                      onTap: () => setState(() => _priority = p),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? color.withValues(alpha: 0.15)
                              : isDark
                              ? const Color(0xFF2C2824)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: isSelected
                                ? color
                                : colorScheme.primary.withValues(alpha: 0.15),
                            width: isSelected ? 2 : 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.flag_rounded,
                              size: 16,
                              color: isSelected
                                  ? color
                                  : colorScheme.primary.withValues(alpha: 0.5),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _priorityLabel(p),
                              style: GoogleFonts.nunito(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? color
                                    : isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 28),

            // ─── Category ────────────────────────────
            _sectionHeader(context, 'CATEGORY'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C2824) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.2),
                ),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _category,
                  isExpanded: true,
                  dropdownColor: isDark
                      ? const Color(0xFF2C2824)
                      : Colors.white,
                  icon: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: colorScheme.primary,
                  ),
                  style: GoogleFonts.nunito(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkTextPrimary
                        : AppColors.textPrimary,
                  ),
                  items: TaskCategory.defaults
                      .where((c) => c.name != 'All')
                      .map(
                        (c) => DropdownMenuItem(
                          value: c.name,
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  c.icon,
                                  size: 18,
                                  color: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(c.name),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _category = value);
                  },
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ─── Due Date ────────────────────────────
            _sectionHeader(context, 'DUE DATE'),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickDate,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2C2824) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.calendar_today_rounded,
                        size: 18,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _dueDate != null
                            ? DateFormat('EEEE, MMM d, y').format(_dueDate!)
                            : 'No due date',
                        style: GoogleFonts.nunito(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _dueDate != null
                              ? (isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.textPrimary)
                              : (isDark
                                    ? AppColors.darkTextLight
                                    : AppColors.textLight),
                        ),
                      ),
                    ),
                    if (_dueDate != null)
                      GestureDetector(
                        onTap: () => setState(() => _dueDate = null),
                        child: Icon(
                          Icons.close_rounded,
                          size: 20,
                          color: colorScheme.secondary,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // ─── Save Button ─────────────────────────
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: Text(_isEditing ? 'Save Changes' : 'Add Task'),
              ),
            ),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String text) {
    return Text(
      text,
      style: GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.2,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  Color _priorityColor(Priority p) {
    switch (p) {
      case Priority.low:
        return AppColors.priorityLow;
      case Priority.medium:
        return AppColors.priorityMedium;
      case Priority.high:
        return AppColors.priorityHigh;
    }
  }

  String _priorityLabel(Priority p) {
    switch (p) {
      case Priority.low:
        return 'Low';
      case Priority.medium:
        return 'Medium';
      case Priority.high:
        return 'High';
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  void _save() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please enter a task title',
            style: GoogleFonts.nunito(fontWeight: FontWeight.w600),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }

    final description = _descriptionController.text.trim();

    if (_isEditing) {
      final updated = widget.existingTask!.copyWith(
        title: title,
        description: description.isNotEmpty ? description : null,
        clearDescription: description.isEmpty,
        priority: _priority,
        category: _category,
        dueDate: _dueDate,
        clearDueDate: _dueDate == null,
      );
      Navigator.of(context).pop(updated);
    } else {
      Navigator.of(context).pop({
        'title': title,
        'description': description.isNotEmpty ? description : null,
        'priority': _priority,
        'category': _category,
        'dueDate': _dueDate,
      });
    }
  }
}
