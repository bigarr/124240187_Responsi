import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static const String userBoxName = 'users';
  static const String keyIsLoggedIn = 'isLoggedIn';
  static const String keyUsername = 'loggedInUsername';
  static const String keyFullName = 'loggedInFullName';

  /// Inisialisasi awal database Hive untuk users
  static Future<void> init() async {
    if (!Hive.isBoxOpen(userBoxName)) {
      await Hive.openBox(userBoxName);
    }
  }

  /// Mendaftarkan user baru ke Hive Local Database
  static Future<bool> register({
    required String username,
    required String password,
    required String fullName,
  }) async {
    final box = Hive.isBoxOpen(userBoxName)
        ? Hive.box(userBoxName)
        : await Hive.openBox(userBoxName);

    final cleanUsername = username.trim().toLowerCase();

    if (box.containsKey(cleanUsername)) {
      return false; // Username sudah terdaftar
    }

    final newUser = UserModel(
      username: cleanUsername,
      password: password,
      fullName: fullName.trim(),
    );

    await box.put(cleanUsername, newUser.toMap());
    return true;
  }

  /// Melakukan login dengan memeriksa data di Hive dan menyimpan sesi ke SharedPreferences
  static Future<UserModel?> login({
    required String username,
    required String password,
  }) async {
    final box = Hive.isBoxOpen(userBoxName)
        ? Hive.box(userBoxName)
        : await Hive.openBox(userBoxName);

    final cleanUsername = username.trim().toLowerCase();

    if (!box.containsKey(cleanUsername)) {
      return null;
    }

    final userData = box.get(cleanUsername);
    if (userData is Map) {
      final user = UserModel.fromMap(userData);
      if (user.password == password) {
        // Simpan sesi aktif ke Shared Preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(keyIsLoggedIn, true);
        await prefs.setString(keyUsername, user.username);
        await prefs.setString(keyFullName, user.fullName);
        return user;
      }
    }

    return null;
  }

  /// Logout: menghapus sesi aktif dari SharedPreferences
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyIsLoggedIn, false);
    await prefs.remove(keyUsername);
    await prefs.remove(keyFullName);
  }

  /// Cek status login dari SharedPreferences
  static Future<bool> checkIsLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyIsLoggedIn) ?? false;
  }

  /// Mendapatkan data user yang sedang login saat ini
  static Future<UserModel?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(keyIsLoggedIn) ?? false;
    if (!isLoggedIn) return null;

    final username = prefs.getString(keyUsername) ?? '';
    final fullName = prefs.getString(keyFullName) ?? '';
    return UserModel(username: username, password: '', fullName: fullName);
  }
}
