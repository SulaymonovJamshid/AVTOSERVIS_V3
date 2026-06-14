import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../services/auth_provider.dart';
import '../../services/service_provider.dart';
import 'service_detail_screen.dart';

class UserMain extends StatefulWidget {
  const UserMain({super.key});
  @override State<UserMain> createState() => _UserMainState();
}
class _UserMainState extends State<UserMain> {
  int _idx = 0;
  @override
  Widget build(BuildContext context) {
    final screens = [
      const _HomeScreen(),
      const _SearchScreen(),
      const _BookingsScreen(),
      const _ProfileScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: _idx, children: screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.divider))),
        child: BottomNavigationBar(
          currentIndex: _idx, onTap: (i) => setState(() => _idx = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home_rounded), label: 'Bosh sahifa'),
            BottomNavigationBarItem(icon: Icon(Icons.search_outlined), activeIcon: Icon(Icons.search_rounded), label: 'Qidirish'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today_rounded), label: 'Bronlarim'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person_rounded), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}

// ═══════════ HOME ═══════════════════════════════════════════════════════════════
class _HomeScreen extends StatelessWidget {
  const _HomeScreen();
  static const _cats = [
    {'icon': Icons.apps_rounded,            'label': 'Barchasi',    'value': 'all'},
    {'icon': Icons.oil_barrel_outlined,     'label': 'Moy',         'value': 'oil'},
    {'icon': Icons.tire_repair_outlined,    'label': 'Shina',       'value': 'tire'},
    {'icon': Icons.electrical_services,     'label': 'Elektrik',    'value': 'electric'},
    {'icon': Icons.ac_unit_outlined,        'label': 'Konditsioner','value': 'ac'},
    {'icon': Icons.directions_car_outlined, 'label': 'Kuzov',       'value': 'body'},
    {'icon': Icons.local_car_wash_outlined, 'label': 'Avtoyu v',    'value': 'wash'},
    {'icon': Icons.settings_outlined,       'label': 'Diagnostika', 'value': 'diag'},
  ];

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final sp   = context.watch<ServiceProvider>();
    final name = auth.user?.name.split(' ').first ?? 'Mehmon';

    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          floating: true, snap: true, backgroundColor: AppColors.bgDark,
          title: Row(children: [
            Container(width: 32, height: 32,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(9),
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark])),
              child: const Icon(Icons.car_repair_rounded, color: Colors.white, size: 18)),
            const SizedBox(width: 8),
            RichText(text: const TextSpan(children: [
              TextSpan(text: 'Avto', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
              TextSpan(text: 'Servis', style: TextStyle(color: AppColors.primary, fontSize: 20, fontWeight: FontWeight.w800)),
            ])),
          ]),
          actions: [IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {})],
        ),
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20,16,20,0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Salom, $name! 👋', style: AppTextStyles.h2),
            const SizedBox(height: 4),
            const Text('Bugun qanday yordam kerak?', style: AppTextStyles.bodySecondary),
            const SizedBox(height: 16),
            _banner(),
            const SizedBox(height: 20),
            const Text('Xizmat turlari', style: AppTextStyles.h3),
            const SizedBox(height: 12),
          ]),
        )),
        SliverToBoxAdapter(child: SizedBox(height: 82, child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _cats.length,
          itemBuilder: (ctx, i) {
            final cat = _cats[i];
            final sel = sp.selectedCategory == cat['value'];
            return GestureDetector(
              onTap: () => context.read<ServiceProvider>().setCategory(cat['value'] as String),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: sel ? AppColors.primary.withOpacity(0.15) : AppColors.bgCard,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: sel ? AppColors.primary : AppColors.divider, width: sel ? 1.5 : 1)),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(cat['icon'] as IconData, color: sel ? AppColors.primary : AppColors.textSecondary, size: 22),
                  const SizedBox(height: 4),
                  Text(cat['label'] as String, style: TextStyle(
                    color: sel ? AppColors.primary : AppColors.textSecondary,
                    fontSize: 10, fontWeight: sel ? FontWeight.w600 : FontWeight.w400)),
                ]),
              ),
            );
          },
        ))),
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.fromLTRB(20,20,20,12),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Servislar', style: AppTextStyles.h3),
            Text('${sp.services.length} ta', style: AppTextStyles.bodySecondary),
          ]),
        )),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: sp.services.isEmpty
            ? SliverToBoxAdapter(child: _empty())
            : SliverList(delegate: SliverChildBuilderDelegate(
                (_, i) => _ServiceCard(service: sp.services[i]),
                childCount: sp.services.length)),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ]),
    );
  }

  Widget _banner() => Container(
    height: 120,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      gradient: const LinearGradient(
        colors: [Color(0xFF0047CC), Color(0xFF0066FF)],
        begin: Alignment.topLeft, end: Alignment.bottomRight)),
    child: Stack(children: [
      Positioned(right: -15, bottom: -15, child: Opacity(opacity: 0.12,
        child: const Icon(Icons.directions_car_rounded, size: 130, color: Colors.white))),
      Padding(padding: const EdgeInsets.all(18), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('GPS orqali yaqin\navtoservisni toping!', style: TextStyle(
            color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700, height: 1.3)),
          const SizedBox(height: 10),
          Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(9)),
            child: const Text('Xaritada ko\'rish →',
              style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600))),
        ],
      )),
    ]),
  );

  Widget _empty() => Container(
    padding: const EdgeInsets.all(32),
    child: Column(children: [
      const Icon(Icons.business_outlined, size: 60, color: AppColors.textHint),
      const SizedBox(height: 12),
      const Text('Servislar topilmadi', style: AppTextStyles.h3),
      const Text('Boshqa kategoriya tanlang', style: AppTextStyles.bodySecondary),
    ]),
  );
}

// ═══════════ SERVICE CARD ════════════════════════════════════════════════════════
class _ServiceCard extends StatelessWidget {
  final ServiceModel service;
  const _ServiceCard({required this.service});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => Navigator.push(context, MaterialPageRoute(
      builder: (_) => ServiceDetailScreen(id: service.id))),
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Rasm (agar yuklangan bo'lsa)
        if (service.images.isNotEmpty)
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: SizedBox(height: 150, width: double.infinity,
              child: PageView.builder(
                itemCount: service.images.length,
                itemBuilder: (_, i) => Image.network(service.images[i],
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder()),
              ),
            ),
          )
        else
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: _placeholder(),
          ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(service.name,
                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 15))),
              if (service.isVerified)
                const Icon(Icons.verified_rounded, color: AppColors.primary, size: 15),
            ]),
            const SizedBox(height: 4),
            Row(children: [
              const Icon(Icons.location_on_outlined, color: AppColors.textSecondary, size: 13),
              const SizedBox(width: 3),
              Expanded(child: Text(service.address,
                style: AppTextStyles.caption, maxLines: 1, overflow: TextOverflow.ellipsis)),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.star_rounded, color: AppColors.star, size: 14),
              const SizedBox(width: 3),
              Text('${service.rating}', style: const TextStyle(color: AppColors.textPrimary, fontSize: 12, fontWeight: FontWeight.w600)),
              Text(' (${service.reviewCount})', style: AppTextStyles.caption),
              const SizedBox(width: 8),
              Text('· ${service.distance} km', style: AppTextStyles.caption),
              const Spacer(),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (service.isOpen ? AppColors.success : AppColors.error).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6)),
                child: Text(service.isOpen ? 'Ochiq' : 'Yopiq', style: TextStyle(
                  color: service.isOpen ? AppColors.success : AppColors.error,
                  fontSize: 10, fontWeight: FontWeight.w600))),
            ]),
          ]),
        ),
      ]),
    ),
  );

  Widget _placeholder() => Container(
    height: 140, color: AppColors.bgCardLight,
    child: const Center(child: Icon(Icons.car_repair_rounded, color: AppColors.primary, size: 50)));
}

// ═══════════ SEARCH ══════════════════════════════════════════════════════════════
class _SearchScreen extends StatelessWidget {
  const _SearchScreen();
  @override
  Widget build(BuildContext context) {
    final sp = context.watch<ServiceProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Servis qidirish'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16,0,16,10),
            child: TextField(
              onChanged: context.read<ServiceProvider>().setSearch,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: 'Servis nomi yoki manzil...',
                prefixIcon: Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 20)),
            ),
          ),
        ),
      ),
      body: sp.services.isEmpty
        ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.search_off_rounded, size: 60, color: AppColors.textHint),
            const SizedBox(height: 12),
            const Text('Topilmadi', style: AppTextStyles.h3),
            const Text('Boshqa so\'z bilan qidiring', style: AppTextStyles.bodySecondary),
          ]))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sp.services.length,
            itemBuilder: (_, i) => _ServiceCard(service: sp.services[i])),
    );
  }
}

// ═══════════ BOOKINGS ════════════════════════════════════════════════════════════
class _BookingsScreen extends StatefulWidget {
  const _BookingsScreen();
  @override State<_BookingsScreen> createState() => _BookingsScreenState();
}
class _BookingsScreenState extends State<_BookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  @override void initState() { super.initState(); _tab = TabController(length: 3, vsync: this); }
  @override void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mening bronlarim'),
        bottom: TabBar(controller: _tab,
          labelColor: AppColors.primary, unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [Tab(text: 'Faol'), Tab(text: 'Bajarilgan'), Tab(text: 'Bekor')],
        ),
      ),
      body: TabBarView(controller: _tab, children: [
        _list(context, 'pending'),
        _list(context, 'completed'),
        _list(context, 'cancelled'),
      ]),
    );
  }

  Widget _list(BuildContext context, String status) {
    final uid  = context.read<AuthProvider>().user?.id ?? 0;
    final bp   = context.watch<BookingProvider>();
    final list = bp.forUserByStatus(uid, status);

    if (list.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Icon(Icons.calendar_today_outlined, size: 56, color: AppColors.textHint),
      const SizedBox(height: 12),
      const Text('Bron yo\'q', style: AppTextStyles.h3),
      Text(status == 'pending' ? 'Servis tanlang va bron qiling' : 'Bu bo\'limda hech narsa yo\'q',
        style: AppTextStyles.bodySecondary),
    ]));

    final clr = {'pending': AppColors.warning, 'completed': AppColors.success, 'cancelled': AppColors.error};
    final lbl = {'pending': 'Kutilmoqda', 'completed': 'Bajarildi', 'cancelled': 'Bekor'};

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (_, i) {
        final b = list[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.divider)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Expanded(child: Text(b.serviceName, style: const TextStyle(
                color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 15))),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: clr[b.status]!.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                child: Text(lbl[b.status]!, style: TextStyle(color: clr[b.status], fontSize: 11, fontWeight: FontWeight.w600))),
            ]),
            const SizedBox(height: 6),
            Text(b.carModel, style: AppTextStyles.bodySecondary),
            Text('${b.date} · ${b.time}', style: AppTextStyles.caption),
            Text(b.serviceAddress, style: AppTextStyles.caption),
            if (b.status == 'pending') ...[
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => context.read<BookingProvider>().updateStatus(b.id, 'cancelled'),
                child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 9),
                  decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                  child: const Center(child: Text('Bekor qilish',
                    style: TextStyle(color: AppColors.error, fontSize: 13, fontWeight: FontWeight.w600)))),
              ),
            ],
          ]),
        );
      },
    );
  }
}

// ═══════════ PROFILE ═════════════════════════════════════════════════════════════
class _ProfileScreen extends StatelessWidget {
  const _ProfileScreen();

  @override
  Widget build(BuildContext context) {
    final user  = context.watch<AuthProvider>().user;
    final name  = user?.name  ?? 'Foydalanuvchi';
    final phone = user?.phone ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          Center(child: Column(children: [
            Container(width: 84, height: 84,
              decoration: BoxDecoration(shape: BoxShape.circle,
                gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark])),
              child: Center(child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'U',
                style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w700)))),
            const SizedBox(height: 12),
            Text(name, style: AppTextStyles.h2),
            Text(phone, style: AppTextStyles.bodySecondary),
          ])),
          const SizedBox(height: 28),
          _item(Icons.favorite_outline,       'Saralangan servislar', () {}),
          _item(Icons.notifications_outlined, 'Bildirishnomalar',     () {}),
          _item(Icons.help_outline,           'Yordam',               () {}),
          const SizedBox(height: 8),
          _item(Icons.logout_rounded, 'Chiqish', () async {
            await context.read<AuthProvider>().logout();
            if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
          }, isRed: true),
        ]),
      ),
    );
  }

  Widget _item(IconData icon, String label, VoidCallback onTap, {bool isRed = false}) =>
    GestureDetector(onTap: onTap, child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider)),
      child: Row(children: [
        Icon(icon, color: isRed ? AppColors.error : AppColors.textSecondary, size: 20),
        const SizedBox(width: 14),
        Expanded(child: Text(label, style: TextStyle(
          color: isRed ? AppColors.error : AppColors.textPrimary, fontSize: 15))),
        if (!isRed) const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: AppColors.textHint),
      ]),
    ));
}
