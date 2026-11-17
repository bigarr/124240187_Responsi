import 'package:hive/hive.dart';
import '../models/article_model.dart';

class BookmarkService {
  static const String boxName = 'bookmarks';

  /// Inisialisasi awal box bookmark di Hive
  static Future<void> init() async {
    if (!Hive.isBoxOpen(boxName)) {
      await Hive.openBox(boxName);
    }
  }

  /// Memuat semua artikel yang dibookmark dari Local Database (Hive)
  static Future<List<ArticleModel>> loadBookmarks() async {
    final box = Hive.isBoxOpen(boxName)
        ? Hive.box(boxName)
        : await Hive.openBox(boxName);

    final List<ArticleModel> list = [];
    for (var val in box.values) {
      if (val is Map) {
        list.add(ArticleModel.fromJson(Map<String, dynamic>.from(val)));
      }
    }
    // Urutkan artikel bookmark yang baru ditambahkan di atas jika perlu, atau reverse
    return list.reversed.toList();
  }

  /// Menyimpan artikel ke Local Database (Hive)
  static Future<void> saveBookmark(ArticleModel article) async {
    final box = Hive.isBoxOpen(boxName)
        ? Hive.box(boxName)
        : await Hive.openBox(boxName);
    await box.put(article.id.toString(), article.toJson());
  }

  /// Menghapus artikel dari Local Database (Hive)
  static Future<void> removeBookmark(int id) async {
    final box = Hive.isBoxOpen(boxName)
        ? Hive.box(boxName)
        : await Hive.openBox(boxName);
    await box.delete(id.toString());
  }

  /// Memeriksa apakah suatu artikel ada di dalam bookmark database
  static Future<bool> isBookmarked(int id) async {
    final box = Hive.isBoxOpen(boxName)
        ? Hive.box(boxName)
        : await Hive.openBox(boxName);
    return box.containsKey(id.toString());
  }
}
