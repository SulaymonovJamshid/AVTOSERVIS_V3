import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../services/service_provider.dart';
import 'online_booking_screen.dart';

class ServiceDetailScreen extends StatefulWidget {
  final int id;
  const ServiceDetailScreen({super.key, required this.id});
  @override State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  bool _isFav = false;
  int _imgIdx = 0;

  @override void initState() { super.initState(); _tab = TabController(length: 3, vsync: this); }
  @override void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final service = context.read<ServiceProvider>().getById(widget.id);
    if (service == null) return const Scaffold(body: Center(child: Text('Topilmadi')));

    return Scaffold(
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 220, pinned: true, backgroundColor: AppColors.bgDark,
          leading: GestureDetector(onTap: () => Navigator.pop(context),
            child: Container(margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.bgCard.withOpacity(0.9), shape: BoxShape.circle),
              child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18))),
          actions: [
            GestureDetector(onTap: () => setState(() => _isFav = !_isFav),
              child: Container(margin: const EdgeInsets.all(8), padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.bgCard.withOpacity(0.9), shape: BoxShape.circle),
                child: Icon(_isFav ? Icons.favorite_rounded : Icons.favorite_outline,
                  color: _isFav ? AppColors.error : Colors.white, size: 20))),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: service.images.isNotEmpty
              ? Stack(fit: StackFit.expand, children: [
                  PageView.builder(
                    itemCount: service.images.length,
                    onPageChanged: (i) => setState(() => _imgIdx = i),
                    itemBuilder: (_, i) => Image.network(service.images[i], fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _heroPlaceholder())),
                  // Dots
                  Positioned(bottom: 12, left: 0, right: 0,
                    child: Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(service.images.length, (i) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: _imgIdx == i ? 16 : 6, height: 6,
                        decoration: BoxDecoration(
                          color: _imgIdx == i ? Colors.white : Colors.white38,
                          borderRadius: BorderRadius.circular(3)))))),
                ])
              : _heroPlaceholder(),
          ),
        ),
        SliverToBoxAdapter(child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Text(service.name, style: AppTextStyles.h2)),
              if (service.isVerified)
                const Icon(Icons.verified_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: (service.isOpen ? AppColors.success : AppColors.error).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8)),
                child: Text(service.isOpen ? 'Ochiq' : 'Yopiq', style: TextStyle(
                  color: service.isOpen ? AppColors.success : AppColors.error,
                  fontSize: 12, fontWeight: FontWeight.w600))),
            ]),
            const SizedBox(height: 8),
            _row(Icons.location_on_outlined, service.address),
            _row(Icons.access_time_outlined, service.workingHours),
            _row(Icons.phone_outlined, service.phone),
            const SizedBox(height: 12),
            Row(children: [
              ...List.generate(5, (i) => Icon(
                i < service.rating.floor() ? Icons.star_rounded
                    : service.rating - i > 0.5 ? Icons.star_half_rounded : Icons.star_outline_rounded,
                color: AppColors.star, size: 18)),
              const SizedBox(width: 6),
              Text(service.rating.toStringAsFixed(1),
                style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w700, fontSize: 15)),
              Text(' (${service.reviewCount} ta)', style: AppTextStyles.bodySecondary),
            ]),
            const SizedBox(height: 20),
            // Bron tugmasi
            ElevatedButton.icon(
              onPressed: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => OnlineBookingScreen(service: service))),
              icon: const Icon(Icons.calendar_month_rounded, size: 18),
              label: const Text('Onlayn bron qilish'),
            ),
            const SizedBox(height: 22),
            TabBar(
              controller: _tab,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              indicatorColor: AppColors.primary,
              tabs: const [Tab(text: 'Ma\'lumot'), Tab(text: 'Xizmatlar'), Tab(text: 'Izohlar')],
            ),
            const SizedBox(height: 14),
            SizedBox(height: 300, child: TabBarView(controller: _tab, children: [
              _tabInfo(service),
              _tabServices(),
              _tabReviews(),
            ])),
          ]),
        )),
      ]),
    );
  }

  Widget _heroPlaceholder() => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color(0xFF0A1628), Color(0xFF111827)])),
    child: const Center(child: Icon(Icons.car_repair_rounded, color: AppColors.primary, size: 80)));

  Widget _row(IconData icon, String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(children: [
      Icon(icon, color: AppColors.textSecondary, size: 15),
      const SizedBox(width: 6),
      Expanded(child: Text(text, style: AppTextStyles.bodySecondary)),
    ]));

  Widget _tabInfo(ServiceModel s) => SingleChildScrollView(child: Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(s.description, style: AppTextStyles.body),
      const SizedBox(height: 12),
      Wrap(spacing: 8, runSpacing: 8,
        children: s.categories.map((c) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primary.withOpacity(0.3))),
          child: Text(c, style: const TextStyle(color: AppColors.primary, fontSize: 12)))).toList()),
    ]));

  Widget _tabServices() => ListView(physics: const NeverScrollableScrollPhysics(), children: [
    _svc('Moy almashtirish',  '50 000 so\'m', Icons.oil_barrel_outlined),
    _svc('Shina montaji',     '30 000 so\'m', Icons.tire_repair_outlined),
    _svc('Diagnostika',       '100 000 so\'m', Icons.settings_outlined),
    _svc('Konditsioner',      'Kelishiladi',  Icons.ac_unit_outlined),
    _svc('Kuzov ta\'miri',    'Kelishiladi',  Icons.directions_car_outlined),
  ]);

  Widget _svc(String name, String price, IconData icon) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.divider)),
    child: Row(children: [
      Icon(icon, color: AppColors.primary, size: 20),
      const SizedBox(width: 12),
      Expanded(child: Text(name, style: AppTextStyles.body)),
      Text(price, style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600, fontSize: 13)),
    ]));

  Widget _tabReviews() => ListView.builder(
    physics: const NeverScrollableScrollPhysics(),
    itemCount: demoReviews.length,
    itemBuilder: (_, i) {
      final r = demoReviews[i];
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            CircleAvatar(radius: 18, backgroundColor: AppColors.primary.withOpacity(0.2),
              child: Text(r.userName[0], style: const TextStyle(color: AppColors.primary))),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(r.userName, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
              Text(r.createdAt, style: AppTextStyles.caption),
            ])),
            Row(children: List.generate(r.rating.toInt(), (_) =>
              const Icon(Icons.star_rounded, color: AppColors.star, size: 13))),
          ]),
          const SizedBox(height: 8),
          Text(r.comment, style: AppTextStyles.bodySecondary),
        ]),
      );
    });
}
