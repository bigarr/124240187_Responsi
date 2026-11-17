import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../views/auth/login_view.dart';
import '../views/home/home_view.dart';

class AuthController extends GetxController {
  final RxBool isLoggedIn = false.obs;
  final RxBool isLoading = false.obs;
  final Rxn<UserModel> currentUser = Rxn<UserModel>();

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  /// Memeriksa status login saat aplikasi dimulai
  Future<void> checkLoginStatus() async {
    isLoggedIn.value = await AuthService.checkIsLoggedIn();
    if (isLoggedIn.value) {
      currentUser.value = await AuthService.getCurrentUser();
    }
  }

  /// Login user menggunakan Local Database Hive dan SharedPreferences
  Future<bool> login(String username, String password) async {
    if (username.trim().isEmpty || password.trim().isEmpty) {
      Get.snackbar(
        'Peringatan',
        'Username dan password tidak boleh kosong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.amber.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
      );
      return false;
    }

    isLoading.value = true;
    try {
      final user = await AuthService.login(
        username: username,
        password: password,
      );

      if (user != null) {
        currentUser.value = user;
        isLoggedIn.value = true;
        Get.snackbar(
          'Login Berhasil',
          'Selamat datang kembali, ${user.fullName.isNotEmpty ? user.fullName : user.username}!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade700,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
          duration: const Duration(seconds: 2),
        );
        Get.offAll(() => const HomeView());
        return true;
      } else {
        Get.snackbar(
          'Login Gagal',
          'Username atau password salah. Silakan coba lagi.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          icon: const Icon(Icons.error_outline, color: Colors.white),
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Terjadi Kesalahan',
        'Error: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Registrasi user baru ke Local Database Hive
  Future<bool> register({
    required String fullName,
    required String username,
    required String password,
    required String confirmPassword,
  }) async {
    if (fullName.trim().isEmpty ||
        username.trim().isEmpty ||
        password.trim().isEmpty ||
        confirmPassword.trim().isEmpty) {
      Get.snackbar(
        'Peringatan',
        'Semua kolom wajib diisi!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.amber.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
      );
      return false;
    }

    if (password != confirmPassword) {
      Get.snackbar(
        'Peringatan',
        'Konfirmasi password tidak cocok!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.amber.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.lock_outline, color: Colors.white),
      );
      return false;
    }

    if (password.length < 6) {
      Get.snackbar(
        'Peringatan',
        'Password minimal 6 karakter!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.amber.shade800,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.info_outline, color: Colors.white),
      );
      return false;
    }

    isLoading.value = true;
    try {
      final success = await AuthService.register(
        username: username,
        password: password,
        fullName: fullName,
      );

      if (success) {
        Get.snackbar(
          'Registrasi Berhasil',
          'Akun berhasil dibuat di Local Database. Silakan login!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade700,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
          duration: const Duration(seconds: 3),
        );
        Get.off(() => const LoginView());
        return true;
      } else {
        Get.snackbar(
          'Registrasi Gagal',
          'Username "$username" sudah terdaftar. Gunakan username lain.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade700,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          icon: const Icon(Icons.cancel_outlined, color: Colors.white),
        );
        return false;
      }
    } catch (e) {
      Get.snackbar(
        'Terjadi Kesalahan',
        'Gagal mendaftar: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
      );
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  /// Logout dari aplikasi dan bersihkan sesi di SharedPreferences
  Future<void> logout() async {
    await AuthService.logout();
    currentUser.value = null;
    isLoggedIn.value = false;
    Get.snackbar(
      'Logout',
      'Anda telah berhasil keluar dari akun',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blueGrey.shade800,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
    Get.offAll(() => const LoginView());
  }
}
