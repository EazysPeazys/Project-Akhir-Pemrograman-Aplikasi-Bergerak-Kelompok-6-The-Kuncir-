import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/menu_model.dart';
import '../providers/auth_provider.dart';
import '../providers/menu_provider.dart';
import '../utils/constants.dart';
import '../widgets/menu_card.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({super.key});

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MenuProvider>(context, listen: false).loadMenus();
    });
  }

  bool _isValidMenuName(String name) {
    if (name.trim().isEmpty) return false;
    final validPattern = RegExp(r'^[a-zA-Z0-9\s]+$');
    return validPattern.hasMatch(name.trim());
  }

  void _showAddEditMenuDialog(BuildContext context, {MenuModel? menu}) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (!authProvider.isManager) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Hanya manager yang bisa mengedit menu'),
          backgroundColor: AppColors.accent,
        ),
      );
      return;
    }

    final nameController = TextEditingController(text: menu?.namaMenu ?? '');
    final priceController = TextEditingController(
      text: menu != null ? menu.harga.toStringAsFixed(0) : '',
    );
    String selectedCategory = menu?.kategori ?? 'Coffee';

    final categories = ['Coffee', 'Non Coffee', 'Tea', 'Snack'];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.secondary,
        title: Text(
          menu == null ? 'Tambah Menu' : 'Edit Menu',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Nama Menu',
                  hintText: 'Contoh: Kopi Susu, Latte, Es Teh',
                  helperText: 'Hanya huruf, angka, dan spasi',
                  helperStyle: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: const InputDecoration(
                  labelText: 'Harga',
                  prefixText: 'Rp ',
                ),
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setState) => DropdownButtonFormField<String>(
                  value: selectedCategory,
                  dropdownColor: AppColors.secondary,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    labelText: 'Kategori',
                  ),
                  items: categories.map((cat) {
                    return DropdownMenuItem(
                      value: cat,
                      child: Text(cat),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedCategory = value!);
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final scaffoldMessenger = ScaffoldMessenger.of(context);

              if (nameController.text.trim().isEmpty) {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Nama menu wajib diisi'),
                    backgroundColor: AppColors.accent,
                  ),
                );
                return;
              }

              if (!_isValidMenuName(nameController.text)) {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Nama menu hanya boleh huruf, angka, dan spasi',
                    ),
                    backgroundColor: AppColors.accent,
                    duration: Duration(seconds: 3),
                  ),
                );
                return;
              }

              if (priceController.text.trim().isEmpty) {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Harga wajib diisi'),
                    backgroundColor: AppColors.accent,
                  ),
                );
                return;
              }

              final price = double.tryParse(priceController.text.trim());
              if (price == null || price <= 0) {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Harga tidak valid'),
                    backgroundColor: AppColors.accent,
                  ),
                );
                return;
              }

              final menuProvider =
                  Provider.of<MenuProvider>(context, listen: false);

              final newMenu = MenuModel(
                id: menu?.id ?? '',
                namaMenu: nameController.text.trim(),
                harga: price,
                kategori: selectedCategory,
                gambarUrl: null,
                createdAt: DateTime.now(),
              );

              Navigator.pop(dialogContext);

              bool success;
              if (menu == null) {
                success = await menuProvider.addMenu(newMenu);
              } else {
                success = await menuProvider.updateMenu(newMenu);
              }

              if (!mounted) return;

              if (success) {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      menu == null
                          ? 'Menu berhasil ditambahkan!'
                          : 'Menu berhasil diupdate!',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(
                        'Gagal: ${menuProvider.error ?? 'Unknown error'}'),
                    backgroundColor: AppColors.accent,
                  ),
                );
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, MenuModel menu) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.secondary,
        title: const Text(
          'Nonaktifkan Menu?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Menu "${menu.namaMenu}" akan dinonaktifkan dan tidak muncul di daftar menu.\n\nMenu yang sudah pernah dipesan tetap ada di riwayat transaksi.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              
              final menuProvider = Provider.of<MenuProvider>(context, listen: false);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              
              final success = await menuProvider.deleteMenu(menu.id);
              
              if (!mounted) return;
              
              if (success) {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Menu berhasil dinonaktifkan'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(
                        'Gagal: ${menuProvider.error ?? 'Unknown error'}'),
                    backgroundColor: AppColors.accent,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accent,
            ),
            child: const Text('Nonaktifkan'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final menuProvider = Provider.of<MenuProvider>(context);
    final isManager = authProvider.isManager;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Kopi'),
        actions: [
          if (isManager)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddEditMenuDialog(context),
              tooltip: 'Tambah Menu',
            ),
        ],
      ),
      body: menuProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : menuProvider.menus.isEmpty
              ? const Center(
                  child: Text(
                    'Belum ada menu',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: menuProvider.menus.length,
                  itemBuilder: (context, index) {
                    final menu = menuProvider.menus[index];
                    return MenuCard(
                      menu: menu,
                      onEdit: isManager
                          ? () => _showAddEditMenuDialog(context, menu: menu)
                          : null,
                      onDelete: isManager
                          ? () => _showDeleteConfirmDialog(context, menu)
                          : null,
                    );
                  },
                ),
    );
  }
}