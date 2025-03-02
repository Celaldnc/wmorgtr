import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/post_model.dart';

class WordPressApiService {
  final String baseUrl = 'https://wm.org.tr/wp-json/wp/v2';

  // Tüm gönderileri getir
  Future<List<Post>> getPosts({int page = 1, int perPage = 10}) async {
    final response = await http.get(
      Uri.parse('$baseUrl/posts?_embed&page=$page&per_page=$perPage'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load posts: ${response.statusCode}');
    }
  }

  // Belirli bir kategorideki gönderileri getir
  Future<List<Post>> getPostsByCategory(
    int categoryId, {
    int page = 1,
    int perPage = 10,
  }) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/posts?_embed&categories=$categoryId&page=$page&per_page=$perPage',
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to load posts by category: ${response.statusCode}',
      );
    }
  }

  // Arama terimine göre gönderileri getir
  Future<List<Post>> searchPosts(
    String searchTerm, {
    int page = 1,
    int perPage = 10,
  }) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/posts?_embed&search=${Uri.encodeComponent(searchTerm)}&page=$page&per_page=$perPage',
      ),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search posts: ${response.statusCode}');
    }
  }

  // Kategori listesini getir
  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await http.get(Uri.parse('$baseUrl/categories'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .map(
            (json) => {
              'id': json['id'],
              'name': json['name'],
              'count': json['count'],
            },
          )
          .toList();
    } else {
      throw Exception('Failed to load categories: ${response.statusCode}');
    }
  }
}
