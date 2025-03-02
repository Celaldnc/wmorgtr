import 'package:flutter/material.dart';
import '../models/topic_model.dart';
import '../models/news_model.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExplorerProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<TopicModel> _topics = [];
  List<AuthorModel> _authors = [];
  List<NewsModel> _savedNews = [];
  bool _isLoading = false;
  String _error = '';

  // Getters
  List<TopicModel> get topics => _topics;
  List<AuthorModel> get authors => _authors;
  List<NewsModel> get savedNews => _savedNews;
  bool get isLoading => _isLoading;
  String get error => _error;

  ExplorerProvider() {
    _initializeTopics();
    _loadAuthors();
    _loadSavedNews();
  }

  // Kategorileri başlat
  void _initializeTopics() {
    _topics = [
      TopicModel(
        id: 1,
        name: 'Sanatçılar',
        description: 'Sanatçılar hakkında en güncel haberler',
        imageUrl: 'https://via.placeholder.com/150',
        count: 8206,
      ),
      TopicModel(
        id: 2,
        name: 'Bilim Adamları',
        description: 'Bilim adamları ve keşifleri hakkında haberler',
        imageUrl: 'https://via.placeholder.com/150',
        count: 4266,
      ),
      TopicModel(
        id: 3,
        name: 'Yeni Oyunlar',
        description: 'Yeni çıkan oyunlar hakkında bilgiler',
        imageUrl: 'https://via.placeholder.com/150',
        count: 3938,
      ),
      TopicModel(
        id: 4,
        name: 'Android',
        description: 'Android dünyasından en son gelişmeler',
        imageUrl: 'https://via.placeholder.com/150',
        count: 2092,
      ),
      TopicModel(
        id: 5,
        name: 'Oyun',
        description: 'Oyun dünyasından haberler',
        imageUrl: 'https://via.placeholder.com/150',
        count: 1931,
      ),
      TopicModel(
        id: 6,
        name: 'Edebiyat',
        description: 'Edebiyat dünyasından en son gelişmeler',
        imageUrl: 'https://via.placeholder.com/150',
        count: 1611,
      ),
      TopicModel(
        id: 7,
        name: 'Apple',
        description: 'Apple ürünleri ve haberleri',
        imageUrl: 'https://via.placeholder.com/150',
        count: 1372,
      ),
      TopicModel(
        id: 8,
        name: 'Tiyatro',
        description: 'Tiyatro dünyasından haberler',
        imageUrl: 'https://via.placeholder.com/150',
        count: 1122,
      ),
      TopicModel(
        id: 9,
        name: 'SEO ve Arama',
        description: 'SEO ve arama teknolojileri hakkında bilgiler',
        imageUrl: 'https://via.placeholder.com/150',
        count: 609,
      ),
      TopicModel(
        id: 10,
        name: 'İşadamları',
        description: 'İş dünyasından önemli isimler',
        imageUrl: 'https://via.placeholder.com/150',
        count: 583,
      ),
    ];

    _loadSavedTopics();
  }

  // Kaydedilmiş konuları yükle
  Future<void> _loadSavedTopics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTopicIds = prefs.getStringList('saved_topics') ?? [];

      _topics =
          _topics.map((topic) {
            return topic.copyWith(
              isSaved: savedTopicIds.contains(topic.id.toString()),
            );
          }).toList();

      notifyListeners();
    } catch (e) {
      _error = 'Kaydedilmiş konular yüklenirken hata oluştu: $e';
    }
  }

  // Yazarları yükle
  Future<void> _loadAuthors() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Gerçek uygulamada API'den yazarları çekebilirsiniz
      // Şimdilik örnek veriler kullanıyoruz
      await Future.delayed(const Duration(seconds: 1));

      _authors = [
        AuthorModel(
          id: 1,
          name: 'Ahmet Yılmaz',
          avatarUrl: 'https://via.placeholder.com/150',
          bio: 'Teknoloji yazarı',
          articleCount: 45,
        ),
        AuthorModel(
          id: 2,
          name: 'Ayşe Demir',
          avatarUrl: 'https://via.placeholder.com/150',
          bio: 'Bilim ve teknoloji editörü',
          articleCount: 32,
        ),
        AuthorModel(
          id: 3,
          name: 'Mehmet Kaya',
          avatarUrl: 'https://via.placeholder.com/150',
          bio: 'Oyun inceleme uzmanı',
          articleCount: 28,
        ),
        AuthorModel(
          id: 4,
          name: 'Zeynep Şahin',
          avatarUrl: 'https://via.placeholder.com/150',
          bio: 'Edebiyat ve sanat yazarı',
          articleCount: 19,
        ),
      ];

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Yazarlar yüklenirken hata oluştu: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Kaydedilmiş haberleri yükle
  Future<void> _loadSavedNews() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedNewsIds = prefs.getStringList('saved_news') ?? [];

      if (savedNewsIds.isNotEmpty) {
        _isLoading = true;
        notifyListeners();

        // Her bir kaydedilmiş haber için detayları al
        List<NewsModel> news = [];
        for (String id in savedNewsIds) {
          try {
            final newsItem = await _apiService.getNewsDetail(int.parse(id));
            news.add(newsItem);
          } catch (e) {
            print('Haber detayı alınırken hata: $e');
          }
        }

        _savedNews = news;
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = 'Kaydedilmiş haberler yüklenirken hata oluştu: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Konuyu kaydet/kaldır
  Future<void> toggleSaveTopic(int topicId) async {
    try {
      final index = _topics.indexWhere((topic) => topic.id == topicId);
      if (index != -1) {
        final newIsSaved = !_topics[index].isSaved;
        _topics[index] = _topics[index].copyWith(isSaved: newIsSaved);
        notifyListeners();

        // SharedPreferences'e kaydet
        final prefs = await SharedPreferences.getInstance();
        final savedTopicIds = prefs.getStringList('saved_topics') ?? [];

        if (newIsSaved) {
          savedTopicIds.add(topicId.toString());
        } else {
          savedTopicIds.remove(topicId.toString());
        }

        await prefs.setStringList('saved_topics', savedTopicIds);
      }
    } catch (e) {
      _error = 'Konu kaydedilirken hata oluştu: $e';
      notifyListeners();
    }
  }

  // Yazarı takip et/takibi bırak
  Future<void> toggleFollowAuthor(int authorId) async {
    try {
      final index = _authors.indexWhere((author) => author.id == authorId);
      if (index != -1) {
        final newIsFollowing = !_authors[index].isFollowing;
        _authors[index] = _authors[index].copyWith(isFollowing: newIsFollowing);
        notifyListeners();

        // SharedPreferences'e kaydet
        final prefs = await SharedPreferences.getInstance();
        final followedAuthorIds = prefs.getStringList('followed_authors') ?? [];

        if (newIsFollowing) {
          followedAuthorIds.add(authorId.toString());
        } else {
          followedAuthorIds.remove(authorId.toString());
        }

        await prefs.setStringList('followed_authors', followedAuthorIds);
      }
    } catch (e) {
      _error = 'Yazar takip edilirken hata oluştu: $e';
      notifyListeners();
    }
  }

  // Kategori bazlı haberleri getir
  Future<List<NewsModel>> getNewsByTopic(int topicId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final news = await _apiService.getNewsByCategory(topicId);

      _isLoading = false;
      notifyListeners();

      return news;
    } catch (e) {
      _error = 'Haberler yüklenirken hata oluştu: $e';
      _isLoading = false;
      notifyListeners();
      return [];
    }
  }
}
