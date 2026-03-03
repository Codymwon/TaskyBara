import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'providers/task_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';

late final TaskProvider taskProvider;
late final SettingsProvider settingsProvider;
late final ThemeProvider themeProvider;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  taskProvider = TaskProvider(prefs);
  settingsProvider = SettingsProvider(prefs);
  themeProvider = ThemeProvider(settingsProvider);

  _updateSystemUI(false);

  runApp(const TaskyBaraApp());
}

void _updateSystemUI(bool isDark) {
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: isDark
          ? AppColors.darkBackground
          : AppColors.background,
      systemNavigationBarIconBrightness: isDark
          ? Brightness.light
          : Brightness.dark,
    ),
  );
}

class TaskyBaraApp extends StatelessWidget {
  const TaskyBaraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeProvider,
      builder: (context, _) {
        _updateSystemUI(themeProvider.isDarkMode);
        return MaterialApp(
          title: 'TaskyBara',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          themeAnimationDuration: Duration.zero,
          home: HomeScreen(
            taskProvider: taskProvider,
            settingsProvider: settingsProvider,
            themeProvider: themeProvider,
          ),
        );
      },
    );
  }
}
