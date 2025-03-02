import 'dart:convert';
import 'package:http/http.dart' as http;

class NewsService {
  final String baseUrl = 'https://wm.org.tr/wp-json/wp/v2';

  // Tüm haberleri getir
  Future<List<dynamic>> getAllNews({int page = 1, int perPage = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/posts?page=$page&per_page=$perPage&_embed'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Haberler yüklenirken hata: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Haberler alınırken bir hata oluştu: $e');
    }
  }

  // Kategori bazlı haberleri getir
  Future<List<dynamic>> getNewsByCategory(
    int categoryId, {
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/posts?categories=$categoryId&page=$page&per_page=$perPage&_embed',
        ),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Kategoriye göre haberler yüklenirken hata: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Kategoriye göre haberler alınırken bir hata oluştu: $e');
    }
  }

  // Arama bazlı haberleri getir
  Future<List<dynamic>> searchNews(
    String query, {
    int page = 1,
    int perPage = 10,
  }) async {
    try {
      final encodedQuery = Uri.encodeComponent(query);
      final response = await http.get(
        Uri.parse(
          '$baseUrl/posts?search=$encodedQuery&page=$page&per_page=$perPage&_embed',
        ),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Arama sonuçları yüklenirken hata: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Arama yapılırken bir hata oluştu: $e');
    }
  }

  // Kategorileri getir
  Future<List<dynamic>> getCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/categories'));

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Kategoriler yüklenirken hata: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Kategoriler alınırken bir hata oluştu: $e');
    }
  }

  // Tekil haber detayını getir
  Future<dynamic> getNewsDetail(int postId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/posts/$postId?_embed'),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception(
          'Haber detayı yüklenirken hata: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Haber detayı alınırken bir hata oluştu: $e');
    }
  }
}
