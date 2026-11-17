import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/article_model.dart';

class ApiService {
  static const String baseUrl = 'https://api.spaceflightnewsapi.net/v4';

  /// Mengambil daftar artikel berita dari Spaceflight News API
  /// Mendukung filter berdasarkan news_site (sumber berita)
  static Future<List<ArticleModel>> getArticles({String? newsSite}) async {
    final Map<String, String> queryParams = {
      'limit': '25',
    };

    if (newsSite != null && newsSite.isNotEmpty && newsSite != 'All' && newsSite != 'Semua') {
      queryParams['news_site'] = newsSite;
    }

    final uri = Uri.parse('$baseUrl/articles/').replace(queryParameters: queryParams);

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> results = data['results'] ?? [];
        return results.map((item) => ArticleModel.fromJson(item as Map<String, dynamic>)).toList();
      } else {
        throw Exception('Gagal memuat berita dari server (Status: ${response.statusCode})');
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception('Koneksi internet bermasalah. Periksa jaringan Anda.');
      }
      rethrow;
    }
  }
}
