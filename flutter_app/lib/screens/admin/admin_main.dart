import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_provider.dart';
import '../../services/service_provider.dart';

class AdminMain extends StatefulWidget {
  const AdminMain({super.key});
  @override State<AdminMain> createState() => _AdminMainState();
}
class _AdminMainState extends State<AdminMain> {
  int _idx = 0;
  @override
  Widget build(BuildContext context) {
    final screens = [const _Dash(), const _Services(), const _Users(), const _Settings()];
    return Scaffold(
      body: IndexedStack(index: _idx, children: screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.divider))),
        child: BottomNavigationBar(
          currentIndex: _idx, onTap: (i) => setState(() => _idx = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.business_outlined), activeIcon: Icon(Icons.business_rounded), label: 'Servislar'),
            BottomNavigationBarItem(icon: Icon(Icons.people_outline), activeIcon: Icon(Icons.people_rounded), label: 'Foydalanuvchilar'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), activeIcon: Icon(Icons.settings_rounded), label: 'Sozlamalar'),
          ],
        ),
      ),
    );
  }
}

class _Dash extends StatelessWidget {
  const _Dash();
  @override
  Widget build(BuildContext context) {
    final bp = context.watch<BookingProvider>();
    final sp = context.watch<ServiceProvider>();
    return Scaffold(
      appBar: AppBar(title: Row(children: [
        Container(width: 28, height: 28,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(7),
            gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark])),
          child: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 15)),
        const SizedBox(width: 8), const Text('Admin Panel'),
      ])),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Statistika', style: AppTextStyles.h3),
          const SizedBox(height: 14),
          GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2, childAspectRatio: 1.4, crossAxisSpacing: 12, mainAxisSpacing: 12,
            children: [
              _card('Jami servislar', '${sp.services.length}', Icons.business_outlined, AppColors.primary),
              _card('Jami bronlar', '${bp.all.length}', Icons.receipt_outlined, AppColors.success),
              _card('Kutilmoqda', '${bp.all.where((b) => b.status == "pending").length}', Icons.pending_outlined, AppColors.warning),
              _card('Bajarildi', '${bp.all.where((b) => b.status == "completed").length}', Icons.check_circle_outline, AppColors.success),
            ]),
          const SizedBox(height: 22),
          const Text('So\'nggi bronlar', style: AppTextStyles.h3),
          const SizedBox(height: 10),
          if (bp.all.isEmpty)
            Container(padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.divider)),
              child: const Center(child: Text('Hali bronlar yo\'q', style: AppTextStyles.bodySecondary)))
          else
            ...bp.all.take(10).map((b) {
              final clr = {'pending': AppColors.warning, 'completed': AppColors.success, 'cancelled': AppColors.error};
              return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.divider)),
                child: Row(children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(
                    shape: BoxShape.circle, color: clr[b.status] ?? AppColors.primary)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(b.serviceName, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
                    Text('${b.carModel} · ${b.date} ${b.time}', style: AppTextStyles.caption),
                  ])),
                ]));
            }),
        ],
      )),
    );
  }

  Widget _card(String label, String value, IconData icon, Color color) =>
    Container(padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Container(padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 18)),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w700)),
          Text(label, style: AppTextStyles.caption, maxLines: 2),
        ]),
      ]));
}

class _Services extends StatelessWidget {
  const _Services();
  @override
  Widget build(BuildContext context) {
    final services = context.watch<ServiceProvider>().services;
    return Scaffold(
      appBar: AppBar(title: Text('Servislar (${services.length})')),
      body: services.isEmpty
        ? const Center(child: Text('Servislar yo\'q', style: AppTextStyles.bodySecondary))
        : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: services.length,
          itemBuilder: (_, i) {
            final s = services[i];
            return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.divider)),
              child: Row(children: [
                Container(width: 44, height: 44,
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.car_repair_rounded, color: AppColors.primary, size: 22)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Text(s.name, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                    if (s.isVerified) const Padding(padding: EdgeInsets.only(left: 4),
                      child: Icon(Icons.verified_rounded, color: AppColors.primary, size: 13)),
                  ]),
                  Text(s.city, style: AppTextStyles.caption),
                  Text('${s.images.length} ta rasm', style: AppTextStyles.caption),
                ])),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert_rounded, color: AppColors.textSecondary),
                  color: AppColors.bgCard,
                  onSelected: (v) => ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$v: ${s.name}'), backgroundColor: AppColors.bgCardLight,
                      behavior: SnackBarBehavior.floating)),
                  itemBuilder: (_) => [
                    const PopupMenuItem(value: 'Ko\'rish', child: Text('Ko\'rish', style: TextStyle(color: AppColors.textPrimary))),
                    const PopupMenuItem(value: 'Tasdiqlash', child: Text('Tasdiqlash', style: TextStyle(color: AppColors.success))),
                    const PopupMenuItem(value: 'Bloklash', child: Text('Bloklash', style: TextStyle(color: AppColors.error))),
                  ]),
              ]));
          }),
    );
  }
}

class _Users extends StatelessWidget {
  const _Users();
  @override
  Widget build(BuildContext context) {
    final demoNames = ['Alisher Karimov', 'AutoPro Servis'];
    final demoRoles = ['user', 'owner'];
    return Scaffold(
      appBar: AppBar(title: Text('Foydalanuvchilar (${demoNames.length})')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: demoNames.length,
        itemBuilder: (_, i) => Container(margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider)),
          child: Row(children: [
            CircleAvatar(radius: 20, backgroundColor: AppColors.primary.withOpacity(0.2),
              child: Text(demoNames[i][0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(demoNames[i], style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
              Text(demoRoles[i] == 'owner' ? 'Servis egasi' : 'Foydalanuvchi', style: AppTextStyles.caption),
            ])),
            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: (demoRoles[i] == 'owner' ? AppColors.accent : AppColors.primary).withOpacity(0.12),
                borderRadius: BorderRadius.circular(8)),
              child: Text(demoRoles[i] == 'owner' ? 'Egasi' : 'User',
                style: TextStyle(color: demoRoles[i] == 'owner' ? AppColors.accent : AppColors.primary,
                  fontSize: 11, fontWeight: FontWeight.w600))),
          ])),
      ),
    );
  }
}

class _Settings extends StatelessWidget {
  const _Settings();
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Sozlamalar')),
    body: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        ...[
          [Icons.notifications_outlined, 'Bildirishnomalar'],
          [Icons.language_outlined,      'Til sozlamalari'],
          [Icons.bar_chart_rounded,      'Hisobotlar'],
          [Icons.policy_outlined,        'Foydalanish shartlari'],
        ].map((item) => GestureDetector(
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${item[1] as String} — tez kunda'), backgroundColor: AppColors.bgCardLight,
              behavior: SnackBarBehavior.floating)),
          child: Container(margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider)),
            child: Row(children: [
              Icon(item[0] as IconData, color: AppColors.textSecondary, size: 20),
              const SizedBox(width: 14),
              Expanded(child: Text(item[1] as String, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15))),
              const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: AppColors.textHint),
            ])))),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            await context.read<AuthProvider>().logout();
            if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
          },
          child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.divider)),
            child: const Row(children: [
              Icon(Icons.logout_rounded, color: AppColors.error, size: 20),
              SizedBox(width: 14),
              Text('Chiqish', style: TextStyle(color: AppColors.error, fontSize: 15)),
            ]))),
      ]),
    ),
  );
}
