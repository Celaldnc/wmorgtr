import 'package:flutter/material.dart';
import '../models/news_model.dart';
import '../models/post_model.dart';
import '../services/api_service.dart';

class UnifiedNewsProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  // Haber Modelleri
  List<NewsModel> _trendingNews = [];
  List<NewsModel> _latestNews = [];
  List<NewsModel> _categoryNews = [];
  List<NewsModel> _searchResults = [];

  // Post Modelleri
  List<Post> _allPosts = [];
  List<Post> _categoryPosts = [];
  List<Post> _searchPostItems = [];

  // Kategoriler
  List<CategoryModel> _categories = [];

  // Durum
  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  // Getters
  List<NewsModel> get trendingNews => _trendingNews;
  List<NewsModel> get latestNews => _latestNews;
  List<NewsModel> get categoryNews => _categoryNews;
  List<NewsModel> get searchResults => _searchResults;

  List<Post> get allPosts => _allPosts;
  List<Post> get categoryPosts => _categoryPosts;
  List<Post> get searchPostItems => _searchPostItems;

  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;

  // Trend haberleri yükle
  Future<void> fetchTrendingNews() async {
    _setLoading(true);
    _clearError();

    try {
      _trendingNews = await _apiService.getTrendingNews();
      notifyListeners();
    } catch (e) {
      _setError('Trend haberler yüklenirken bir hata oluştu: $e');
    } finally {
      _setLoading(false);
    }
  }

  // En son haberleri yükle
  Future<void> fetchLatestNews({int page = 1}) async {
    if (page == 1) {
      _latestNews = [];
    }

    _setLoading(true);
    _clearError();

    try {
      final newNews = await _apiService.getAllNews(page: page);

      if (page == 1) {
        _latestNews = newNews;
      } else {
        _latestNews.addAll(newNews);
      }

      notifyListeners();
    } catch (e) {
      _setError('Son haberler yüklenirken bir hata oluştu: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Tüm postları yükle
  Future<void> loadPosts({int page = 1, bool refresh = false}) async {
    if (refresh) _allPosts = [];

    _setLoading(true);
    _clearError();

    try {
      final posts = await _apiService.getPosts(page: page);

      if (refresh) {
        _allPosts = posts;
      } else {
        _allPosts.addAll(posts);
      }

      notifyListeners();
    } catch (e) {
      _setError('Gönderiler yüklenirken bir hata oluştu: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Kategoriye göre haberleri yükle
  Future<void> fetchNewsByCategory(int categoryId, {int page = 1}) async {
    if (page == 1) {
      _categoryNews = [];
    }

    _setLoading(true);
    _clearError();

    try {
      final newNews = await _apiService.getNewsByCategory(
        categoryId,
        page: page,
      );

      if (page == 1) {
        _categoryNews = newNews;
      } else {
        _categoryNews.addAll(newNews);
      }

      notifyListeners();
    } catch (e) {
      _setError('Kategori haberleri yüklenirken bir hata oluştu: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Kategoriye göre postları yükle
  Future<void> loadPostsByCategory(
    int categoryId, {
    int page = 1,
    bool refresh = false,
  }) async {
    if (refresh) _categoryPosts = [];

    _setLoading(true);
    _clearError();

    try {
      final posts = await _apiService.getPostsByCategory(
        categoryId,
        page: page,
      );

      if (refresh) {
        _categoryPosts = posts;
      } else {
        _categoryPosts.addAll(posts);
      }

      notifyListeners();
    } catch (e) {
      _setError('Kategori gönderileri yüklenirken bir hata oluştu: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Arama yap (NewsModel)
  Future<void> searchNews(String query, {int page = 1}) async {
    if (page == 1) {
      _searchResults = [];
    }

    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      final newResults = await _apiService.searchNews(query, page: page);

      if (page == 1) {
        _searchResults = newResults;
      } else {
        _searchResults.addAll(newResults);
      }

      notifyListeners();
    } catch (e) {
      _setError('Arama yapılırken bir hata oluştu: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Arama yap (Post)
  Future<void> searchPosts(String query, {int page = 1}) async {
    if (query.isEmpty) {
      _searchPostItems = [];
      notifyListeners();
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      final posts = await _apiService.searchPosts(query, page: page);
      _searchPostItems = posts;
      notifyListeners();
    } catch (e) {
      _setError('Arama yapılırken bir hata oluştu: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Kategorileri yükle
  Future<void> fetchCategories() async {
    _setLoading(true);
    _clearError();

    try {
      _categories = await _apiService.getCategories();
      notifyListeners();
    } catch (e) {
      _setError('Kategoriler yüklenirken bir hata oluştu: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Haber detayını getir
  Future<NewsModel?> getNewsDetail(int newsId) async {
    _setLoading(true);
    _clearError();

    try {
      final newsDetail = await _apiService.getNewsDetail(newsId);
      return newsDetail;
    } catch (e) {
      _setError('Haber detayı yüklenirken bir hata oluştu: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _hasError = true;
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _hasError = false;
    _errorMessage = '';
  }
}
