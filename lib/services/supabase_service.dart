import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../models/menu_model.dart';
import '../models/order_model.dart';
import '../utils/helpers.dart';

class SupabaseService {
  static final SupabaseClient _supabase = Supabase.instance.client;

  
  static Future<AuthResponse> signIn(String email, String password) async {
    return await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<AuthResponse> signUp(String email, String password, Map<String, dynamic> userData) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: userData,
    );
    
    if (response.user != null) {
      await _supabase.from('users').insert({
        'id': response.user!.id,
        'email': email,
        'full_name': userData['full_name'],
        'role': userData['role'],
      });
    }
    
    return response;
  }

  static Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  static User? get currentUser => _supabase.auth.currentUser;
  static Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;
  
  static Future<bool> changePassword(String currentPassword, String newPassword) async {
    try {
      final user = currentUser;
      if (user == null) {
        throw Exception('User tidak login');
      }
      
      try {
        await _supabase.auth.signInWithPassword(
          email: user.email!,
          password: currentPassword,
        );
      } catch (e) {
        throw Exception('Password lama tidak benar');
      }
      
      await _supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      
      return true;
    } catch (e) {
      print('changePassword error: $e');
      throw Exception('Gagal ganti password: $e');
    }
  }
  
  static Future<UserModel?> getCurrentUserProfile() async {
    final user = currentUser;
    if (user == null) return null;

    final response = await _supabase
        .from('users')
        .select()
        .eq('id', user.id)
        .single();

    return UserModel.fromJson(response);
  }

  static Future<List<UserModel>> getAllUsers() async {
    final response = await _supabase
        .from('users')
        .select()
        .order('created_at', ascending: false);

    return (response as List).map((e) => UserModel.fromJson(e)).toList();
  }

  static Future<void> createUser(String email, String password, String fullName, String role) async {
    await signUp(email, password, {
      'full_name': fullName,
      'role': role,
    });
  }

  static Future<void> deleteUser(String userId) async {
    await _supabase.from('users').delete().eq('id', userId);
  }
  
  static Future<List<MenuModel>> getAllMenus() async {
    try {
      final response = await _supabase
          .from('menu')
          .select()
          .eq('is_active', true)
          .order('created_at', ascending: false);
      
      return (response as List).map((e) => MenuModel.fromJson(e)).toList();
    } catch (e) {
      throw e;
    }
  }

  static Future<MenuModel> createMenu(MenuModel menu) async {
    try {
      final data = {
        'nama_menu': menu.namaMenu,
        'harga': menu.harga,
        'kategori': menu.kategori,
        'gambar_url': menu.gambarUrl,
        'is_active': true,
      };
      
      final response = await _supabase
          .from('menu')
          .insert(data)
          .select()
          .single();

      return MenuModel.fromJson(response);
    } catch (e) {
      throw e;
    }
  }

  static Future<MenuModel> updateMenu(MenuModel menu) async {
    try {
      final response = await _supabase
          .from('menu')
          .update({
            'nama_menu': menu.namaMenu,
            'harga': menu.harga,
            'kategori': menu.kategori,
            'gambar_url': menu.gambarUrl,
          })
          .eq('id', menu.id)
          .select()
          .single();

      return MenuModel.fromJson(response);
    } catch (e) {
      throw e;
    }
  }

  static Future<void> deleteMenu(String id) async {
    try {
      await _supabase
          .from('menu')
          .update({'is_active': false})
          .eq('id', id);
    } catch (e) {
      throw e;
    }
  }
  
  static Future<OrderModel> createOrder(OrderModel order, List<OrderDetailModel> details) async {
    try {
      final orderData = {
        'tanggal': order.tanggal.toIso8601String(),
        'total_harga': order.totalHarga,
        'id_user': order.idUser,
        'metode_pembayaran': order.metodePembayaran,
      };
      
      print('=== INSERT ORDER ===');
      print('Data: $orderData');

      final orderResponse = await _supabase
          .from('orders')
          .insert(orderData)
          .select()
          .single();

      print('Order created: ${orderResponse['id']}');

      final createdOrder = OrderModel.fromJson(orderResponse);

      final detailsWithOrderId = details.map((d) => {
        'id_order': createdOrder.id,
        'id_menu': d.idMenu,
        'jumlah': d.jumlah,
        'subtotal': d.subtotal,
      }).toList();

      print('=== INSERT DETAILS ===');
      print('Count: ${detailsWithOrderId.length}');

      await _supabase.from('order_details').insert(detailsWithOrderId);

      return createdOrder;
    } catch (e) {
      print('createOrder error: $e');
      throw Exception('Gagal membuat pesanan: $e');
    }
  }

  static Future<List<OrderModel>> getOrdersByDate(DateTime date) async {
    final start = Helpers.getStartOfDay(date);
    final end = Helpers.getEndOfDay(date);

    final response = await _supabase
        .from('orders')
        .select('''
          *,
          users: id_user (full_name),
          order_details (
            *,
            menu: id_menu (*)
          )
        ''')
        .gte('tanggal', start.toIso8601String())
        .lte('tanggal', end.toIso8601String())
        .order('tanggal', ascending: false);

    return (response as List).map((e) => OrderModel.fromJson(e)).toList();
  }

  static Future<List<OrderModel>> getAllOrders() async {
    final response = await _supabase
        .from('orders')
        .select('''
          *,
          users: id_user (full_name),
          order_details (
            *,
            menu: id_menu (*)
          )
        ''')
        .order('tanggal', ascending: false);

    return (response as List).map((e) => OrderModel.fromJson(e)).toList();
  }

  static Future<double> getTotalTransactionsToday() async {
    final today = DateTime.now();
    final start = Helpers.getStartOfDay(today);
    final end = Helpers.getEndOfDay(today);

    final response = await _supabase
        .from('orders')
        .select('total_harga')
        .gte('tanggal', start.toIso8601String())
        .lte('tanggal', end.toIso8601String());

    double total = 0;
    for (var item in response) {
      total += (item['total_harga'] as num).toDouble();
    }
    return total;
  }

  static Future<Map<String, int>> getBestSellers() async {
    final response = await _supabase
        .from('order_details')
        .select('''
          id_menu,
          jumlah,
          menu: id_menu (nama_menu)
        ''');

    Map<String, int> menuCount = {};
    for (var item in response) {
      final menuName = item['menu']['nama_menu'] as String;
      final jumlah = item['jumlah'] as int;
      menuCount[menuName] = (menuCount[menuName] ?? 0) + jumlah;
    }

    var sortedEntries = menuCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedEntries.take(5));
  }
  
  static Future<List<OrderModel>> getOrdersByDateRange(DateTime start, DateTime end) async {
    final response = await _supabase
        .from('orders')
        .select('''
          *,
          users: id_user (full_name),
          order_details (
            *,
            menu: id_menu (*)
          )
        ''')
        .gte('tanggal', start.toIso8601String())
        .lte('tanggal', end.toIso8601String())
        .order('tanggal', ascending: false);

    return (response as List).map((e) => OrderModel.fromJson(e)).toList();
  }

  static Future<Map<String, int>> getBestSellersByDateRange(DateTime start, DateTime end) async {
    final response = await _supabase
        .from('order_details')
        .select('''
          id_menu,
          jumlah,
          menu: id_menu (nama_menu),
          orders!inner(tanggal)
        ''')
        .gte('orders.tanggal', start.toIso8601String())
        .lte('orders.tanggal', end.toIso8601String());

    Map<String, int> menuCount = {};
    for (var item in response) {
      final menuName = item['menu']['nama_menu'] as String;
      final jumlah = item['jumlah'] as int;
      menuCount[menuName] = (menuCount[menuName] ?? 0) + jumlah;
    }

    var sortedEntries = menuCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Map.fromEntries(sortedEntries.take(5));
  }
}