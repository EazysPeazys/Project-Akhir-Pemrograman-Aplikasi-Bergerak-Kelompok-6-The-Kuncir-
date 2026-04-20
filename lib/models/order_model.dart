import 'menu_model.dart';

enum MetodePembayaran { qris, tunai, transfer }

class OrderModel {
  final String id;
  final DateTime tanggal;
  final double totalHarga;
  final String idUser;
  final String? userName;
  final List<OrderDetailModel>? details;
  final String metodePembayaran;

  OrderModel({
    required this.id,
    required this.tanggal,
    required this.totalHarga,
    required this.idUser,
    this.userName,
    this.details,
    this.metodePembayaran = 'tunai',
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] ?? '',
      tanggal: DateTime.parse(json['tanggal']),
      totalHarga: (json['total_harga'] as num).toDouble(),
      idUser: json['id_user'],
      userName: json['users']?['full_name'],
      details: json['order_details'] != null
          ? (json['order_details'] as List)
              .map((e) => OrderDetailModel.fromJson(e))
              .toList()
          : null,
      metodePembayaran: json['metode_pembayaran'] ?? 'tunai',
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'tanggal': tanggal.toIso8601String(),
      'total_harga': totalHarga,
      'id_user': idUser,
      'metode_pembayaran': metodePembayaran,
    };
    
    if (id.isNotEmpty) {
      json['id'] = id;
    }
    
    return json;
  }
}

class OrderDetailModel {
  final String id;
  final String idOrder;
  final String idMenu;
  final int jumlah;
  final double subtotal;
  final MenuModel? menu;

  OrderDetailModel({
    required this.id,
    required this.idOrder,
    required this.idMenu,
    required this.jumlah,
    required this.subtotal,
    this.menu,
  });

  factory OrderDetailModel.fromJson(Map<String, dynamic> json) {
    return OrderDetailModel(
      id: json['id'] ?? '',
      idOrder: json['id_order'] ?? '',
      idMenu: json['id_menu'],
      jumlah: json['jumlah'],
      subtotal: (json['subtotal'] as num).toDouble(),
      menu: json['menu'] != null ? MenuModel.fromJson(json['menu']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'id_order': idOrder,
      'id_menu': idMenu,
      'jumlah': jumlah,
      'subtotal': subtotal,
    };
    
    if (id.isNotEmpty) {
      json['id'] = id;
    }
    
    return json;
  }
}