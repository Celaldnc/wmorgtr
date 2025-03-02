import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../services/wordpress_api_service.dart';

class NewsProvider extends ChangeNotifier {
  final WordPressApiService _apiService = WordPressApiService();

  List<Post> _allPosts = [];
  List<Post> _categoryPosts = [];
  List<Post> _searchResults = [];
  List<Map<String, dynamic>> _categories = [];
  bool _isLoading = false;
  String _error = '';

  // Getters
  List<Post> get allPosts => _allPosts;
  List<Post> get categoryPosts => _categoryPosts;
  List<Post> get searchResults => _searchResults;
  List<Map<String, dynamic>> get categories => _categories;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Tüm gönderileri yükle
  Future<void> loadPosts({int page = 1, bool refresh = false}) async {
    if (refresh) _allPosts = [];

    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      final posts = await _apiService.getPosts(page: page);

      if (refresh) {
        _allPosts = posts;
      } else {
        _allPosts.addAll(posts);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Kategoriye göre gönderileri yükle
  Future<void> loadPostsByCategory(
    int categoryId, {
    int page = 1,
    bool refresh = false,
  }) async {
    if (refresh) _categoryPosts = [];

    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      final posts = await _apiService.getPostsByCategory(
        categoryId,
        page: page,
      );

      if (refresh) {
        _categoryPosts = posts;
      } else {
        _categoryPosts.addAll(posts);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Arama yap
  Future<void> searchPosts(String query, {int page = 1}) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      final posts = await _apiService.searchPosts(query, page: page);
      _searchResults = posts;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Kategorileri yükle
  Future<void> loadCategories() async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      _categories = await _apiService.getCategories();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
