import 'package:flutter/material.dart';
import '../models/menu_model.dart';
import '../services/supabase_service.dart';

class MenuProvider extends ChangeNotifier {
  List<MenuModel> _menus = [];
  bool _isLoading = false;
  String? _error;

  List<MenuModel> get menus => _menus;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<String> get categories => _menus.map((m) => m.kategori).toSet().toList();

  Future<void> loadMenus() async {
    _isLoading = true;
    notifyListeners();

    try {
      _menus = await SupabaseService.getAllMenus();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addMenu(MenuModel menu) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newMenu = await SupabaseService.createMenu(menu);
      _menus.insert(0, newMenu);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateMenu(MenuModel menu) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updatedMenu = await SupabaseService.updateMenu(menu);
      final index = _menus.indexWhere((m) => m.id == menu.id);
      if (index != -1) {
        _menus[index] = updatedMenu;
      }
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Soft delete: nonaktifkan menu (tidak hapus permanen)
  Future<bool> deleteMenu(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      await SupabaseService.deleteMenu(id);
      _menus.removeWhere((m) => m.id == id);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
    }
  }

  List<MenuModel> getMenusByCategory(String category) {
    return _menus.where((m) => m.kategori == category).toList();
  }
}