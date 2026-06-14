import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _name     = TextEditingController();
  final _phone    = TextEditingController();
  final _password = TextEditingController();
  final _confirm  = TextEditingController();
  String _role    = 'user';
  bool _obscure   = true;

  Future<void> _register() async {
    final name    = _name.text.trim();
    final phone   = _phone.text.trim();
    final pass    = _password.text;
    final confirm = _confirm.text;

    if ([name, phone, pass, confirm].any((s) => s.isEmpty)) {
      _snack('Barcha maydonlarni to\'ldiring', AppColors.error); return;
    }
    if (pass.length < 6) {
      _snack('Parol kamida 6 ta belgi bo\'lishi kerak', AppColors.error); return;
    }
    if (pass != confirm) {
      _snack('Parollar mos kelmayapti', AppColors.error); return;
    }

    final auth = context.read<AuthProvider>();
    final ok = await auth.register(name: name, phone: phone, password: pass, role: _role);
    if (!mounted) return;
    if (ok) {
      _snack('Muvaffaqiyatli ro\'yxatdan o\'tdingiz! 🎉', AppColors.success);
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      switch (auth.role) {
        case 'owner': Navigator.pushReplacementNamed(context, '/owner'); break;
        default:      Navigator.pushReplacementNamed(context, '/user');
      }
    } else {
      _snack(auth.errorMessage ?? 'Xatolik', AppColors.error);
    }
  }

  void _snack(String msg, Color color) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));

  @override
  void dispose() { _name.dispose(); _phone.dispose(); _password.dispose(); _confirm.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<AuthProvider>().isLoading;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ro\'yxatdan o\'tish'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Yangi hisob yarating', style: AppTextStyles.h2),
          const SizedBox(height: 6),
          const Text('Ma\'lumotlaringizni to\'ldiring', style: AppTextStyles.bodySecondary),
          const SizedBox(height: 28),

          const Text('Hisob turi', style: AppTextStyles.label),
          const SizedBox(height: 10),
          Row(children: [
            _roleCard('user',  'Foydalanuvchi', Icons.person_outline),
            const SizedBox(width: 12),
            _roleCard('owner', 'Servis egasi',  Icons.business_outlined),
          ]),
          const SizedBox(height: 22),

          _field('Ism Familiya', _name, Icons.person_outline, 'Ismingizni kiriting'),
          const SizedBox(height: 16),
          _fieldPhone(),
          const SizedBox(height: 16),
          _fieldPass('Parol', _password, 'Kamida 6 ta belgi'),
          const SizedBox(height: 16),
          _fieldPass('Parolni tasdiqlang', _confirm, 'Parolni qayta kiriting'),
          const SizedBox(height: 32),

          loading
            ? Container(height: 54,
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(14)),
                child: const Center(child: SizedBox(width: 22, height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))))
            : ElevatedButton(onPressed: _register, child: const Text('Ro\'yxatdan o\'tish')),
          const SizedBox(height: 18),

          Center(child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: RichText(text: const TextSpan(children: [
              TextSpan(text: 'Hisobingiz bormi? ',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              TextSpan(text: 'Kirish',
                style: TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w600)),
            ])),
          )),
          const SizedBox(height: 30),
        ]),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, IconData icon, String hint) =>
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTextStyles.label),
      const SizedBox(height: 8),
      TextField(controller: ctrl,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 20))),
    ]);

  Widget _fieldPhone() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Telefon raqam', style: AppTextStyles.label),
    const SizedBox(height: 8),
    TextField(controller: _phone,
      keyboardType: TextInputType.phone,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+]'))],
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: const InputDecoration(
        hintText: '+998901234567',
        prefixIcon: Icon(Icons.phone_outlined, color: AppColors.textSecondary, size: 20))),
  ]);

  Widget _fieldPass(String label, TextEditingController ctrl, String hint) =>
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: AppTextStyles.label),
      const SizedBox(height: 8),
      TextField(controller: ctrl, obscureText: _obscure,
        style: const TextStyle(color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textSecondary, size: 20),
          suffixIcon: IconButton(
            icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
              color: AppColors.textSecondary, size: 20),
            onPressed: () => setState(() => _obscure = !_obscure)))),
    ]);

  Widget _roleCard(String value, String label, IconData icon) {
    final sel = _role == value;
    return Expanded(child: GestureDetector(
      onTap: () => setState(() => _role = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: sel ? AppColors.primary.withOpacity(0.12) : AppColors.bgCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: sel ? AppColors.primary : AppColors.divider, width: sel ? 1.5 : 1)),
        child: Column(children: [
          Icon(icon, color: sel ? AppColors.primary : AppColors.textSecondary, size: 28),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(
            color: sel ? AppColors.primary : AppColors.textSecondary,
            fontSize: 13, fontWeight: sel ? FontWeight.w600 : FontWeight.w400)),
        ]),
      ),
    ));
  }
}
