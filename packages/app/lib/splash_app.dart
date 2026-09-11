import 'package:flutter/material.dart';

class SplashApp extends StatelessWidget {
  const SplashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(body: Center(child: FlutterLogo())),
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      title: 'Task App',
    );
  }
}
