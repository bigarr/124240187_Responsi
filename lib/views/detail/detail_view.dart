import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/article_controller.dart';
import '../../models/article_model.dart';
import '../../utils/app_theme.dart';

class DetailView extends StatelessWidget {
  final ArticleModel article;

  const DetailView({super.key, required this.article});

  Future<void> _openFullArticle(BuildContext context) async {
    if (article.url.isEmpty) {
      Get.snackbar(
        'Peringatan',
        'Tautan artikel tidak tersedia.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.amber.shade800,
        colorText: Colors.white,
      );
      return;
    }

    final uri = Uri.parse(article.url);
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        throw 'Could not launch $uri';
      }
    } catch (e) {
      Get.snackbar(
        'Gagal Membuka Browser',
        'Tidak dapat membuka artikel: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade700,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final ArticleController articleController = Get.find<ArticleController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Berita'),
        actions: [
          // Tombol Bookmark (Requirement 3)
          Obx(() {
            final isBookmarked = articleController.isBookmarked(article.id);
            return IconButton(
              tooltip: isBookmarked ? 'Hapus Bookmark' : 'Tambah Bookmark',
              icon: Icon(
                isBookmarked
                    ? Icons.bookmark_rounded
                    : Icons.bookmark_border_rounded,
                color: isBookmarked ? Colors.amber : Colors.white,
                size: 28,
              ),
              onPressed: () {
                articleController.toggleBookmark(article);
              },
            );
          }),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Gambar Berita
            Hero(
              tag: 'article_image_${article.id}',
              child: SizedBox(
                width: double.infinity,
                height: 250,
                child: article.imageUrl.isNotEmpty
                    ? Image.network(
                        article.imageUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: AppTheme.surface,
                            child: const Center(
                              child: CircularProgressIndicator(color: AppTheme.primary),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppTheme.surfaceLight,
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.broken_image_rounded, size: 54, color: AppTheme.textSecondary),
                                  SizedBox(height: 8),
                                  Text('Gambar tidak tersedia', style: TextStyle(color: AppTheme.textSecondary)),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    : Container(
                        color: AppTheme.surfaceLight,
                        child: const Center(
                          child: Icon(Icons.satellite_alt_rounded, size: 60, color: AppTheme.accent),
                        ),
                      ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Sumber Berita (News Site) & Tanggal Publikasi
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.primary, width: 1),
                        ),
                        child: Text(
                          article.newsSite,
                          style: const TextStyle(
                            color: AppTheme.accent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        article.formattedDate,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 3. Judul Berita
                  Text(
                    article.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 4. Penulis (Authors)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.cardBorder, width: 0.8),
                    ),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 18,
                          backgroundColor: AppTheme.primaryDark,
                          child: Icon(Icons.person_rounded, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Penulis / Kontributor:',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              Text(
                                article.authorsText,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 5. Ringkasan Berita (Summary)
                  const Text(
                    'Ringkasan Berita',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    article.summary.isNotEmpty
                        ? article.summary
                        : 'Tidak ada ringkasan yang tersedia untuk berita ini.',
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppTheme.textSecondary,
                      height: 1.6,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // 6. Tombol "Read Full Article"
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.secondary,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: () => _openFullArticle(context),
                      icon: const Icon(Icons.open_in_browser_rounded, size: 22),
                      label: const Text(
                        'Read Full Article',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
