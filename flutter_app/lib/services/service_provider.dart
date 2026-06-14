import 'package:flutter/material.dart';
import '../models/models.dart';

// ─── Demo servislar (1 ta — qolganlari ro'yxatdan o'tib qo'shadi) ─────────────
final _services = <ServiceModel>[
  ServiceModel(
    id: 1, ownerId: 2,
    name: 'AutoPro Service',
    description: 'Professional avtoservis markazi. Barcha turdagi avtomobillar bilan ishlaymiz. '
        'Zamonaviy diagnostika uskunalari bilan jihozlanganmiz. 10+ yillik tajriba.',
    address: 'Yunusobod tumani, 7-mavze',
    city: 'Toshkent',
    lat: 41.3111, lng: 69.2797,
    phone: '+998907654321',
    images: [], // Egasi rasm yuklaydi
    categories: ['oil', 'tire', 'electric', 'diag'],
    rating: 4.8, reviewCount: 124,
    isOpen: true, workingHours: '09:00 - 20:00',
    distance: 1.2, isVerified: true,
  ),
];

// ─── Demo izohlar ─────────────────────────────────────────────────────────────
final demoReviews = [
  ReviewModel(id: 1, userName: 'Abdullayev J.', rating: 5,
    comment: 'Juda yaxshi xizmat, tez va sifatli! Har doim shu joyga boraman.', createdAt: '2 kun oldin'),
  ReviewModel(id: 2, userName: 'Toshmatov S.', rating: 4,
    comment: 'Yaxshi, lekin biroz kutish bo\'ldi.', createdAt: '1 hafta oldin'),
  ReviewModel(id: 3, userName: 'Raimova D.', rating: 5,
    comment: 'Mexaniklar juda tajribali, tavsiya qilaman!', createdAt: '2 hafta oldin'),
];

// ─── Har bir servis uchun band slotlar ───────────────────────────────────────
final _bookedSlots = <int, Set<String>>{};

class ServiceProvider extends ChangeNotifier {
  String _searchQuery = '';
  String _selectedCategory = 'all';

  List<ServiceModel> get services {
    var list = List<ServiceModel>.from(_services);
    if (_selectedCategory != 'all') {
      list = list.where((s) => s.categories.contains(_selectedCategory)).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((s) =>
        s.name.toLowerCase().contains(q) || s.address.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  String get selectedCategory => _selectedCategory;

  void setCategory(String c) { _selectedCategory = c; notifyListeners(); }
  void setSearch(String q)   { _searchQuery = q; notifyListeners(); }

  ServiceModel? getById(int id) {
    try { return _services.firstWhere((s) => s.id == id); } catch (_) { return null; }
  }

  // Egasi o'z servisini oladi
  ServiceModel? getOwnerService(int ownerId) {
    try { return _services.firstWhere((s) => s.ownerId == ownerId); } catch (_) { return null; }
  }

  // Rasm qo'shish (max 6)
  void addImage(int serviceId, String imagePath) {
    final idx = _services.indexWhere((s) => s.id == serviceId);
    if (idx < 0) return;
    final s = _services[idx];
    if (s.images.length >= 6) return;
    _services[idx] = s.copyWith(images: [...s.images, imagePath]);
    notifyListeners();
  }

  void removeImage(int serviceId, int imgIdx) {
    final idx = _services.indexWhere((s) => s.id == serviceId);
    if (idx < 0) return;
    final imgs = List<String>.from(_services[idx].images)..removeAt(imgIdx);
    _services[idx] = _services[idx].copyWith(images: imgs);
    notifyListeners();
  }

  // Band slotlar — har servis uchun alohida
  Set<String> getBookedSlots(int serviceId) => _bookedSlots[serviceId] ?? {};

  void addBookedSlot(int serviceId, String slot) {
    _bookedSlots[serviceId] = {...(_bookedSlots[serviceId] ?? {}), slot};
    notifyListeners();
  }

  // Yangi servis qo'shish (ro'yxatdan o'tgan ega uchun)
  void addService(ServiceModel s) {
    _services.add(s);
    notifyListeners();
  }
}

// ─── Booking provider ─────────────────────────────────────────────────────────
class BookingProvider extends ChangeNotifier {
  final List<BookingModel> _all = [];

  List<BookingModel> get all => _all;

  // Foydalanuvchi bo'yicha
  List<BookingModel> forUser(int userId) =>
    _all.where((b) => b.userId == userId).toList();

  // Servis bo'yicha (egasi uchun)
  List<BookingModel> forService(int serviceId) =>
    _all.where((b) => b.serviceId == serviceId).toList();

  List<BookingModel> forUserByStatus(int userId, String status) =>
    _all.where((b) => b.userId == userId && b.status == status).toList();

  List<BookingModel> forServiceByStatus(int serviceId, String status) =>
    _all.where((b) => b.serviceId == serviceId && b.status == status).toList();

  void add(BookingModel b) { _all.insert(0, b); notifyListeners(); }

  void updateStatus(int id, String status) {
    final idx = _all.indexWhere((b) => b.id == id);
    if (idx < 0) return;
    final b = _all[idx];
    _all[idx] = BookingModel(
      id: b.id, serviceId: b.serviceId, serviceName: b.serviceName,
      serviceAddress: b.serviceAddress, userId: b.userId,
      carModel: b.carModel, description: b.description,
      status: status, date: b.date, time: b.time,
    );
    notifyListeners();
  }
}
