import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phone    = TextEditingController();
  final _password = TextEditingController();
  bool _obscure   = true;

  Future<void> _login() async {
    final phone = _phone.text.trim();
    final pass  = _password.text;
    if (phone.isEmpty || pass.isEmpty) {
      _snack('Barcha maydonlarni to\'ldiring', AppColors.error); return;
    }
    final auth = context.read<AuthProvider>();
    final ok   = await auth.login(phone, pass);
    if (!mounted) return;
    if (ok) {
      switch (auth.role) {
        case 'owner': Navigator.pushReplacementNamed(context, '/owner'); break;
        case 'admin': Navigator.pushReplacementNamed(context, '/admin'); break;
        default:      Navigator.pushReplacementNamed(context, '/user');
      }
    } else {
      _snack(auth.errorMessage ?? 'Xatolik', AppColors.error);
    }
  }

  void _snack(String msg, Color color) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), backgroundColor: color, behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));

  @override
  void dispose() { _phone.dispose(); _password.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().isLoading;
    return Scaffold(
      body: SafeArea(child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: 40),
          // Logo
          Center(child: Container(
            width: 84, height: 84,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
              boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.35), blurRadius: 24)],
            ),
            child: const Icon(Icons.car_repair_rounded, color: Colors.white, size: 44),
          )),
          const SizedBox(height: 36),
          const Text('Xush kelibsiz!', style: AppTextStyles.h1),
          const SizedBox(height: 6),
          const Text('Hisobingizga kiring', style: AppTextStyles.bodySecondary),
          const SizedBox(height: 32),

          const Text('Telefon raqam', style: AppTextStyles.label),
          const SizedBox(height: 8),
          TextField(
            controller: _phone,
            keyboardType: TextInputType.phone,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))],
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: const InputDecoration(
              hintText: '+998901234567',
              prefixIcon: Icon(Icons.phone_outlined, color: AppColors.textSecondary, size: 20),
            ),
          ),
          const SizedBox(height: 18),

          const Text('Parol', style: AppTextStyles.label),
          const SizedBox(height: 8),
          TextField(
            controller: _password,
            obscureText: _obscure,
            onSubmitted: (_) => _login(),
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: '••••••••',
              prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary, size: 20),
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  color: AppColors.textSecondary, size: 20),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: 28),

          loading
            ? _loadingBtn()
            : ElevatedButton(onPressed: _login, child: const Text('Kirish')),
          const SizedBox(height: 18),

          Center(child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/register'),
            child: RichText(text: const TextSpan(children: [
              TextSpan(text: 'Hisobingiz yo\'qmi? ',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              TextSpan(text: 'Ro\'yxatdan o\'ting',
                style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w600)),
            ])),
          )),
          const SizedBox(height: 40),
        ]),
      )),
    );
  }

  Widget _loadingBtn() => Container(
    height: 54,
    decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(14)),
    child: const Center(child: SizedBox(width: 22, height: 22,
      child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))),
  );
}
