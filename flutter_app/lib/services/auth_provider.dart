import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

// Demo hisoblar — foydalanuvchiga ko'rsatilmaydi (README da yozilgan)
final _demoUsers = <Map<String, dynamic>>[
  {'id': 1, 'name': 'Alisher Karimov',  'phone': '+998901234567', 'password': 'user123',  'role': 'user',  'email': ''},
  {'id': 2, 'name': 'AutoPro Servis',   'phone': '+998907654321', 'password': 'owner123', 'role': 'owner', 'email': ''},
  {'id': 3, 'name': 'Admin',            'phone': '+998991111111', 'password': 'admin123', 'role': 'admin', 'email': ''},
];

class AuthProvider extends ChangeNotifier {
  static const bool _demoMode = true;

  UserModel? _user;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user         => _user;
  bool       get isLoading    => _isLoading;
  bool       get isLoggedIn   => _user != null;
  String     get role         => _user?.role ?? 'guest';
  String?    get errorMessage => _errorMessage;

  Future<bool> login(String phone, String password) async {
    _isLoading = true; _errorMessage = null; notifyListeners();
    await Future.delayed(const Duration(milliseconds: 700));
    try {
      final found = _demoUsers.where(
        (u) => u['phone'] == phone.trim() && u['password'] == password).toList();
      if (found.isEmpty) {
        _errorMessage = 'Telefon yoki parol noto\'g\'ri';
        _isLoading = false; notifyListeners(); return false;
      }
      final u = found.first;
      _user = UserModel(id: u['id'], name: u['name'], phone: u['phone'],
        email: u['email'], role: u['role'], token: 'demo_${u['id']}');
      await _save();
      _isLoading = false; notifyListeners(); return true;
    } catch (e) {
      _errorMessage = 'Xatolik yuz berdi';
      _isLoading = false; notifyListeners(); return false;
    }
  }

  Future<bool> register({required String name, required String phone,
    required String password, required String role}) async {
    _isLoading = true; _errorMessage = null; notifyListeners();
    await Future.delayed(const Duration(milliseconds: 800));
    try {
      if (_demoUsers.any((u) => u['phone'] == phone.trim())) {
        _errorMessage = 'Bu telefon raqam allaqachon ro\'yxatdan o\'tgan';
        _isLoading = false; notifyListeners(); return false;
      }
      final newId = _demoUsers.length + 10;
      _demoUsers.add({'id': newId, 'name': name.trim(), 'phone': phone.trim(),
        'password': password, 'role': role, 'email': ''});
      _user = UserModel(id: newId, name: name.trim(), phone: phone.trim(),
        email: '', role: role, token: 'demo_$newId');
      await _save();
      _isLoading = false; notifyListeners(); return true;
    } catch (e) {
      _errorMessage = 'Xatolik yuz berdi';
      _isLoading = false; notifyListeners(); return false;
    }
  }

  Future<void> loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final s = prefs.getString('current_user');
    if (s == null) return;
    try {
      _user = UserModel.fromJson(jsonDecode(s));
      notifyListeners();
    } catch (_) { await prefs.remove('current_user'); }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('current_user');
    _user = null; notifyListeners();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_user', jsonEncode(_user!.toJson()));
  }
}
