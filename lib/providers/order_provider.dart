import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/supabase_service.dart';
import '../pages/dashboard_page.dart';

class OrderProvider extends ChangeNotifier {
  List<OrderModel> _orders = [];
  List<OrderDetailModel> _currentOrderDetails = [];
  bool _isLoading = false;
  String? _error;
  double _totalTransactionsToday = 0;
  Map<String, int> _bestSellers = {};
  
  FilterPeriode _currentPeriode = FilterPeriode.harian;
  double _totalPendapatanFilter = 0;
  int _totalTransaksiFilter = 0;
  String _metodePembayaran = 'tunai';

  List<OrderModel> get orders => _orders;
  List<OrderDetailModel> get currentOrderDetails => _currentOrderDetails;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get totalTransactionsToday => _totalTransactionsToday;
  Map<String, int> get bestSellers => _bestSellers;
  
  FilterPeriode get currentPeriode => _currentPeriode;
  double get totalPendapatanFilter => _totalPendapatanFilter;
  int get totalTransaksiFilter => _totalTransaksiFilter;
  String get metodePembayaran => _metodePembayaran;

  double get currentOrderTotal {
    return _currentOrderDetails.fold(0, (sum, item) => sum + item.subtotal);
  }

  void setMetodePembayaran(String metode) {
    _metodePembayaran = metode;
    notifyListeners();
  }

  Future<void> loadOrdersByDate(DateTime date) async {
    _isLoading = true;
    notifyListeners();

    try {
      _orders = await SupabaseService.getOrdersByDate(date);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDashboardData() async {
    await loadDashboardDataByPeriode(FilterPeriode.harian);
  }

  Future<void> loadDashboardDataByPeriode(FilterPeriode periode) async {
    _isLoading = true;
    _currentPeriode = periode;
    notifyListeners();

    try {
      final now = DateTime.now();
      DateTime startDate;
      DateTime endDate = now;

      switch (periode) {
        case FilterPeriode.harian:
          startDate = DateTime(now.year, now.month, now.day);
          endDate = startDate.add(const Duration(days: 1));
          break;
        case FilterPeriode.mingguan:
          final weekday = now.weekday;
          startDate = now.subtract(Duration(days: weekday - 1));
          startDate = DateTime(startDate.year, startDate.month, startDate.day);
          break;
        case FilterPeriode.bulanan:
          startDate = DateTime(now.year, now.month, 1);
          break;
        case FilterPeriode.tahunan:
          startDate = DateTime(now.year, 1, 1);
          break;
      }

      final allOrders = await SupabaseService.getAllOrders();
      
      final filteredOrders = allOrders.where((order) {
        return order.tanggal.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
               order.tanggal.isBefore(endDate.add(const Duration(days: 1)));
      }).toList();

      _totalPendapatanFilter = filteredOrders.fold(0, (sum, o) => sum + o.totalHarga);
      _totalTransaksiFilter = filteredOrders.length;
      
      _bestSellers = await SupabaseService.getBestSellersByDateRange(startDate, endDate);
      
      _totalTransactionsToday = periode == FilterPeriode.harian 
          ? _totalPendapatanFilter 
          : await SupabaseService.getTotalTransactionsToday();

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addToCurrentOrder(OrderDetailModel detail) {
    final existingIndex = _currentOrderDetails.indexWhere(
      (d) => d.idMenu == detail.idMenu,
    );

    if (existingIndex != -1) {
      final existing = _currentOrderDetails[existingIndex];
      _currentOrderDetails[existingIndex] = OrderDetailModel(
        id: existing.id,
        idOrder: existing.idOrder,
        idMenu: existing.idMenu,
        jumlah: existing.jumlah + detail.jumlah,
        subtotal: existing.subtotal + detail.subtotal,
        menu: existing.menu,
      );
    } else {
      _currentOrderDetails.add(detail);
    }
    notifyListeners();
  }

  void removeFromCurrentOrder(String menuId) {
    _currentOrderDetails.removeWhere((d) => d.idMenu == menuId);
    notifyListeners();
  }

  void incrementQuantity(String menuId) {
    final index = _currentOrderDetails.indexWhere((d) => d.idMenu == menuId);
    if (index != -1) {
      final item = _currentOrderDetails[index];
      final harga = item.subtotal / item.jumlah; // harga satuan
      _currentOrderDetails[index] = OrderDetailModel(
        id: item.id,
        idOrder: item.idOrder,
        idMenu: item.idMenu,
        jumlah: item.jumlah + 1,
        subtotal: item.subtotal + harga,
        menu: item.menu,
      );
      notifyListeners();
    }
  }

  void decrementQuantity(String menuId) {
    final index = _currentOrderDetails.indexWhere((d) => d.idMenu == menuId);
    if (index != -1) {
      final item = _currentOrderDetails[index];
      if (item.jumlah <= 1) {
        removeFromCurrentOrder(menuId);
        return;
      }
      
      final harga = item.subtotal / item.jumlah;
      _currentOrderDetails[index] = OrderDetailModel(
        id: item.id,
        idOrder: item.idOrder,
        idMenu: item.idMenu,
        jumlah: item.jumlah - 1,
        subtotal: item.subtotal - harga,
        menu: item.menu,
      );
      notifyListeners();
    }
  }

  void updateQuantity(String menuId, int newQuantity, double harga) {
    final index = _currentOrderDetails.indexWhere((d) => d.idMenu == menuId);
    if (index != -1) {
      final item = _currentOrderDetails[index];
      _currentOrderDetails[index] = OrderDetailModel(
        id: item.id,
        idOrder: item.idOrder,
        idMenu: item.idMenu,
        jumlah: newQuantity,
        subtotal: harga * newQuantity,
        menu: item.menu,
      );
      notifyListeners();
    }
  }

  void clearCurrentOrder() {
    _currentOrderDetails.clear();
    _metodePembayaran = 'tunai';
    notifyListeners();
  }

  Future<bool> createOrder(String userId) async {
    if (_currentOrderDetails.isEmpty) return false;

    _isLoading = true;
    notifyListeners();

    try {
      final order = OrderModel(
        id: '',
        tanggal: DateTime.now(),
        totalHarga: currentOrderTotal,
        idUser: userId,
        metodePembayaran: _metodePembayaran,
      );

      await SupabaseService.createOrder(order, _currentOrderDetails);
      
      clearCurrentOrder();
      await loadDashboardData();
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}