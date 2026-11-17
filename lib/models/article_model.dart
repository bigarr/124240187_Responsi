class ArticleModel {
  final int id;
  final String title;
  final String url;
  final String imageUrl;
  final String newsSite;
  final String summary;
  final String publishedAt;
  final String updatedAt;
  final List<String> authors;

  ArticleModel({
    required this.id,
    required this.title,
    required this.url,
    required this.imageUrl,
    required this.newsSite,
    required this.summary,
    required this.publishedAt,
    required this.updatedAt,
    this.authors = const [],
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    List<String> authorsList = [];
    if (json['authors'] is List) {
      authorsList = (json['authors'] as List)
          .map((a) {
            if (a is Map) {
              return (a['name'] as String? ?? 'Unknown');
            }
            return a.toString();
          })
          .where((s) => s.isNotEmpty)
          .toList();
    }

    return ArticleModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      title: json['title'] as String? ?? 'No Title',
      url: json['url'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? json['imageUrl'] as String? ?? '',
      newsSite: json['news_site'] as String? ?? json['newsSite'] as String? ?? 'Spaceflight News',
      summary: json['summary'] as String? ?? '',
      publishedAt: json['published_at'] as String? ?? json['publishedAt'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? json['updatedAt'] as String? ?? '',
      authors: authorsList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'imageUrl': imageUrl,
      'newsSite': newsSite,
      'summary': summary,
      'publishedAt': publishedAt,
      'updatedAt': updatedAt,
      'authors': authors,
    };
  }

  String get formattedDate {
    if (publishedAt.isEmpty) return 'Unknown Date';
    try {
      final dt = DateTime.parse(publishedAt).toLocal();
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      final month = months[dt.month - 1];
      final minute = dt.minute.toString().padLeft(2, '0');
      final hour = dt.hour.toString().padLeft(2, '0');
      return '${dt.day} $month ${dt.year}, $hour:$minute';
    } catch (_) {
      return publishedAt;
    }
  }

  String get authorsText {
    if (authors.isEmpty) return 'Spaceflight News Reporter';
    return authors.join(', ');
  }
}
