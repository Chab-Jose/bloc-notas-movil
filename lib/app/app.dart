import 'package:blog_note_android/viewmodels/theme_viewmodel.dart';
import 'package:blog_note_android/views/home/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeViewModel>(
      builder: (context, themeVm, _) {
        return MaterialApp(
          title: 'Bloc de Notas',
          debugShowCheckedModeBanner: false,
          theme: themeVm.themeData,
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: themeVm.currentTheme.seedColor,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          themeMode: themeVm.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          home: const HomeScreen(),
        );
      },
    );
  }
}