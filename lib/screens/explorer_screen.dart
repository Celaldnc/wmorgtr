import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/explorer_provider.dart';
import '../widgets/topic_card.dart';
import '../widgets/author_card.dart';
import '../widgets/news_card.dart';
import '../models/news_model.dart';
import '../screens/news_detail_screen.dart';
import '../screens/topic_news_screen.dart';

class ExplorerScreen extends StatefulWidget {
  const ExplorerScreen({super.key});

  @override
  State<ExplorerScreen> createState() => _ExplorerScreenState();
}

class _ExplorerScreenState extends State<ExplorerScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showCategories = false;
  String _selectedCategory = 'Tümü';

  final List<String> _categories = [
    'Tümü',
    'Android',
    'Apple',
    'ASUS',
    'Bilim Adamları',
    'Edebiyat',
    'Oyun',
    'Teknoloji',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.offset > 100 && !_showCategories) {
      setState(() => _showCategories = true);
    } else if (_scrollController.offset <= 100 && _showCategories) {
      setState(() => _showCategories = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [
            // Arama çubuğu
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Konu ara...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => _searchController.clear(),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                ),
              ),
            ),

            // Tab Bar ve içerik
            Expanded(
              child: DefaultTabController(
                length: 3,
                child: NestedScrollView(
                  headerSliverBuilder: (context, innerBoxIsScrolled) {
                    return [
                      // Kategori AppBar
                      SliverAppBar(
                        pinned: true,
                        floating: true,
                        backgroundColor: Colors.white,
                        elevation: innerBoxIsScrolled ? 4 : 0,
                        automaticallyImplyLeading: false,
                        title: Container(
                          height: 40,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: _categories.length,
                            itemBuilder: (context, index) {
                              final category = _categories[index];
                              return _buildCategoryChip(
                                category,
                                category == _selectedCategory,
                              );
                            },
                          ),
                        ),
                        toolbarHeight: 56,
                      ),

                      // Tab Bar
                      SliverPersistentHeader(
                        delegate: _SliverAppBarDelegate(
                          TabBar(
                            controller: _tabController,
                            labelColor: Colors.blue,
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: Colors.blue,
                            tabs: const [
                              Tab(text: 'Konular'),
                              Tab(text: 'Yazarlar'),
                              Tab(text: 'Kaydedilenler'),
                            ],
                          ),
                        ),
                        pinned: true,
                      ),
                    ];
                  },
                  body: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildTopicsTab(),
                      const _AuthorsTab(),
                      const _SavedTab(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (bool selected) {
          if (selected) {
            setState(() {
              _selectedCategory = label;
            });
            // Provider üzerinden haberleri filtrele
            context.read<ExplorerProvider>().filterNewsByCategory(label);
          }
        },
        selectedColor: Colors.blue.shade100,
        labelStyle: TextStyle(
          color: isSelected ? Colors.blue.shade800 : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildTopicsTab() {
    return Consumer<ExplorerProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error.isNotEmpty) {
          return Center(
            child: Text(
              provider.error,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.topics.length,
          itemBuilder: (context, index) {
            final topic = provider.topics[index];
            return TopicCard(
              topic: topic,
              onSaveTap: (id) => provider.toggleSaveTopic(id),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => TopicNewsScreen(
                          topicId: topic.id,
                          topicName: topic.name,
                        ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _AuthorsTab extends StatelessWidget {
  const _AuthorsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExplorerProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error.isNotEmpty) {
          return Center(
            child: Text(
              provider.error,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.authors.length,
          itemBuilder: (context, index) {
            final author = provider.authors[index];
            return AuthorCard(
              author: author,
              onFollowTap: (id) => provider.toggleFollowAuthor(id),
              onTap: () {
                // Yazar detay sayfasına git
              },
            );
          },
        );
      },
    );
  }
}

class _SavedTab extends StatelessWidget {
  const _SavedTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ExplorerProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error.isNotEmpty) {
          return Center(
            child: Text(
              provider.error,
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (provider.savedNews.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bookmark_border, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Henüz kaydedilmiş haber yok',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Haberleri kaydetmek için "Kaydet" butonuna tıklayın',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.savedNews.length,
          itemBuilder: (context, index) {
            final news = provider.savedNews[index];
            return NewsCard(
              news: news,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => NewsDetailScreen(
                          newsId: news.id,
                          initialNews: news,
                        ),
                  ),
                );
              },
              isTrending: false,
            );
          },
        );
      },
    );
  }
}

// SliverPersistentHeader için delegate sınıfı
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
