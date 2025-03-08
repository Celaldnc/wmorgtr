import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../widgets/post_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    final newsProvider = Provider.of<NewsProvider>(context, listen: false);
    newsProvider.searchPosts(query).then((_) {
      setState(() {
        _isSearching = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Arama yapın...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: TextStyle(color: Colors.white),
          textInputAction: TextInputAction.search,
          onSubmitted: _performSearch,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () => _performSearch(_searchController.text),
          ),
        ],
      ),
      body:
          _isSearching
              ? Center(child: CircularProgressIndicator())
              : Consumer<NewsProvider>(
                builder: (context, newsProvider, child) {
                  if (newsProvider.error.isNotEmpty) {
                    return Center(child: Text('Hata: ${newsProvider.error}'));
                  }

                  if (newsProvider.searchResults.isEmpty) {
                    return Center(child: Text('Haber bulunamadı, arama yapın'));
                  }

                  return ListView.builder(
                    itemCount: newsProvider.searchResults.length,
                    itemBuilder: (context, index) {
                      final post = newsProvider.searchResults[index];
                      return PostCard(post: post);
                    },
                  );
                },
              ),
    );
  }
}
