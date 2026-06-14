import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../services/auth_provider.dart';
import '../../services/service_provider.dart';

class OnlineBookingScreen extends StatefulWidget {
  final ServiceModel service;
  const OnlineBookingScreen({super.key, required this.service});
  @override State<OnlineBookingScreen> createState() => _OnlineBookingScreenState();
}

class _OnlineBookingScreenState extends State<OnlineBookingScreen> {
  final _carCtrl  = TextEditingController();
  final _descCtrl = TextEditingController();

  int _step = 0;
  DateTime _date    = DateTime.now().add(const Duration(days: 1));
  String? _time;

  static const _slots = [
    '09:00','10:00','11:00','12:00','13:00',
    '14:00','15:00','16:00','17:00','18:00',
  ];

  Set<String> get _booked =>
    context.read<ServiceProvider>().getBookedSlots(widget.service.id);

  bool _isFree(String t) {
    final key = '${_date.toIso8601String().substring(0,10)}_$t';
    return !_booked.contains(key);
  }

  @override
  void dispose() { _carCtrl.dispose(); _descCtrl.dispose(); super.dispose(); }

  // ─── Validation per step ────────────────────────────────────────────────────
  bool get _canProceed => switch (_step) {
    0 => true,
    1 => _time != null,
    2 => _carCtrl.text.trim().isNotEmpty && _descCtrl.text.trim().isNotEmpty,
    _ => true,
  };

  void _next() {
    if (!_canProceed) {
      String msg = '';
      if (_step == 1) msg = 'Iltimos soat tanlang';
      if (_step == 2) msg = 'Mashina modeli va muammoni yozing';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(msg), backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
      return;
    }
    if (_step < 3) {
      setState(() => _step++);
    } else {
      _submit();
    }
  }

  void _back() {
    if (_step > 0) setState(() => _step--);
    else Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async { _back(); return false; },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Onlayn bron qilish'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: _back),
        ),
        body: Column(children: [
          _stepper(),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: KeyedSubtree(
                key: ValueKey(_step),
                child: [_stepDate(), _stepTime(), _stepInfo(), _stepConfirm()][_step],
              ),
            ),
          )),
          _bottomBar(),
        ]),
      ),
    );
  }

  // ─── Stepper ─────────────────────────────────────────────────────────────────
  Widget _stepper() {
    final labels = ['Sana','Soat','Ma\'lumot','Tasdiqlash'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: AppColors.bgCard,
      child: Row(children: List.generate(4, (i) {
        final done = i < _step, cur = i == _step;
        return Expanded(child: Row(children: [
          Column(mainAxisSize: MainAxisSize.min, children: [
            AnimatedContainer(duration: const Duration(milliseconds: 250),
              width: 26, height: 26,
              decoration: BoxDecoration(shape: BoxShape.circle,
                color: done || cur ? AppColors.primary : AppColors.bgInput,
                border: Border.all(color: done || cur ? AppColors.primary : AppColors.divider)),
              child: Center(child: done
                ? const Icon(Icons.check_rounded, color: Colors.white, size: 13)
                : Text('${i+1}', style: TextStyle(
                    color: cur ? Colors.white : AppColors.textHint,
                    fontSize: 11, fontWeight: FontWeight.w600)))),
            const SizedBox(height: 3),
            Text(labels[i], style: TextStyle(
              color: cur ? AppColors.primary : AppColors.textHint,
              fontSize: 9, fontWeight: cur ? FontWeight.w600 : FontWeight.w400)),
          ]),
          if (i < 3) Expanded(child: Container(
            height: 2, margin: const EdgeInsets.only(bottom: 14),
            color: i < _step ? AppColors.primary : AppColors.divider)),
        ]));
      })),
    );
  }

  // ─── Step 0: Sana ───────────────────────────────────────────────────────────
  Widget _stepDate() {
    final now   = DateTime.now();
    final dates = List.generate(14, (i) => now.add(Duration(days: i + 1)));
    const dayNames = ['','Du','Se','Ch','Pa','Ju','Sh','Ya'];
    const monthNames = ['','Yan','Fev','Mar','Apr','May','Iyn','Iyl','Avg','Sen','Okt','Noy','Dek'];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Sana tanlang', style: AppTextStyles.h3),
      const SizedBox(height: 6),
      const Text('Kelishingiz mumkin bo\'lgan kunni tanlang', style: AppTextStyles.bodySecondary),
      const SizedBox(height: 20),
      GridView.builder(
        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, childAspectRatio: 0.9, crossAxisSpacing: 10, mainAxisSpacing: 10),
        itemCount: dates.length,
        itemBuilder: (_, i) {
          final d = dates[i];
          final sel = _date.day == d.day && _date.month == d.month;
          return GestureDetector(
            onTap: () => setState(() { _date = d; _time = null; }),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                color: sel ? AppColors.primary : AppColors.bgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: sel ? AppColors.primary : AppColors.divider)),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(dayNames[d.weekday],
                  style: TextStyle(color: sel ? Colors.white70 : AppColors.textSecondary, fontSize: 10)),
                const SizedBox(height: 2),
                Text('${d.day}', style: TextStyle(
                  color: sel ? Colors.white : AppColors.textPrimary,
                  fontSize: 20, fontWeight: FontWeight.w700)),
                Text(monthNames[d.month],
                  style: TextStyle(color: sel ? Colors.white70 : AppColors.textSecondary, fontSize: 10)),
              ]),
            ),
          );
        },
      ),
    ]);
  }

  // ─── Step 1: Soat ───────────────────────────────────────────────────────────
  Widget _stepTime() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Soat tanlang', style: AppTextStyles.h3),
      const SizedBox(height: 6),
      Text('${_date.day}.${_date.month}.${_date.year} uchun bo\'sh soatlar',
        style: AppTextStyles.bodySecondary),
      const SizedBox(height: 20),
      GridView.builder(
        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, childAspectRatio: 2.4, crossAxisSpacing: 10, mainAxisSpacing: 10),
        itemCount: _slots.length,
        itemBuilder: (_, i) {
          final t    = _slots[i];
          final free = _isFree(t);
          final sel  = _time == t;
          return GestureDetector(
            onTap: free ? () => setState(() => _time = t) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                color: !free ? AppColors.bgInput.withOpacity(0.4)
                    : sel  ? AppColors.primary : AppColors.bgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: !free ? AppColors.divider.withOpacity(0.3)
                      : sel  ? AppColors.primary : AppColors.divider)),
              child: Center(child: Text(t, style: TextStyle(
                color: !free ? AppColors.textHint
                    : sel  ? Colors.white : AppColors.textPrimary,
                fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                fontSize: 15,
                decoration: !free ? TextDecoration.lineThrough : null))),
            ),
          );
        },
      ),
      const SizedBox(height: 16),
      Row(children: [
        _dot(AppColors.primary, 'Bo\'sh'),
        const SizedBox(width: 16),
        _dot(AppColors.bgInput, 'Band'),
      ]),
    ]);
  }

  Widget _dot(Color c, String l) => Row(children: [
    Container(width: 10, height: 10, decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(3))),
    const SizedBox(width: 5),
    Text(l, style: AppTextStyles.caption),
  ]);

  // ─── Step 2: Ma'lumot ────────────────────────────────────────────────────────
  Widget _stepInfo() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Mashina ma\'lumoti', style: AppTextStyles.h3),
    const SizedBox(height: 6),
    const Text('Mashinangiz va muammo haqida ma\'lumot bering', style: AppTextStyles.bodySecondary),
    const SizedBox(height: 24),
    const Text('Mashina modeli', style: AppTextStyles.label),
    const SizedBox(height: 8),
    TextField(
      controller: _carCtrl,
      style: const TextStyle(color: AppColors.textPrimary),
      onChanged: (_) => setState(() {}),
      decoration: const InputDecoration(
        hintText: 'Masalan: Chevrolet Cobalt 2022',
        prefixIcon: Icon(Icons.directions_car_outlined, color: AppColors.textSecondary, size: 20)),
    ),
    const SizedBox(height: 18),
    const Text('Muammo tavsifi', style: AppTextStyles.label),
    const SizedBox(height: 8),
    TextField(
      controller: _descCtrl,
      maxLines: 4,
      style: const TextStyle(color: AppColors.textPrimary),
      onChanged: (_) => setState(() {}),
      decoration: const InputDecoration(
        hintText: 'Mashinangizning muammosini batafsil yozing...',
        alignLabelWithHint: true,
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: 60),
          child: Icon(Icons.description_outlined, color: AppColors.textSecondary, size: 20))),
    ),
    const SizedBox(height: 16),
    Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3))),
      child: const Row(children: [
        Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 18),
        SizedBox(width: 10),
        Expanded(child: Text('Servis egasi narx va vaqtni tasdiqlaydi',
          style: TextStyle(color: AppColors.primary, fontSize: 12))),
      ]),
    ),
  ]);

  // ─── Step 3: Tasdiqlash ──────────────────────────────────────────────────────
  Widget _stepConfirm() {
    const months = ['','Yanvar','Fevral','Mart','Aprel','May','Iyun',
                    'Iyul','Avgust','Sentyabr','Oktyabr','Noyabr','Dekabr'];
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Bronni tasdiqlang', style: AppTextStyles.h3),
      const SizedBox(height: 6),
      const Text('Ma\'lumotlarni tekshirib, tasdiqlang', style: AppTextStyles.bodySecondary),
      const SizedBox(height: 22),
      _row('🏢 Servis',   widget.service.name),
      _row('📍 Manzil',  widget.service.address),
      _row('📅 Sana',    '${_date.day} ${months[_date.month]} ${_date.year}'),
      _row('🕐 Soat',    _time ?? ''),
      _row('🚗 Mashina', _carCtrl.text),
      _row('📝 Muammo',  _descCtrl.text),
      const SizedBox(height: 20),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.success.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.success.withOpacity(0.3))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Row(children: [
            Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 18),
            SizedBox(width: 8),
            Text('Bron qabul qilinsa:', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600, fontSize: 13)),
          ]),
          const SizedBox(height: 8),
          ...['Servis egasi siz bilan bog\'lanadi',
              'SMS bildirishnoma yuboriladi',
              '"Bronlarim" bo\'limida ko\'rasiz'].map((t) =>
            Padding(padding: const EdgeInsets.only(top: 4),
              child: Row(children: [
                const SizedBox(width: 26),
                const Icon(Icons.arrow_right_rounded, color: AppColors.textSecondary, size: 16),
                const SizedBox(width: 4),
                Text(t, style: AppTextStyles.caption),
              ]))),
        ]),
      ),
    ]);
  }

  Widget _row(String label, String val) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.divider)),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 90, child: Text(label, style: AppTextStyles.label)),
      const SizedBox(width: 8),
      Expanded(child: Text(val, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w500))),
    ]),
  );

  // ─── Bottom bar ──────────────────────────────────────────────────────────────
  Widget _bottomBar() => Container(
    padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
    decoration: const BoxDecoration(
      color: AppColors.bgCard,
      border: Border(top: BorderSide(color: AppColors.divider))),
    child: ElevatedButton(
      onPressed: _next,
      style: ElevatedButton.styleFrom(
        backgroundColor: _canProceed ? AppColors.primary : AppColors.bgInput,
        foregroundColor: _canProceed ? Colors.white : AppColors.textHint),
      child: Text(_step == 3 ? 'Bronni yuborish ✓' : 'Davom etish →'),
    ),
  );

  // ─── Submit ──────────────────────────────────────────────────────────────────
  void _submit() {
    final auth = context.read<AuthProvider>();
    final sp   = context.read<ServiceProvider>();
    final bp   = context.read<BookingProvider>();

    final slotKey = '${_date.toIso8601String().substring(0,10)}_$_time';
    sp.addBookedSlot(widget.service.id, slotKey);

    bp.add(BookingModel(
      id: DateTime.now().millisecondsSinceEpoch,
      serviceId: widget.service.id,
      serviceName: widget.service.name,
      serviceAddress: widget.service.address,
      userId: auth.user?.id ?? 0,
      carModel: _carCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      status: 'pending',
      date: '${_date.day}.${_date.month}.${_date.year}',
      time: _time ?? '',
    ));

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 72, height: 72,
            decoration: BoxDecoration(color: AppColors.success.withOpacity(0.15), shape: BoxShape.circle),
            child: const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 42)),
          const SizedBox(height: 16),
          const Text('Bron yuborildi!', style: AppTextStyles.h3, textAlign: TextAlign.center),
          const SizedBox(height: 8),
          Text('${widget.service.name}\n$_time soatga bron qilindi.',
            style: AppTextStyles.bodySecondary, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () { Navigator.pop(context); Navigator.pop(context); },
            child: const Text('Yopish')),
        ]),
      ),
    );
  }
}
