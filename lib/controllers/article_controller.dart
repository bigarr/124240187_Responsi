import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/article_model.dart';
import '../services/api_service.dart';
import '../services/bookmark_service.dart';

class ArticleController extends GetxController {
  final RxList<ArticleModel> articleList = <ArticleModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Filter news site (Requirement 5)
  final RxString selectedNewsSite = 'All'.obs;
  final RxList<String> newsSites = <String>['All'].obs;

  // Bookmarks (Stored in Local Database Hive - Requirement 4)
  final RxList<ArticleModel> bookmarkList = <ArticleModel>[].obs;
  final RxSet<int> bookmarkIds = <int>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadBookmarks();
    fetchArticles();
  }

  /// Memuat daftar bookmark dari Local Database (Hive)
  Future<void> loadBookmarks() async {
    try {
      final bookmarks = await BookmarkService.loadBookmarks();
      bookmarkList.assignAll(bookmarks);
      bookmarkIds.assignAll(bookmarks.map((a) => a.id));
    } catch (e) {
      debugPrint('Error loading bookmarks: $e');
    }
  }

  /// Mengambil daftar artikel dari Spaceflight News API (Minimal 10 berita - Requirement 2)
  Future<void> fetchArticles() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final results = await ApiService.getArticles(
        newsSite: selectedNewsSite.value == 'All' ? null : selectedNewsSite.value,
      );

      articleList.assignAll(results);

      // Kumpulkan daftar news site unik untuk filter (Requirement 5)
      final sitesSet = <String>{'All'};
      for (final a in results) {
        if (a.newsSite.isNotEmpty) {
          sitesSet.add(a.newsSite);
        }
      }
      // Gabungkan dengan daftar yang sudah ada sebelumnya agar opsi filter tidak hilang jika berganti
      for (final site in newsSites) {
        sitesSet.add(site);
      }
      final sortedSites = sitesSet.toList();
      sortedSites.sort((a, b) {
        if (a == 'All') return -1;
        if (b == 'All') return 1;
        return a.compareTo(b);
      });
      newsSites.assignAll(sortedSites);
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  /// Mengubah filter news site (Requirement 5)
  void setNewsSiteFilter(String site) {
    if (selectedNewsSite.value != site) {
      selectedNewsSite.value = site;
      fetchArticles();
    }
  }

  /// Cek apakah suatu artikel ada di daftar bookmark
  bool isBookmarked(int id) {
    return bookmarkIds.contains(id);
  }

  /// Toggle bookmark artikel (Tambah / Hapus) - Requirement 3
  /// - Apabila menambahkan: icon berubah warna & menampilkan snackbar hijau
  /// - Apabila diklik untuk menghapus: icon kembali seperti semula & menampilkan snackbar merah
  Future<void> toggleBookmark(ArticleModel article) async {
    final alreadyBookmarked = isBookmarked(article.id);

    if (alreadyBookmarked) {
      bookmarkList.removeWhere((item) => item.id == article.id);
      bookmarkIds.remove(article.id);
      await BookmarkService.removeBookmark(article.id);

      // Snackbar Merah (Requirement 3)
      Get.rawSnackbar(
        title: 'Bookmark Dihapus',
        message: 'Berita "${article.title}" telah dihapus dari bookmark.',
        backgroundColor: Colors.red.shade700,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.bookmark_remove_rounded, color: Colors.white),
        duration: const Duration(seconds: 2),
      );
    } else {
      bookmarkList.insert(0, article);
      bookmarkIds.add(article.id);
      await BookmarkService.saveBookmark(article);

      // Snackbar Hijau (Requirement 3)
      Get.rawSnackbar(
        title: 'Bookmark Ditambahkan',
        message: 'Berita "${article.title}" berhasil disimpan ke bookmark.',
        backgroundColor: Colors.green.shade700,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        icon: const Icon(Icons.bookmark_added_rounded, color: Colors.white),
        duration: const Duration(seconds: 2),
      );
    }
  }

  /// Hapus bookmark saat di-swipe di Halaman Bookmark (Requirement 4)
  Future<void> removeBookmarkBySwipe(ArticleModel article) async {
    bookmarkList.removeWhere((item) => item.id == article.id);
    bookmarkIds.remove(article.id);
    await BookmarkService.removeBookmark(article.id);

    // Snackbar Merah saat menghapus dari daftar bookmark
    Get.rawSnackbar(
      title: 'Bookmark Dihapus',
      message: 'Berita "${article.title}" telah dihapus dari bookmark.',
      backgroundColor: Colors.red.shade700,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      icon: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      duration: const Duration(seconds: 2),
    );
  }
}
