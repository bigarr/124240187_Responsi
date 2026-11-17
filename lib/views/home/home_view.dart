import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/article_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/article_model.dart';
import '../../utils/app_theme.dart';
import '../bookmark/bookmark_view.dart';
import '../detail/detail_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final ArticleController articleController = Get.put(ArticleController());
    final AuthController authController = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());

    return Scaffold(
      appBar: AppBar(
        // Requirement 2: Pada title AppBar, tampilkan username pengguna yang sedang login
        title: Obx(() {
          final username = authController.currentUser.value?.username ?? 'Pengguna';
          return Row(
            children: [
              CircleAvatar(
                radius: 17,
                backgroundColor: AppTheme.primary,
                child: Text(
                  username.isNotEmpty ? username[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const Text(
                      'SpaceNews Explorer',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppTheme.accent,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
        actions: [
          // Requirement 2: Sediakan button pada bagian kanan AppBar yang mengarah ke halaman Bookmark
          Obx(() {
            final count = articleController.bookmarkList.length;
            return Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  tooltip: 'Halaman Bookmark',
                  icon: const Icon(Icons.bookmarks_rounded, size: 24),
                  onPressed: () => Get.to(() => const BookmarkView()),
                ),
                if (count > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppTheme.secondary,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '$count',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            );
          }),

          // Tombol Logout
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout_rounded, size: 22),
            onPressed: () {
              Get.defaultDialog(
                title: 'Konfirmasi Logout',
                titleStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                middleText: 'Apakah Anda yakin ingin keluar dari akun?',
                textConfirm: 'Keluar',
                textCancel: 'Batal',
                confirmTextColor: Colors.white,
                buttonColor: Colors.red.shade700,
                onConfirm: () {
                  Get.back();
                  authController.logout();
                },
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Requirement 5: Fitur Filter Berita berdasarkan sumber publikasi (news site)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            color: AppTheme.surface.withValues(alpha: 0.5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: Row(
                    children: [
                      Icon(Icons.filter_list_rounded, size: 16, color: AppTheme.accent),
                      SizedBox(width: 6),
                      Text(
                        'Filter Sumber Berita (News Site):',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 42,
                  child: Obx(() {
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: articleController.newsSites.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final site = articleController.newsSites[index];
                        final isSelected = articleController.selectedNewsSite.value == site;

                        return ChoiceChip(
                          label: Text(site == 'All' ? 'Semua Sumber' : site),
                          selected: isSelected,
                          selectedColor: AppTheme.primary,
                          backgroundColor: AppTheme.surfaceLight,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : AppTheme.textSecondary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: isSelected ? AppTheme.primary : AppTheme.cardBorder,
                            ),
                          ),
                          onSelected: (selected) {
                            if (selected) {
                              articleController.setNewsSiteFilter(site);
                            }
                          },
                        );
                      },
                    );
                  }),
                ),
              ],
            ),
          ),

          // Content List with Loading & Error Indicator (Requirement 2)
          Expanded(
            child: Obx(() {
              // Tampilkan loading indicator ketika data sedang dimuat
              if (articleController.isLoading.value) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppTheme.primary),
                      SizedBox(height: 16),
                      Text(
                        'Memuat berita luar angkasa...',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                );
              }

              // Error State
              if (articleController.errorMessage.value.isNotEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.cloud_off_rounded,
                          size: 60,
                          color: Colors.redAccent,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          articleController.errorMessage.value,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => articleController.fetchArticles(),
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Empty State
              if (articleController.articleList.isEmpty) {
                return const Center(
                  child: Text(
                    'Tidak ada berita yang ditemukan.',
                    style: TextStyle(color: AppTheme.textSecondary),
                  ),
                );
              }

              // Menampilkan daftar berita (Minimal 10 berita)
              return RefreshIndicator(
                onRefresh: () async {
                  await articleController.fetchArticles();
                },
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: articleController.articleList.length,
                  itemBuilder: (context, index) {
                    final ArticleModel article = articleController.articleList[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () {
                          Get.to(() => DetailView(article: article));
                        },
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Gambar Berita
                            Hero(
                              tag: 'article_image_${article.id}',
                              child: SizedBox(
                                height: 180,
                                width: double.infinity,
                                child: article.imageUrl.isNotEmpty
                                    ? Image.network(
                                        article.imageUrl,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, progress) {
                                          if (progress == null) return child;
                                          return Container(
                                            color: AppTheme.surfaceLight,
                                            child: const Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: AppTheme.primary,
                                              ),
                                            ),
                                          );
                                        },
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            color: AppTheme.surfaceLight,
                                            child: const Center(
                                              child: Icon(
                                                Icons.satellite_alt_rounded,
                                                color: AppTheme.accent,
                                                size: 48,
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                    : Container(
                                        color: AppTheme.surfaceLight,
                                        child: const Center(
                                          child: Icon(
                                            Icons.satellite_alt_rounded,
                                            color: AppTheme.accent,
                                            size: 48,
                                          ),
                                        ),
                                      ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // 2. Sumber Berita (News Site) & Tanggal Publikasi
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primary.withValues(alpha: 0.2),
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: AppTheme.primary, width: 0.8),
                                        ),
                                        child: Text(
                                          article.newsSite,
                                          style: const TextStyle(
                                            color: AppTheme.accent,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      const Icon(
                                        Icons.calendar_today_outlined,
                                        size: 13,
                                        color: AppTheme.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        article.formattedDate,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  // 3. Judul Berita
                                  Text(
                                    article.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: AppTheme.textPrimary,
                                      height: 1.3,
                                    ),
                                  ),
                                  const SizedBox(height: 8),

                                  // Ringkasan singkat
                                  Text(
                                    article.summary,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppTheme.textSecondary,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
