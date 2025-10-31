import 'package:dailyplus/providers/theme_provider.dart';
import 'package:dailyplus/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'providers/mood_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize MoodProvider before runApp
  final moodProvider = MoodProvider();
  await moodProvider.init();

  // Initialize ThemeProvider before app load (so theme loads instantly)
  final themeProvider = ThemeProvider();
  await themeProvider.init(); 

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<MoodProvider>.value(value: moodProvider),
        ChangeNotifierProvider<ThemeProvider>.value(value: themeProvider),
      ],
      child: const DailyPulseApp(),
    ),
  );
}

class DailyPulseApp extends StatelessWidget {
  const DailyPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return ScreenUtilInit(
      designSize: const Size(350, 850),
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'DailyPulse',
          theme: AppThemes.lightTheme,
          darkTheme: AppThemes.darkTheme,
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const HomeScreen(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
