import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'controllers/auth_controller.dart';
import 'services/auth_service.dart';
import 'services/bookmark_service.dart';
import 'utils/app_theme.dart';
import 'views/auth/login_view.dart';
import 'views/home/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Inisialisasi Hive Local Database
  await Hive.initFlutter();

  // 2. Inisialisasi Box Database
  await AuthService.init();
  await BookmarkService.init();

  // 3. Inisialisasi AuthController
  final authController = Get.put(AuthController());
  await authController.checkLoginStatus();

  final bool isLoggedIn = authController.isLoggedIn.value;

  runApp(SpaceNewsExplorerApp(isLoggedIn: isLoggedIn));
}

class SpaceNewsExplorerApp extends StatelessWidget {
  final bool isLoggedIn;

  const SpaceNewsExplorerApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SpaceNews Explorer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: isLoggedIn ? const HomeView() : const LoginView(),
    );
  }
}
