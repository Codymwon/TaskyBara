import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

enum CapybaraMoodState { noTasks, hasTasks, almostDone, allDone }

class CapybaraMoodWidget extends StatelessWidget {
  final CapybaraMoodState mood;
  final int pendingCount;
  final int completedCount;

  const CapybaraMoodWidget({
    super.key,
    required this.mood,
    required this.pendingCount,
    required this.completedCount,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      switchInCurve: Curves.easeIn,
      switchOutCurve: Curves.easeOut,
      child: Container(
        key: ValueKey(mood),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2824) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05),
              offset: const Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          children: [
            // Capybara emoticon
            Text(
              _emoticon,
              style: GoogleFonts.nunito(
                fontSize: 48,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            // Mood message
            Text(
              _message,
              textAlign: TextAlign.center,
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            // Stats row
            if (pendingCount > 0 || completedCount > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _StatBadge(
                    icon: Icons.pending_actions_rounded,
                    label: '$pendingCount pending',
                    color: AppColors.info,
                  ),
                  const SizedBox(width: 16),
                  _StatBadge(
                    icon: Icons.check_circle_outline_rounded,
                    label: '$completedCount done',
                    color: AppColors.success,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String get _emoticon {
    switch (mood) {
      case CapybaraMoodState.noTasks:
        return '(•‿•)';
      case CapybaraMoodState.hasTasks:
        return '(•ᴗ•)';
      case CapybaraMoodState.almostDone:
        return '(ᵔ◡ᵔ)';
      case CapybaraMoodState.allDone:
        return '(≧◡≦)';
    }
  }

  String get _message {
    switch (mood) {
      case CapybaraMoodState.noTasks:
        return 'Add a task! I\'ll keep you\ncompany~';
      case CapybaraMoodState.hasTasks:
        return 'Let\'s get things done!';
      case CapybaraMoodState.almostDone:
        return 'Great progress!\nKeep going~';
      case CapybaraMoodState.allDone:
        return 'All done! Time\nto relax~';
    }
  }
}

class _StatBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatBadge({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(50),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
