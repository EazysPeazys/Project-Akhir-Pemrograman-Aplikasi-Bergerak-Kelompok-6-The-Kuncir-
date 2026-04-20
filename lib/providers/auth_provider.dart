import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/supabase_service.dart';
import '../services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;
  bool _isReady = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isReady => _isReady;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  
  bool get isManager {
    final role = _currentUser?.role?.toLowerCase().trim();
    print('Checking isManager: role="$role"');
    return role == 'manager';
  }
  
  bool get isKasir {
    final role = _currentUser?.role?.toLowerCase().trim();
    print('Checking isKasir: role="$role"');
    return role == 'kasir';
  }

  AuthProvider() {
    _init();
  }

  void _init() async {
    await _checkStorage();
  }

  Future<void> _checkStorage() async {
    try {
      final isLoggedIn = await StorageService.isLoggedIn();
      print('=== CHECK STORAGE ===');
      print('isLoggedIn: $isLoggedIn');
      
      if (isLoggedIn) {
        final data = await StorageService.getUserData();
        
        final storedRole = data['role'];
        print('Stored role: "$storedRole"');
        
        if (data['user_id'] != null && storedRole != null) {
          _currentUser = UserModel(
            id: data['user_id']!,
            email: data['email'] ?? '',
            fullName: data['full_name'] ?? '',
            role: storedRole,
            createdAt: DateTime.now(),
          );
          
          print('=== USER RESTORED ===');
          print('Role: ${_currentUser?.role}');
          print('isManager: $isManager');
          print('isKasir: $isKasir');
        } else {
          print('❌ Data tidak lengkap, logout...');
          await logout();
        }
      }
    } catch (e) {
      print('❌ Storage error: $e');
    } finally {
      _isReady = true;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await SupabaseService.signIn(email, password);
      
      if (response.user != null && response.session != null) {
        final metadata = response.user!.userMetadata;
        print('=== USER METADATA ===');
        print('full metadata: $metadata');
        
        final roleFromMetadata = metadata?['role'] as String?;
        print('role dari metadata: "$roleFromMetadata"');
        
        final actualRole = (roleFromMetadata ?? 'kasir').trim().toLowerCase();
        print('actualRole setelah trim: "$actualRole"');

        await StorageService.saveUserData(
          accessToken: response.session!.accessToken,
          refreshToken: response.session!.refreshToken ?? '',
          userId: response.user!.id,
          email: response.user!.email!,
          role: actualRole,
          fullName: metadata?['full_name'] ?? '',
        );

        final profile = await SupabaseService.getCurrentUserProfile();
        
        if (profile != null) {
          _currentUser = profile;
          print('=== PROFILE DARI DATABASE ===');
          print('role: ${_currentUser?.role}');
        } else {
          // Fallback
          _currentUser = UserModel(
            id: response.user!.id,
            email: response.user!.email!,
            fullName: metadata?['full_name'] ?? '',
            role: actualRole,
            createdAt: DateTime.now(),
          );
        }
        
        print('=== LOGIN SUCCESS ===');
        print('Final role: ${_currentUser?.role}');
        print('isManager: $isManager');
        print('isKasir: $isKasir');
        
        return true;
      }
      return false;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      print('❌ Login error: $e');
      _error = 'Terjadi kesalahan. Silakan coba lagi.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String email, String password, String fullName, String role) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await SupabaseService.signUp(email, password, {
        'full_name': fullName,
        'role': role,
      });
      return true;
    } on AuthException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Terjadi kesalahan. Silakan coba lagi.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await SupabaseService.signOut();
    await StorageService.clearAll();
    _currentUser = null;
    notifyListeners();
  }

  void clearUserSilent() {
    _currentUser = null;
    _isLoading = false;
    _error = null;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}