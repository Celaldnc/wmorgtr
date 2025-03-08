import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/news_model.dart';
import '../providers/unified_news_provider.dart';
import '../widgets/news_card.dart';
import 'news_detail_screen.dart';
import 'explorer_screen.dart';
import 'create_news_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  int _currentPage = 1;
  bool _isLoadingMore = false;
  int _selectedCategoryIndex = 0;
  int _selectedNavIndex = 0;
  late TabController _tabController;

  final ScrollController _scrollController = ScrollController();

  // Kategori listesi
  final List<String> _categories = [
    'For You',
    'Android',
    'SEO',
    'Apple',
    'İşadamları',
    'Tiyatro',
    'Yeni Oyunlar',
    'Sanatçılar',
    'Oyun',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _tabController.addListener(_handleTabChange);

    // Verileri yükle - build tamamlandıktan sonra
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
    });

    // Scroll olayını dinle (sonsuz kaydırma için)
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMoreNews();
      }
    });
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      setState(() {
        _selectedCategoryIndex = _tabController.index;
        _currentPage = 1;
      });

      // Kategori değiştiğinde haberleri yükle
      _loadCategoryNews(_selectedCategoryIndex);

      // Sayfayı yukarı kaydır
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  void _loadCategoryNews(int index) {
    final newsProvider = Provider.of<UnifiedNewsProvider>(
      context,
      listen: false,
    );

    if (index == 0) {
      // For You - Kullanıcının kaydettiği haber türlerine göre
      newsProvider.fetchPersonalizedNews();
    } else {
      // Diğer kategoriler - wm.org.tr'den ilgili kategorideki haberler
      // Kategori ID'lerini wm.org.tr'deki kategori ID'leriyle eşleştir
      int categoryId;
      switch (index) {
        case 1: // Android
          categoryId = 1; // Android kategorisi ID'si
          break;
        case 2: // SEO
          categoryId = 15; // SEO kategorisi ID'si
          break;
        case 3: // Apple
          categoryId = 2; // Apple kategorisi ID'si
          break;
        case 4: // İşadamları
          categoryId = 20; // İşadamları kategorisi ID'si
          break;
        case 5: // Tiyatro
          categoryId = 25; // Tiyatro kategorisi ID'si
          break;
        case 6: // Yeni Oyunlar
          categoryId = 30; // Yeni Oyunlar kategorisi ID'si
          break;
        case 7: // Sanatçılar
          categoryId = 35; // Sanatçılar kategorisi ID'si
          break;
        case 8: // Oyun
          categoryId = 6; // Oyun kategorisi ID'si
          break;
        default:
          categoryId = 1; // Varsayılan olarak Android kategorisi
      }
      newsProvider.fetchNewsByCategory(categoryId);
    }
  }

  // Haber detay sayfasına yönlendirme
  void _navigateToNewsDetail(NewsModel news) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => NewsDetailScreen(newsId: news.id, initialNews: news),
      ),
    );
  }

  Future<void> _loadData() async {
    final newsProvider = Provider.of<UnifiedNewsProvider>(
      context,
      listen: false,
    );
    await newsProvider.fetchPersonalizedNews(); // For You için
    await newsProvider.fetchContinueReading(); // Devam edilen haberler
  }

  Future<void> _loadMoreNews() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final newsProvider = Provider.of<UnifiedNewsProvider>(
        context,
        listen: false,
      );

      if (_isSearching && _searchController.text.isNotEmpty) {
        // Arama yapılıyorsa, arama sonuçlarını getir
        await newsProvider.searchNews(
          _searchController.text,
          page: _currentPage + 1,
        );
      } else {
        // Kategori seçimine göre haberleri getir
        _loadCategoryNews(_selectedCategoryIndex);
      }

      setState(() {
        _currentPage++;
      });
    } catch (e) {
      // Hata durumunda
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  void _handleSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _currentPage = 1;
    });

    try {
      final newsProvider = Provider.of<UnifiedNewsProvider>(
        context,
        listen: false,
      );
      await newsProvider.searchNews(query);
    } catch (e) {
      // Hata durumunda işlem yapılabilir
      if (mounted) {
        setState(() {
          // Gerekirse state güncellenebilir
        });
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child:
            _selectedNavIndex == 0
                ? Consumer<UnifiedNewsProvider>(
                  builder: (context, newsProvider, child) {
                    return CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        // Selamlama ve Bildirim
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Morning, Alex',
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.waving_hand,
                                      color: Colors.amber,
                                      size: 22,
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.notifications_outlined,
                                  ),
                                  onPressed: () {
                                    // Bildirimler sayfasına git
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Arama Çubuğu
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Haber ara...',
                                prefixIcon: const Icon(Icons.search),
                                suffixIcon:
                                    _searchController.text.isNotEmpty
                                        ? IconButton(
                                          icon: const Icon(Icons.clear),
                                          onPressed: () {
                                            _searchController.clear();
                                            _handleSearch('');
                                          },
                                        )
                                        : null,
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 0,
                                ),
                              ),
                              onSubmitted: _handleSearch,
                              onChanged: (value) {
                                setState(() {});
                              },
                              textInputAction: TextInputAction.search,
                            ),
                          ),
                        ),

                        // Kategori Tabları
                        SliverToBoxAdapter(
                          child: TabBar(
                            controller: _tabController,
                            isScrollable: true,
                            labelColor: Colors.black,
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: Colors.black,
                            indicatorSize: TabBarIndicatorSize.label,
                            labelStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                            unselectedLabelStyle: const TextStyle(
                              fontWeight: FontWeight.normal,
                              fontSize: 14,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            labelPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            tabs:
                                _categories
                                    .map((category) => Tab(text: category))
                                    .toList(),
                          ),
                        ),

                        // Devam Edilen Okumalar
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Continue Reading',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _buildContinueReadingCard(newsProvider),
                              ],
                            ),
                          ),
                        ),

                        // Seçilen Haberler
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _isSearching
                                      ? 'Arama Sonuçları'
                                      : _selectedCategoryIndex == 0
                                      ? 'Selected For You'
                                      : '${_categories[_selectedCategoryIndex]} Haberleri',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (!_isSearching)
                                  TextButton(
                                    onPressed: () {
                                      // Tüm kişiselleştirilmiş haberleri göster
                                    },
                                    child: const Text(
                                      'Explore More',
                                      style: TextStyle(color: Colors.teal),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        // Haberler Listesi
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              // Kategori seçimine göre gösterilecek haber listesini belirle
                              final List<NewsModel> newsList;
                              if (_isSearching) {
                                newsList = newsProvider.searchResults;
                              } else if (_selectedCategoryIndex == 0) {
                                newsList = newsProvider.personalizedNews;
                              } else {
                                newsList = newsProvider.categoryNews;
                              }

                              // Yükleniyor durumu
                              if (newsProvider.isLoading && newsList.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              // Boş liste durumu
                              if (newsList.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Center(
                                    child: Text(
                                      _isSearching
                                          ? 'Arama sonucu bulunamadı'
                                          : 'Haber bulunamadı',
                                    ),
                                  ),
                                );
                              }

                              final news = newsList[index];
                              return _buildSelectedNewsItem(news);
                            },
                            childCount:
                                _isSearching
                                    ? (newsProvider.searchResults.isEmpty
                                        ? 1
                                        : newsProvider.searchResults.length)
                                    : _selectedCategoryIndex == 0
                                    ? (newsProvider.personalizedNews.isEmpty
                                        ? 1
                                        : newsProvider.personalizedNews.length >
                                            3
                                        ? 3
                                        : newsProvider.personalizedNews.length)
                                    : (newsProvider.categoryNews.isEmpty
                                        ? 1
                                        : newsProvider.categoryNews.length),
                          ),
                        ),

                        // Yükleniyor
                        if (newsProvider.isLoading &&
                            !_isLoadingMore &&
                            ((_selectedCategoryIndex == 0 &&
                                    newsProvider.personalizedNews.isNotEmpty) ||
                                (_selectedCategoryIndex != 0 &&
                                    newsProvider.categoryNews.isNotEmpty)))
                          const SliverToBoxAdapter(
                            child: Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(),
                              ),
                            ),
                          ),

                        // Yükleniyor (Daha fazla için)
                        if (_isLoadingMore)
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                          ),
                      ],
                    );
                  },
                )
                : const ExplorerScreen(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedNavIndex,
        onTap: (index) {
          // Artı butonuna tıklandığında direkt haber oluşturma sayfasına git
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateNewsScreen()),
            );
          } else {
            setState(() {
              _selectedNavIndex = index < 2 ? index : index - 1;
            });
          }
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, size: 40, color: Color(0xFFB21274)),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Kaydedilenler',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  // Devam Edilen Okuma Kartı
  Widget _buildContinueReadingCard(UnifiedNewsProvider newsProvider) {
    // Eğer devam edilen haber yoksa boş bir container döndür
    if (newsProvider.continueReadingNews.isEmpty) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(child: Text('Devam edilen okuma bulunamadı')),
      );
    }

    final news = newsProvider.continueReadingNews.first;

    return GestureDetector(
      onTap: () => _navigateToNewsDetail(news),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Arkaplan resmi
              Positioned.fill(
                child:
                    news.featuredImageUrl.isNotEmpty
                        ? Image.network(
                          news.featuredImageUrl,
                          fit: BoxFit.cover,
                        )
                        : Container(color: Colors.grey[300]),
              ),

              // Karartma gradyanı
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),

              // İçerik
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Başlık
                    Text(
                      news.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 8),

                    // Yazar ve okuma süresi
                    Row(
                      children: [
                        Text(
                          news.authorName,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '7:25',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Seçilen Haber Öğesi
  Widget _buildSelectedNewsItem(NewsModel news) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: () => _navigateToNewsDetail(news),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sol taraf - Profil resmi
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey[200],
                  child:
                      news.authorName.isNotEmpty
                          ? Text(
                            news.authorName[0],
                            style: TextStyle(
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                          : Icon(
                            Icons.person,
                            size: 16,
                            color: Colors.grey[700],
                          ),
                ),

                const SizedBox(width: 12),

                // Sağ taraf - İçerik
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Başlık satırı
                      Row(
                        children: [
                          // Yazar adı
                          Expanded(
                            child: Text(
                              news.authorName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          // Yorum sayısı
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '128',
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Haber başlığı
                      Text(
                        news.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 8),

                      // Alt bilgiler
                      Row(
                        children: [
                          // Tarih
                          Text(
                            news.getFormattedDate(),
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),

                          const Spacer(),

                          // Artı butonu
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.add,
                              size: 16,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
