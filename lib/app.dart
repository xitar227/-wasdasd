import 'package:flutter/material.dart';

import 'pages/splash_page.dart';

class KaloApp extends StatelessWidget {
  const KaloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kalo',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        useMaterial3: true,
      ),
      home: const SplashPage(),
    );
  }
}
