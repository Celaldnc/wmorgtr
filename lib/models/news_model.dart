class NewsModel {
  final int id;
  final String title;
  final String content;
  final String excerpt;
  final String date;
  final String link;
  final String featuredImageUrl;
  final List<dynamic> categories;
  final String source;
  final String authorName;

  NewsModel({
    required this.id,
    required this.title,
    required this.content,
    required this.excerpt,
    required this.date,
    required this.link,
    required this.featuredImageUrl,
    required this.categories,
    required this.source,
    required this.authorName,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    // Özelleştirilmiş başlık - HTML etiketlerini temizlemek için
    String parseHtmlString(String htmlString) {
      // Önce HTML etiketlerini temizle
      RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
      String result = htmlString.replaceAll(exp, '');

      // Özel HTML karakterlerini düzelt
      result = result
          .replaceAll('&nbsp;', ' ')
          .replaceAll('&quot;', '"')
          .replaceAll('&amp;', '&')
          .replaceAll('&lt;', '<')
          .replaceAll('&gt;', '>')
          .replaceAll('&#8217;', "'")
          .replaceAll('&#8220;', '"')
          .replaceAll('&#8221;', '"')
          .replaceAll('&#8211;', '-')
          .replaceAll('&#8212;', '-')
          .replaceAll('&#8230;', '...');

      // Diğer HTML kodlarını temizle (&#xxxx; formatındaki kodlar)
      result = result.replaceAllMapped(
        RegExp(r'&#(\d+);'),
        (match) => String.fromCharCode(int.parse(match.group(1)!)),
      );

      return result;
    }

    // Başlık
    String title = '';
    if (json['title'] != null && json['title']['rendered'] != null) {
      title = parseHtmlString(json['title']['rendered']);
    }

    // İçerik
    String content = '';
    if (json['content'] != null && json['content']['rendered'] != null) {
      content = json['content']['rendered'];
    }

    // Alıntı
    String excerpt = '';
    if (json['excerpt'] != null && json['excerpt']['rendered'] != null) {
      excerpt = parseHtmlString(json['excerpt']['rendered']);
    }

    // Öne çıkan resim URL'si
    String featuredImageUrl = '';
    if (json['_embedded'] != null &&
        json['_embedded']['wp:featuredmedia'] != null &&
        json['_embedded']['wp:featuredmedia'].isNotEmpty &&
        json['_embedded']['wp:featuredmedia'][0]['source_url'] != null) {
      featuredImageUrl = json['_embedded']['wp:featuredmedia'][0]['source_url'];
    }

    // Yazar adı
    String authorName = 'WM.org.tr';
    if (json['_embedded'] != null &&
        json['_embedded']['author'] != null &&
        json['_embedded']['author'].isNotEmpty &&
        json['_embedded']['author'][0]['name'] != null) {
      authorName = json['_embedded']['author'][0]['name'];
    }

    // Kategoriler
    List<dynamic> categories = [];
    if (json['categories'] != null) {
      categories = json['categories'];
    }

    return NewsModel(
      id: json['id'] ?? 0,
      title: title,
      content: content,
      excerpt: excerpt,
      date: json['date'] ?? '',
      link: json['link'] ?? '',
      featuredImageUrl: featuredImageUrl,
      categories: categories,
      source: 'WM.org.tr',
      authorName: authorName,
    );
  }

  // Zamanı formatla
  String getFormattedDate() {
    try {
      final DateTime dateTime = DateTime.parse(date);
      final Duration difference = DateTime.now().difference(dateTime);

      if (difference.inDays > 0) {
        return '${difference.inDays} gün önce';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} saat önce';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} dakika önce';
      } else {
        return 'Az önce';
      }
    } catch (e) {
      return date;
    }
  }
}

// Kategori modeli
class CategoryModel {
  final int id;
  final String name;
  final String slug;

  CategoryModel({required this.id, required this.name, required this.slug});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
    );
  }
}
