import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../widgets/post_card.dart';

class CategoryScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  CategoryScreen({required this.categoryId, required this.categoryName});

  @override
  _CategoryScreenState createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NewsProvider>(context, listen: false)
          .loadPostsByCategory(widget.categoryId, refresh: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
      ),
      body: Consumer<NewsProvider>(
        builder: (context, newsProvider, child) {
          if (newsProvider.isLoading && newsProvider.categoryPosts.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }

          if (newsProvider.error.isNotEmpty && newsProvider.categoryPosts.isEmpty) {
            return Center(
              child: Text('Hata: ${newsProvider.error}'),
            );
          }

          if (newsProvider.categoryPosts.isEmpty) {
            return Center(
              child: Text('Bu kategoride haber bulunamadı'),
            );
          }

          return RefreshIndicator(
            onRefresh: () => newsProvider.loadPostsByCategory(widget.categoryId, refresh: true),
            child: ListView.builder(
              itemCount: newsProvider.categoryPosts.length,
              itemBuilder: (context, index) {
                final post = newsProvider.categoryPosts[index];
                return PostCard(post: post);
              },
            ),
          );
        },
      ),
    );
  }
} 