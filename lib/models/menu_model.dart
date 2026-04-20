class MenuModel {
  final String id;
  final String namaMenu;
  final double harga;
  final String kategori;
  final String? gambarUrl;
  final DateTime createdAt;
  final bool isActive;

  MenuModel({
    required this.id,
    required this.namaMenu,
    required this.harga,
    required this.kategori,
    this.gambarUrl,
    required this.createdAt,
    this.isActive = true,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      id: json['id'],
      namaMenu: json['nama_menu'],
      harga: (json['harga'] as num).toDouble(),
      kategori: json['kategori'],
      gambarUrl: json['gambar_url'],
      createdAt: DateTime.parse(json['created_at']),
      isActive: json['is_active'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_menu': namaMenu,
      'harga': harga,
      'kategori': kategori,
      'gambar_url': gambarUrl,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive,
    };
  }
}