import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';
import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  final SettingsProvider settingsProvider;
  final ThemeProvider themeProvider;

  const SettingsScreen({
    super.key,
    required this.settingsProvider,
    required this.themeProvider,
  });

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
            Icons.arrow_back_rounded,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.nunito(
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: ListenableBuilder(
        listenable: settingsProvider,
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            children: [
              // ─── Appearance ────────────────────────
              _sectionHeader(context, 'APPEARANCE'),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(
                      value: 'system',
                      icon: Icon(Icons.smartphone_rounded, size: 20),
                      label: Text('System'),
                    ),
                    ButtonSegment(
                      value: 'light',
                      icon: Icon(Icons.light_mode_rounded, size: 20),
                      label: Text('Light'),
                    ),
                    ButtonSegment(
                      value: 'dark',
                      icon: Icon(Icons.dark_mode_rounded, size: 20),
                      label: Text('Dark'),
                    ),
                  ],
                  selected: {settingsProvider.themeMode},
                  onSelectionChanged: (selected) {
                    settingsProvider.setThemeMode(selected.first);
                    themeProvider.updateTheme();
                  },
                  showSelectedIcon: true,
                  style: ButtonStyle(
                    padding: WidgetStateProperty.all(
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    ),
                    textStyle: WidgetStateProperty.all(
                      GoogleFonts.nunito(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    iconSize: WidgetStateProperty.all(20),
                    shape: WidgetStateProperty.all(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    side: WidgetStateProperty.all(
                      BorderSide(
                        color: colorScheme.primary.withValues(alpha: 0.3),
                        width: 1.5,
                      ),
                    ),
                    backgroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return colorScheme.primary;
                      }
                      return Colors.transparent;
                    }),
                    foregroundColor: WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.selected)) {
                        return isDark ? AppColors.darkBackground : Colors.white;
                      }
                      return isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.textSecondary;
                    }),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // ─── About ────────────────────────────
              _sectionHeader(context, 'ABOUT'),
              const SizedBox(height: 12),
              _settingsCard(
                context,
                isDark: isDark,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Column(
                      children: [
                        Text(
                          '(•‿•)',
                          style: GoogleFonts.nunito(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'TaskyBara',
                          style: GoogleFonts.nunito(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Your cozy capybara task companion',
                          style: GoogleFonts.nunito(
                            fontSize: 14,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'v1.0.0',
                          style: GoogleFonts.nunito(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextLight
                                : AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          );
        },
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

  Widget _settingsCard(
    BuildContext context, {
    required bool isDark,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(children: children),
    );
  }

  Widget _iconContainer(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
