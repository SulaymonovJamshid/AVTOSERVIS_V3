import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../services/auth_provider.dart';
import '../../services/service_provider.dart';

class OwnerMain extends StatefulWidget {
  const OwnerMain({super.key});
  @override State<OwnerMain> createState() => _OwnerMainState();
}
class _OwnerMainState extends State<OwnerMain> {
  int _idx = 0;
  @override
  Widget build(BuildContext context) {
    final screens = [const _OwnerDash(), const _OwnerBookings(), const _OwnerProfile()];
    return Scaffold(
      body: IndexedStack(index: _idx, children: screens),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: AppColors.divider))),
        child: BottomNavigationBar(
          currentIndex: _idx, onTap: (i) => setState(() => _idx = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined), activeIcon: Icon(Icons.list_alt_rounded), label: 'Bronlar'),
            BottomNavigationBarItem(icon: Icon(Icons.business_outlined), activeIcon: Icon(Icons.business_rounded), label: 'Servisim'),
          ],
        ),
      ),
    );
  }
}

// ─── Dashboard ────────────────────────────────────────────────────────────────
class _OwnerDash extends StatelessWidget {
  const _OwnerDash();
  @override
  Widget build(BuildContext context) {
    final ownerId = context.read<AuthProvider>().user?.id ?? 0;
    final service = context.read<ServiceProvider>().getOwnerService(ownerId);
    final bp      = context.watch<BookingProvider>();
    final sid     = service?.id ?? 0;
    final pending = bp.forServiceByStatus(sid, 'pending');
    final done    = bp.forServiceByStatus(sid, 'completed');

    return Scaffold(
      appBar: AppBar(title: const Text('Boshqaruv paneli')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(
        crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (service != null) _serviceCard(service),
          const SizedBox(height: 22),
          const Text('Statistika', style: AppTextStyles.h3),
          const SizedBox(height: 12),
          Row(children: [
            _stat('Jami bronlar', '${bp.forService(sid).length}', AppColors.primary),
            const SizedBox(width: 10),
            _stat('Bajarildi', '${done.length}', AppColors.success),
          ]),
          const SizedBox(height: 10),
          Row(children: [
            _stat('Kutilmoqda', '${pending.length}', AppColors.warning),
            const SizedBox(width: 10),
            _stat('Bekor', '${bp.forServiceByStatus(sid, "cancelled").length}', AppColors.error),
          ]),
          const SizedBox(height: 22),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Yangi bronlar', style: AppTextStyles.h3),
            if (pending.isNotEmpty)
              Text('${pending.length} ta', style: AppTextStyles.bodySecondary),
          ]),
          const SizedBox(height: 10),
          if (pending.isEmpty)
            _empty('Yangi bron yo\'q')
          else
            ...pending.map((b) => _bronCard(context, b)),
        ],
      )),
    );
  }

  Widget _serviceCard(ServiceModel s) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
      borderRadius: BorderRadius.circular(18)),
    child: Row(children: [
      Container(width: 52, height: 52,
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(14)),
        child: const Icon(Icons.car_repair_rounded, color: Colors.white, size: 28)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(s.name, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
        Text(s.address, style: const TextStyle(color: Colors.white70, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        Row(children: [
          const Icon(Icons.star_rounded, color: Colors.amber, size: 13),
          Text(' ${s.rating}', style: const TextStyle(color: Colors.white, fontSize: 12)),
          const SizedBox(width: 8),
          if (s.isVerified) const Text('✓ Tasdiqlangan', style: TextStyle(color: Colors.white70, fontSize: 12)),
        ]),
      ])),
    ]));

  Widget _stat(String label, String val, Color color) => Expanded(child: Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.divider)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(val, style: TextStyle(color: color, fontSize: 24, fontWeight: FontWeight.w700)),
      const SizedBox(height: 4),
      Text(label, style: AppTextStyles.caption),
    ])));

  Widget _bronCard(BuildContext context, BookingModel b) => Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.warning.withOpacity(0.4))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        const Icon(Icons.directions_car_outlined, color: AppColors.primary, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(b.carModel, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600))),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: AppColors.warning.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
          child: const Text('Yangi', style: TextStyle(color: AppColors.warning, fontSize: 11, fontWeight: FontWeight.w600))),
      ]),
      const SizedBox(height: 4),
      Text(b.description, style: AppTextStyles.bodySecondary, maxLines: 2, overflow: TextOverflow.ellipsis),
      Text('${b.date} · ${b.time}', style: AppTextStyles.caption),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: GestureDetector(
          onTap: () { context.read<BookingProvider>().updateStatus(b.id, 'completed');
            _toast(context, 'Bron qabul qilindi ✓', AppColors.success); },
          child: Container(padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(color: AppColors.success.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
            child: const Center(child: Text('Qabul qilish', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600)))))),
        const SizedBox(width: 10),
        Expanded(child: GestureDetector(
          onTap: () { context.read<BookingProvider>().updateStatus(b.id, 'cancelled');
            _toast(context, 'Bron rad etildi', AppColors.error); },
          child: Container(padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(color: AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: const Center(child: Text('Rad etish', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)))))),
      ]),
    ]));

  void _toast(BuildContext ctx, String msg, Color color) =>
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(msg),
      backgroundColor: color, behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));

  Widget _empty(String msg) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.divider)),
    child: Center(child: Text(msg, style: AppTextStyles.bodySecondary)));
}

// ─── Bronlar ─────────────────────────────────────────────────────────────────
class _OwnerBookings extends StatelessWidget {
  const _OwnerBookings();
  @override
  Widget build(BuildContext context) {
    final ownerId = context.read<AuthProvider>().user?.id ?? 0;
    final service = context.read<ServiceProvider>().getOwnerService(ownerId);
    final bp      = context.watch<BookingProvider>();
    final list    = service != null ? bp.forService(service.id) : <BookingModel>[];
    final clr = {'pending': AppColors.warning, 'completed': AppColors.success, 'cancelled': AppColors.error};
    final lbl = {'pending': 'Kutilmoqda', 'completed': 'Bajarildi', 'cancelled': 'Bekor'};

    return Scaffold(
      appBar: AppBar(title: Text('Barcha bronlar (${list.length})')),
      body: list.isEmpty
        ? const Center(child: Text('Hali bron yo\'q', style: AppTextStyles.bodySecondary))
        : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (_, i) {
            final b = list[i];
            return Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.divider)),
              child: Row(children: [
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(b.carModel, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                  Text(b.description, style: AppTextStyles.caption, maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text('${b.date} · ${b.time}', style: AppTextStyles.caption),
                ])),
                const SizedBox(width: 8),
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: (clr[b.status] ?? AppColors.primary).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8)),
                  child: Text(lbl[b.status] ?? b.status,
                    style: TextStyle(color: clr[b.status] ?? AppColors.primary, fontSize: 11, fontWeight: FontWeight.w600))),
              ]));
          }),
    );
  }
}

// ─── Servisim (Sozlamalar) ────────────────────────────────────────────────────
class _OwnerProfile extends StatelessWidget {
  const _OwnerProfile();
  @override
  Widget build(BuildContext context) {
    final user    = context.watch<AuthProvider>().user;
    final ownerId = user?.id ?? 0;
    final service = context.watch<ServiceProvider>().getOwnerService(ownerId);

    return Scaffold(
      appBar: AppBar(title: const Text('Servisim')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Servis info
          Container(padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.divider)),
            child: Row(children: [
              Container(width: 60, height: 60,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark])),
                child: const Icon(Icons.car_repair_rounded, color: Colors.white, size: 32)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(service?.name ?? user?.name ?? 'Servis egasi',
                  style: AppTextStyles.h3),
                Text(user?.phone ?? '', style: AppTextStyles.bodySecondary),
              ])),
            ])),
          const SizedBox(height: 24),

          // Rasm boshqaruvi — ENG MUHIM
          if (service != null) ...[
            const Text('Xizmat rasmlari', style: AppTextStyles.h3),
            const SizedBox(height: 6),
            Text('${service.images.length}/6 rasm yuklangan', style: AppTextStyles.bodySecondary),
            const SizedBox(height: 12),
            _imageGrid(context, service),
            const SizedBox(height: 22),
          ],

          const Text('Sozlamalar', style: AppTextStyles.h3),
          const SizedBox(height: 12),
          _item(Icons.edit_outlined,       'Servis ma\'lumotlarini tahrirlash', () => _showEditDialog(context, service)),
          _item(Icons.schedule_outlined,   'Ish vaqtlari',                    () => _showWorkingHours(context)),
          _item(Icons.category_outlined,   'Xizmat turlari',                  () => _showCategories(context)),
          _item(Icons.attach_money_rounded,'Narxlar ro\'yxati',               () => _showPrices(context)),
          _item(Icons.bar_chart_rounded,   'Statistika',                      () {}),
          const SizedBox(height: 8),
          _item(Icons.logout_rounded, 'Chiqish', () async {
            await context.read<AuthProvider>().logout();
            if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
          }, isRed: true),
        ]),
      ),
    );
  }

  Widget _imageGrid(BuildContext context, ServiceModel service) {
    final sp = context.read<ServiceProvider>();
    return GridView.builder(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, childAspectRatio: 1, crossAxisSpacing: 8, mainAxisSpacing: 8),
      itemCount: service.images.length < 6 ? service.images.length + 1 : 6,
      itemBuilder: (ctx, i) {
        if (i == service.images.length && service.images.length < 6) {
          // Rasm qo'shish tugmasi
          return GestureDetector(
            onTap: () => _showAddImageDialog(context, service.id),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.bgInput,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.5), width: 1.5)),
              child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.add_photo_alternate_outlined, color: AppColors.primary, size: 28),
                SizedBox(height: 4),
                Text('Rasm qo\'sh', style: TextStyle(color: AppColors.primary, fontSize: 10)),
              ])));
        }
        // Mavjud rasm
        return Stack(fit: StackFit.expand, children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(service.images[i], fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                decoration: BoxDecoration(color: AppColors.bgInput, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.broken_image_outlined, color: AppColors.textHint)))),
          Positioned(top: 4, right: 4, child: GestureDetector(
            onTap: () => sp.removeImage(service.id, i),
            child: Container(
              width: 22, height: 22,
              decoration: BoxDecoration(color: AppColors.error, shape: BoxShape.circle),
              child: const Icon(Icons.close_rounded, color: Colors.white, size: 14)))),
        ]);
      },
    );
  }

  void _showAddImageDialog(BuildContext context, int serviceId) {
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (_) => AlertDialog(
      backgroundColor: AppColors.bgCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Rasm URL kiriting', style: AppTextStyles.h3),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Rasmning to\'liq URL manzilini kiriting (https://...)',
          style: AppTextStyles.bodySecondary),
        const SizedBox(height: 14),
        TextField(controller: ctrl,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'https://example.com/image.jpg',
            prefixIcon: Icon(Icons.link, color: AppColors.textSecondary, size: 20))),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context),
          child: const Text('Bekor', style: TextStyle(color: AppColors.textSecondary))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(minimumSize: const Size(80, 40)),
          onPressed: () {
            final url = ctrl.text.trim();
            if (url.isNotEmpty) {
              context.read<ServiceProvider>().addImage(serviceId, url);
              Navigator.pop(context);
            }
          },
          child: const Text('Qo\'shish')),
      ],
    ));
  }

  void _showEditDialog(BuildContext context, ServiceModel? service) {
    showModalBottomSheet(context: context, backgroundColor: AppColors.bgCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4,
            decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          const Text('Servis ma\'lumotlari', style: AppTextStyles.h3),
          const SizedBox(height: 16),
          TextField(style: const TextStyle(color: AppColors.textPrimary),
            controller: TextEditingController(text: service?.name ?? ''),
            decoration: const InputDecoration(labelText: 'Servis nomi',
              prefixIcon: Icon(Icons.business_outlined, color: AppColors.textSecondary, size: 20))),
          const SizedBox(height: 12),
          TextField(style: const TextStyle(color: AppColors.textPrimary),
            controller: TextEditingController(text: service?.phone ?? ''),
            decoration: const InputDecoration(labelText: 'Telefon',
              prefixIcon: Icon(Icons.phone_outlined, color: AppColors.textSecondary, size: 20))),
          const SizedBox(height: 12),
          TextField(style: const TextStyle(color: AppColors.textPrimary),
            controller: TextEditingController(text: service?.address ?? ''),
            decoration: const InputDecoration(labelText: 'Manzil',
              prefixIcon: Icon(Icons.location_on_outlined, color: AppColors.textSecondary, size: 20))),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () { Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text('Ma\'lumotlar saqlandi ✓'), backgroundColor: AppColors.success,
                behavior: SnackBarBehavior.floating)); },
            child: const Text('Saqlash')),
        ]),
      ));
  }

  void _showWorkingHours(BuildContext context) {
    showModalBottomSheet(context: context, backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4,
            decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          const Text('Ish vaqtlari', style: AppTextStyles.h3),
          const SizedBox(height: 16),
          ...['Dushanba', 'Seshanba', 'Chorshanba', 'Payshanba', 'Juma', 'Shanba', 'Yakshanba']
            .map((d) => Padding(padding: const EdgeInsets.only(bottom: 10),
              child: Row(children: [
                SizedBox(width: 100, child: Text(d, style: AppTextStyles.body)),
                Expanded(child: TextField(
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                  controller: TextEditingController(text: d == 'Yakshanba' ? 'Dam olish' : '09:00 - 18:00'),
                  decoration: const InputDecoration(contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10)))),
              ]))),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Saqlash')),
        ]),
      ));
  }

  void _showCategories(BuildContext context) {
    final allCats = ['oil','tire','electric','ac','body','wash','diag'];
    final labels  = {'oil':'Moy','tire':'Shina','electric':'Elektrik','ac':'Konditsioner','body':'Kuzov','wash':'Avtoyu v','diag':'Diagnostika'};
    final selected = <String>{'oil','tire','electric'};
    showModalBottomSheet(context: context, backgroundColor: AppColors.bgCard,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(builder: (ctx, ss) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4,
            decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          const Text('Xizmat turlari', style: AppTextStyles.h3),
          const SizedBox(height: 16),
          Wrap(spacing: 10, runSpacing: 10, children: allCats.map((c) {
            final sel = selected.contains(c);
            return GestureDetector(
              onTap: () => ss(() => sel ? selected.remove(c) : selected.add(c)),
              child: AnimatedContainer(duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: sel ? AppColors.primary.withOpacity(0.15) : AppColors.bgInput,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: sel ? AppColors.primary : AppColors.divider)),
                child: Text(labels[c] ?? c, style: TextStyle(
                  color: sel ? AppColors.primary : AppColors.textSecondary,
                  fontWeight: sel ? FontWeight.w600 : FontWeight.w400))));
          }).toList()),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Saqlash')),
        ]),
      )));
  }

  void _showPrices(BuildContext context) {
    final prices = [
      {'name': 'Moy almashtirish', 'price': '50 000'},
      {'name': 'Shina montaji',    'price': '30 000'},
      {'name': 'Diagnostika',      'price': '100 000'},
      {'name': 'Konditsioner',     'price': 'Kelishiladi'},
    ];
    showModalBottomSheet(context: context, backgroundColor: AppColors.bgCard,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4,
            decoration: BoxDecoration(color: AppColors.divider, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          const Text('Narxlar ro\'yxati', style: AppTextStyles.h3),
          const SizedBox(height: 16),
          ...prices.map((p) => Container(margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: AppColors.bgInput, borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              Expanded(child: Text(p['name']!, style: AppTextStyles.body)),
              Text('${p['price']!} so\'m',
                style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600, fontSize: 13)),
            ]))),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Tahrirlash')),
        ]),
      ));
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
      ])));
}
