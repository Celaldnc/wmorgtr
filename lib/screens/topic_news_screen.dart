import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/explorer_provider.dart';
import '../widgets/news_card.dart';
import '../models/news_model.dart';
import '../screens/news_detail_screen.dart';

class TopicNewsScreen extends StatefulWidget {
  final int topicId;
  final String topicName;

  const TopicNewsScreen({
    super.key,
    required this.topicId,
    required this.topicName,
  });

  @override
  State<TopicNewsScreen> createState() => _TopicNewsScreenState();
}

class _TopicNewsScreenState extends State<TopicNewsScreen> {
  List<NewsModel> _news = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadNews();
  }

  Future<void> _loadNews() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final provider = Provider.of<ExplorerProvider>(context, listen: false);
      final news = await provider.getNewsByTopic(widget.topicId);

      setState(() {
        _news = news;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Haberler yüklenirken bir hata oluştu: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.topicName), elevation: 0),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _error.isNotEmpty
              ? _buildErrorView()
              : _buildNewsListView(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          Text(
            _error,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadNews,
            child: const Text('Tekrar Dene'),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsListView() {
    if (_news.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.article_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Bu kategoride haber bulunamadı',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _news.length,
      itemBuilder: (context, index) {
        final news = _news[index];
        return NewsCard(
          news: news,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        NewsDetailScreen(newsId: news.id, initialNews: news),
              ),
            );
          },
          isTrending: false,
        );
      },
    );
  }
}
