import 'dart:async';
import 'package:flutter/material.dart';
import '../screens/connect_screen.dart';
import '../sync/sync_engine.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});
  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final SyncEngine sync = SyncEngine();
  bool minimumDone = false, syncDone = false, navigated = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer(const Duration(milliseconds: 1500), () {
      minimumDone = true;
      _navigate();
    });
    unawaited(_run());
  }

  Future<void> _run() async {
    await sync.run();
    syncDone = true;
    _navigate();
  }

  void _navigate() {
    if (!mounted || navigated || !minimumDone || !syncDone) return;
    navigated = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 180),
        pageBuilder: (_, animation, __) => const ConnectScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    sync.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    body: SizedBox.expand(
      child: Image.asset('assets/splash/kalo_splash.png',
        fit: BoxFit.contain, filterQuality: FilterQuality.high),
    ),
  );
}
