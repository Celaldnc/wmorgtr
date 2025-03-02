import 'package:flutter/material.dart';
import '../models/news_model.dart';
import '../services/news_service.dart';

class NewsProvider extends ChangeNotifier {
  final NewsService _newsService = NewsService();

  List<NewsModel> _trendingNews = [];
  List<NewsModel> _latestNews = [];
  List<NewsModel> _categoryNews = [];
  List<NewsModel> _searchResults = [];
  List<CategoryModel> _categories = [];

  bool _isLoading = false;
  bool _hasError = false;
  String _errorMessage = '';

  // Getters
  List<NewsModel> get trendingNews => _trendingNews;
  List<NewsModel> get latestNews => _latestNews;
  List<NewsModel> get categoryNews => _categoryNews;
  List<NewsModel> get searchResults => _searchResults;
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;

  // Trend haberleri yükle
  Future<void> fetchTrendingNews() async {
    _setLoading(true);
    _clearError();

    try {
      final responseData = await _newsService.getAllNews(perPage: 5);
      _trendingNews =
          responseData.map((item) => NewsModel.fromJson(item)).toList();
      Future.microtask(() {
        notifyListeners();
      });
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
      final responseData = await _newsService.getAllNews(page: page);
      final newNews =
          responseData.map((item) => NewsModel.fromJson(item)).toList();

      if (page == 1) {
        _latestNews = newNews;
      } else {
        _latestNews.addAll(newNews);
      }

      Future.microtask(() {
        notifyListeners();
      });
    } catch (e) {
      _setError('Son haberler yüklenirken bir hata oluştu: $e');
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
      final responseData = await _newsService.getNewsByCategory(
        categoryId,
        page: page,
      );
      final newNews =
          responseData.map((item) => NewsModel.fromJson(item)).toList();

      if (page == 1) {
        _categoryNews = newNews;
      } else {
        _categoryNews.addAll(newNews);
      }

      Future.microtask(() {
        notifyListeners();
      });
    } catch (e) {
      _setError('Kategori haberleri yüklenirken bir hata oluştu: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Arama yap
  Future<void> searchNews(String query, {int page = 1}) async {
    if (page == 1) {
      _searchResults = [];
    }

    if (query.isEmpty) {
      _searchResults = [];
      Future.microtask(() {
        notifyListeners();
      });
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      final responseData = await _newsService.searchNews(query, page: page);
      final newResults =
          responseData.map((item) => NewsModel.fromJson(item)).toList();

      if (page == 1) {
        _searchResults = newResults;
      } else {
        _searchResults.addAll(newResults);
      }

      Future.microtask(() {
        notifyListeners();
      });
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
      final responseData = await _newsService.getCategories();
      _categories =
          responseData.map((item) => CategoryModel.fromJson(item)).toList();
      Future.microtask(() {
        notifyListeners();
      });
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
      final responseData = await _newsService.getNewsDetail(newsId);
      return NewsModel.fromJson(responseData);
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
    Future.microtask(() {
      notifyListeners();
    });
  }

  void _setError(String message) {
    _hasError = true;
    _errorMessage = message;
    Future.microtask(() {
      notifyListeners();
    });
  }

  void _clearError() {
    _hasError = false;
    _errorMessage = '';
    Future.microtask(() {
      notifyListeners();
    });
  }
}
