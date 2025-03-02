class Post {
  final int id;
  final String title;
  final String content;
  final String excerpt;
  final String featuredImageUrl;
  final DateTime date;
  final List<int> categories;
  final String author;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.excerpt,
    required this.featuredImageUrl,
    required this.date,
    required this.categories,
    required this.author,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    String featuredImageUrl = '';

    // Featured image URL'sini al
    if (json['_embedded'] != null &&
        json['_embedded']['wp:featuredmedia'] != null &&
        json['_embedded']['wp:featuredmedia'].isNotEmpty &&
        json['_embedded']['wp:featuredmedia'][0]['source_url'] != null) {
      featuredImageUrl = json['_embedded']['wp:featuredmedia'][0]['source_url'];
    }

    // Yazar bilgisini al
    String author = 'Unknown';
    if (json['_embedded'] != null &&
        json['_embedded']['author'] != null &&
        json['_embedded']['author'].isNotEmpty &&
        json['_embedded']['author'][0]['name'] != null) {
      author = json['_embedded']['author'][0]['name'];
    }

    return Post(
      id: json['id'],
      title: json['title']['rendered'] ?? '',
      content: json['content']['rendered'] ?? '',
      excerpt: json['excerpt']['rendered'] ?? '',
      featuredImageUrl: featuredImageUrl,
      date: DateTime.parse(json['date']),
      categories: List<int>.from(json['categories'] ?? []),
      author: author,
    );
  }
}
