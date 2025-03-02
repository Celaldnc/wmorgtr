import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/news_model.dart';
import '../providers/unified_news_provider.dart';
import '../widgets/news_card.dart';
import 'news_detail_screen.dart';
import 'explorer_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  int _currentPage = 1;
  bool _isLoadingMore = false;
  int _selectedCategoryIndex = 0;
  int _selectedNavIndex = 0;

  final ScrollController _scrollController = ScrollController();

  // Sabit kategori listesi (gerçek uygulamada API'den alınacak)
  final List<Map<String, dynamic>> _categories = [
    {'id': 0, 'name': 'All'},
    {'id': 1, 'name': 'Sports'},
    {'id': 2, 'name': 'Politics'},
    {'id': 3, 'name': 'Business'},
    {'id': 4, 'name': 'Health'},
    {'id': 5, 'name': 'Travel'},
    {'id': 6, 'name': 'Science'},
  ];

  @override
  void initState() {
    super.initState();

    // Verileri yükle - build tamamlandıktan sonra
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadData();
      _loadCategories(); // Kategorileri yükle
    });

    // Scroll olayını dinle (sonsuz kaydırma için)
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        _loadMoreNews();
      }
    });
  }

  // Kategorileri API'den yükle
  Future<void> _loadCategories() async {
    final newsProvider = Provider.of<UnifiedNewsProvider>(
      context,
      listen: false,
    );
    await newsProvider.fetchCategories();

    // API'den gelen kategorileri state'e aktar
    if (newsProvider.categories.isNotEmpty) {
      setState(() {
        // "All" kategorisini her zaman listenin başında tut
        final apiCategories =
            newsProvider.categories
                .map((category) => {'id': category.id, 'name': category.name})
                .toList();

        _categories.clear();
        _categories.add({'id': 0, 'name': 'All'});
        _categories.addAll(apiCategories);
      });
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
    await newsProvider.fetchTrendingNews();
    await newsProvider.fetchLatestNews();
    await newsProvider.fetchCategories();
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
      } else if (_selectedCategoryIndex > 0) {
        // Kategori seçili ise, o kategorinin haberlerini getir
        final categoryId = _categories[_selectedCategoryIndex]['id'] as int;
        await newsProvider.fetchNewsByCategory(
          categoryId,
          page: _currentPage + 1,
        );
      } else {
        // Seçili kategori All ise veya kategori seçili değilse, tüm haberleri getir
        await newsProvider.fetchLatestNews(page: _currentPage + 1);
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child:
            _selectedNavIndex == 0
                ? Consumer<UnifiedNewsProvider>(
                  builder: (context, newsProvider, child) {
                    return CustomScrollView(
                      controller: _scrollController,
                      slivers: [
                        // Uygulama Çubuğu
                        SliverAppBar(
                          floating: true,
                          pinned: false,
                          snap: false,
                          backgroundColor: Colors.white,
                          elevation: 0,
                          title: const Text(
                            'WM.org.tr',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          actions: [
                            IconButton(
                              icon: const Icon(
                                Icons.bookmark_border,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                // Kaydedilmiş haberlere git
                              },
                            ),
                          ],
                        ),

                        // Arama Çubuğu
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: TextField(
                              controller: _searchController,
                              decoration: InputDecoration(
                                hintText: 'Search',
                                prefixIcon: const Icon(Icons.search),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.filter_list),
                                  onPressed: () {
                                    // Filtre menüsünü aç
                                  },
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  vertical: 0,
                                ),
                              ),
                              onSubmitted: _handleSearch,
                              textInputAction: TextInputAction.search,
                            ),
                          ),
                        ),

                        // İçerik
                        if (_isSearching)
                          _buildSearchResults(newsProvider)
                        else
                          ..._buildHomeContent(newsProvider),

                        // Yükleniyor
                        if (newsProvider.isLoading && !_isLoadingMore)
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
          setState(() {
            _selectedNavIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Explore'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Bookmark',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  List<Widget> _buildHomeContent(UnifiedNewsProvider newsProvider) {
    return [
      // Trend Olan
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Trending',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  // Tüm trend haberleri göster
                },
                child: const Text('See all'),
              ),
            ],
          ),
        ),
      ),

      // Trend Haberler Listesi
      SliverToBoxAdapter(
        child: SizedBox(
          height: 320,
          child:
              newsProvider.trendingNews.isEmpty
                  ? const Center(child: Text('Trend haber bulunamadı'))
                  : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: newsProvider.trendingNews.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width:
                            MediaQuery.of(context).size.width *
                            0.85, // Genişliği artırıldı
                        margin: const EdgeInsets.only(right: 16),
                        child: NewsCard(
                          news: newsProvider.trendingNews[index],
                          isTrending: true,
                          onTap: () {
                            _navigateToNewsDetail(
                              newsProvider.trendingNews[index],
                            );
                          },
                        ),
                      );
                    },
                  ),
        ),
      ),

      // En Son Haberler
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Latest',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  // Tüm son haberleri göster
                },
                child: const Text('See all'),
              ),
            ],
          ),
        ),
      ),

      // Kategori Seçimi - Görsel ile uyumlu alt çizgili tab tasarımı
      SliverToBoxAdapter(
        child: SizedBox(height: 44, child: _buildCategoryTabs(newsProvider)),
      ),

      // Son Haberler Listesi
      SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            // Seçili kategori "All" ise latest haberleri, değilse kategori haberlerini göster
            final newsList =
                _selectedCategoryIndex == 0
                    ? newsProvider.latestNews
                    : newsProvider.categoryNews;

            if (newsList.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(child: Text('Haber bulunamadı')),
              );
            }

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: NewsCard(
                news: newsList[index],
                onTap: () {
                  _navigateToNewsDetail(newsList[index]);
                },
              ),
            );
          },
          childCount:
              _selectedCategoryIndex == 0
                  ? (newsProvider.latestNews.isEmpty
                      ? 1
                      : newsProvider.latestNews.length)
                  : (newsProvider.categoryNews.isEmpty
                      ? 1
                      : newsProvider.categoryNews.length),
        ),
      ),
    ];
  }

  // ChoiceChip yerine görsel ile uyumlu kategori tableri
  Widget _buildCategoryTabs(UnifiedNewsProvider newsProvider) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        final bool isSelected = index == _selectedCategoryIndex;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedCategoryIndex = index;
              _currentPage = 1; // Kategori değiştiğinde sayfa sayısını sıfırla
            });

            // Kategori id'si 0 ise (All) tüm haberleri getir, değilse kategoriye göre getir
            if (category['id'] == 0) {
              newsProvider.fetchLatestNews();
            } else {
              final categoryId = category['id'] as int;
              newsProvider.fetchNewsByCategory(categoryId);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: isSelected ? Colors.blue.shade600 : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            child: Text(
              category['name'].toString(),
              style: TextStyle(
                color: isSelected ? Colors.blue.shade600 : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults(UnifiedNewsProvider newsProvider) {
    if (newsProvider.searchResults.isEmpty) {
      return const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: Text('Arama sonucu bulunamadı')),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: NewsCard(
            news: newsProvider.searchResults[index],
            onTap: () {
              _navigateToNewsDetail(newsProvider.searchResults[index]);
            },
          ),
        );
      }, childCount: newsProvider.searchResults.length),
    );
  }
}
