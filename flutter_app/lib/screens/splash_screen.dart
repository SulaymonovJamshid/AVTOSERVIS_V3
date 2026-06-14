import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _ctrl =
    AnimationController(duration: const Duration(milliseconds: 1000), vsync: this)..forward();
  late final Animation<double> _scale =
    CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
  late final Animation<double> _fade =
    CurvedAnimation(parent: _ctrl, curve: const Interval(0.5, 1.0));

  @override
  void initState() { super.initState(); _init(); }

  Future<void> _init() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    await context.read<AuthProvider>().loadUser();
    if (!mounted) return;
    final auth = context.read<AuthProvider>();
    if (auth.isLoggedIn) {
      _go(auth.role);
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _go(String role) {
    switch (role) {
      case 'owner': Navigator.pushReplacementNamed(context, '/owner'); break;
      case 'admin': Navigator.pushReplacementNamed(context, '/admin'); break;
      default:      Navigator.pushReplacementNamed(context, '/user');
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.bgDark,
    body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      ScaleTransition(scale: _scale, child: Container(
        width: 100, height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
            begin: Alignment.topLeft, end: Alignment.bottomRight),
          boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 32, spreadRadius: 6)],
        ),
        child: const Icon(Icons.car_repair_rounded, color: Colors.white, size: 52),
      )),
      const SizedBox(height: 24),
      FadeTransition(opacity: _fade, child: Column(children: [
        RichText(text: const TextSpan(children: [
          TextSpan(text: 'Avto', style: TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -1)),
          TextSpan(text: 'Servis', style: TextStyle(color: AppColors.primary, fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -1)),
        ])),
        const SizedBox(height: 6),
        const Text("O'zbekiston avtoservis platformasi",
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        const SizedBox(height: 40),
        const SizedBox(width: 22, height: 22,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
      ])),
    ])),
  );
}
