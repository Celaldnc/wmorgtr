import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/news_model.dart';
import '../models/post_model.dart';

class ApiService {
  final String baseUrl = 'https://wm.org.tr/wp-json/wp/v2';

  // Temel get isteği fonksiyonu (kod tekrarını azaltmak için)
  Future<dynamic> _get(String endpoint) async {
    try {
      print('API isteği: $baseUrl/$endpoint');
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        // Yanıtı UTF-8 olarak decode et
        final decodedResponse = utf8.decode(response.bodyBytes);
        return json.decode(decodedResponse);
      } else {
        print('API hatası: ${response.statusCode} - ${response.body}');
        throw Exception('API isteği başarısız: ${response.statusCode}');
      }
    } catch (e) {
      print('API hatası: $e');
      throw Exception('API hatası: $e');
    }
  }

  // Tüm haberleri getir (NewsModel formatında)
  Future<List<NewsModel>> getAllNews({int page = 1, int perPage = 10}) async {
    try {
      final data = await _get('posts?page=$page&per_page=$perPage&_embed');
      return (data as List).map((item) => NewsModel.fromJson(item)).toList();
    } catch (e) {
      print('Haberler alınırken hata: $e');
      throw Exception('Haberler alınırken bir hata oluştu: $e');
    }
  }

  // Tüm haberleri getir (Post formatında)
  Future<List<Post>> getPosts({int page = 1, int perPage = 10}) async {
    try {
      final data = await _get('posts?_embed&page=$page&per_page=$perPage');
      return (data as List).map((item) => Post.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Haberler alınırken bir hata oluştu: $e');
    }
  }

  // Trend haberleri getir
  Future<List<NewsModel>> getTrendingNews({int perPage = 5}) async {
    try {
      // "Trending" etiketli veya popüler haberleri almak için bir sorgu eklenebilir
      // Şimdilik en son haberleri alıyoruz
      final data = await _get('posts?page=1&per_page=$perPage&_embed');
      return (data as List).map((item) => NewsModel.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Trend haberler alınırken bir hata oluştu: $e');
    }
  }

  // Kategori bazlı haberleri getir (NewsModel formatında)
  Future<List<NewsModel>> getNewsByCategory(
    int categoryId, {
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final data = await _get(
        'posts?categories=$categoryId&page=$page&per_page=$perPage&_embed',
      );
      return (data as List).map((item) => NewsModel.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Kategoriye göre haberler alınırken bir hata oluştu: $e');
    }
  }

  // Arama parametresi ile haberleri getir
  Future<List<NewsModel>> getNewsBySearch(
    String searchTerm, {
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final data = await _get(
        'posts?search=$searchTerm&page=$page&per_page=$perPage&_embed',
      );
      return (data as List).map((item) => NewsModel.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Arama ile haberler alınırken bir hata oluştu: $e');
    }
  }

  // Kategori bazlı haberleri getir (Post formatında)
  Future<List<Post>> getPostsByCategory(
    int categoryId, {
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final data = await _get(
        'posts?_embed&categories=$categoryId&page=$page&per_page=$perPage',
      );
      return (data as List).map((item) => Post.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Kategoriye göre haberler alınırken bir hata oluştu: $e');
    }
  }

  // Arama bazlı haberleri getir (NewsModel formatında)
  Future<List<NewsModel>> searchNews(
    String query, {
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final data = await _get(
        'posts?search=$encodedQuery&page=$page&per_page=$perPage&_embed',
      );
      return (data as List).map((item) => NewsModel.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Arama yapılırken bir hata oluştu: $e');
    }
  }

  // Arama bazlı haberleri getir (Post formatında)
  Future<List<Post>> searchPosts(
    String query, {
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final data = await _get(
        'posts?_embed&search=$encodedQuery&page=$page&per_page=$perPage',
      );
      return (data as List).map((item) => Post.fromJson(item)).toList();
    } catch (e) {
      throw Exception('Arama yapılırken bir hata oluştu: $e');
    }
  }

  // Kategorileri getir (CategoryModel formatında)
  Future<List<CategoryModel>> getCategories() async {
    try {
      final data = await _get('categories');
      return (data as List)
          .map((item) => CategoryModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('Kategoriler alınırken bir hata oluştu: $e');
    }
  }

  // Kategorileri getir (Map formatında)
  Future<List<Map<String, dynamic>>> getCategoriesAsMap() async {
    try {
      final data = await _get('categories');
      return (data as List)
          .map(
            (json) => {
              'id': json['id'],
              'name': json['name'],
              'count': json['count'],
            },
          )
          .toList();
    } catch (e) {
      throw Exception('Kategoriler alınırken bir hata oluştu: $e');
    }
  }

  // Tekil haber detayını getir
  Future<NewsModel> getNewsDetail(int postId) async {
    try {
      final data = await _get('posts/$postId?_embed');
      return NewsModel.fromJson(data);
    } catch (e) {
      print('Haber detayı alınırken hata: $e');
      throw Exception('Haber detayı alınırken bir hata oluştu: $e');
    }
  }
}
