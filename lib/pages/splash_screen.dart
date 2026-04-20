import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import 'login_page.dart';
import 'dashboard_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), _checkAndNavigate);
  }

  void _checkAndNavigate() {
    if (!mounted) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);

    if (!auth.isReady) {
      Future.delayed(const Duration(milliseconds: 300), _checkAndNavigate);
      return;
    }

    if (!mounted) return;

    print('=== NAVIGASI DARI SPLASH ===');
    print('isAuthenticated: ${auth.isAuthenticated}');
    print('currentUser: ${auth.currentUser?.email}');
    print('role: ${auth.currentUser?.role}');
    print('isManager: ${auth.isManager}');
    print('isKasir: ${auth.isKasir}');

    if (auth.isAuthenticated) {
      if (auth.isManager) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
      } else if (auth.isKasir) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const DashboardPage()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'PANASEA',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'COFFEE ORDER',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                letterSpacing: 8,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}