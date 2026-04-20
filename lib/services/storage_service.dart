import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';
  static const String _userEmailKey = 'user_email';
  static const String _userRoleKey = 'user_role';
  static const String _userNameKey = 'user_name';

  static Future<void> saveUserData({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String email,
    required String role,
    required String fullName,
  }) async {
    print('=== MENYIMPAN KE STORAGE ===');
    print('role yang disimpan: $role');
    
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    await _storage.write(key: _userIdKey, value: userId);
    await _storage.write(key: _userEmailKey, value: email);
    await _storage.write(key: _userRoleKey, value: role); // PASTIKAN ROLE TERSIMPAN
    await _storage.write(key: _userNameKey, value: fullName);
    
    print('✅ Data tersimpan');
  }

  static Future<Map<String, String?>> getUserData() async {
    final data = {
      'user_id': await _storage.read(key: _userIdKey),
      'email': await _storage.read(key: _userEmailKey),
      'role': await _storage.read(key: _userRoleKey), // BISA NULL KALAU BELUM LOGIN
      'full_name': await _storage.read(key: _userNameKey),
      'access_token': await _storage.read(key: _accessTokenKey),
      'refresh_token': await _storage.read(key: _refreshTokenKey),
    };
    
    print('=== MEMBACA DARI STORAGE ===');
    print('role yang dibaca: ${data['role']}');
    
    return data;
  }

  static Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: _accessTokenKey);
    return token != null && token.isNotEmpty;
  }

  static Future<void> clearAll() async {
    await _storage.deleteAll();
    print('=== STORAGE DIHAPUS ===');
  }
}