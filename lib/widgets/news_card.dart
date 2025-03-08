import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/news_model.dart';

class NewsCard extends StatefulWidget {
  final NewsModel news;
  final VoidCallback onTap;
  final bool isTrending;

  const NewsCard({
    super.key,
    required this.news,
    required this.onTap,
    this.isTrending = false,
  });

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isHovering = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.03,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHover(bool isHovering) {
    setState(() {
      _isHovering = isHovering;
    });
    if (isHovering) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color:
                          _isHovering
                              ? Colors.black.withOpacity(0.15)
                              : Colors.black.withOpacity(0.05),
                      blurRadius: _isHovering ? 12 : 8,
                      offset:
                          _isHovering ? const Offset(0, 4) : const Offset(0, 2),
                      spreadRadius: _isHovering ? 2 : 0,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Resim ve kategori etiketi
                      Stack(
                        children: [
                          // Resim
                          if (widget.news.featuredImageUrl.isNotEmpty)
                            Hero(
                              tag: 'news_image_${widget.news.id}',
                              child: CachedNetworkImage(
                                imageUrl: widget.news.featuredImageUrl,
                                height: widget.isTrending ? 180 : 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                placeholder:
                                    (context, url) => Container(
                                      height: widget.isTrending ? 180 : 150,
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                errorWidget:
                                    (context, url, error) => Container(
                                      height: widget.isTrending ? 180 : 150,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.error),
                                    ),
                              ),
                            ),

                          // Kategori etiketi
                          if (widget.news.categories.isNotEmpty)
                            Positioned(
                              top: 12,
                              left: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade600,
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  getCategoryName(widget.news.categories.first),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                          // Gradient overlay
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Colors.black.withOpacity(0.5),
                                  ],
                                  stops: const [0.7, 1.0],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // İçerik
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Başlık
                            Text(
                              widget.news.title,
                              style: TextStyle(
                                fontSize: widget.isTrending ? 18 : 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),

                            // Özet (excerpt) - Sadece trending olmayan kartlarda göster
                            if (!widget.isTrending &&
                                widget.news.excerpt.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(
                                  widget.news.excerpt,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),

                            const SizedBox(height: 12),

                            // Alt bilgiler (kaynak ve tarih)
                            Row(
                              children: [
                                // Kaynak logosu
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'WM',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),

                                // Kaynak adı
                                Expanded(
                                  child: Text(
                                    widget.news.source,
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 12,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),

                                // Tarih
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.access_time,
                                      size: 12,
                                      color: Colors.black54,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      widget.news.getFormattedDate(),
                                      style: const TextStyle(
                                        color: Colors.black54,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
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
          },
        ),
      ),
    );
  }

  // Kategori ID'sine göre kategori adını döndür
  String getCategoryName(int categoryId) {
    // Kategori ID'lerine göre isimler (gerçek uygulamada API'den alınacak)
    final Map<int, String> categoryNames = {
      1: 'Teknoloji',
      2: 'Bilim',
      3: 'Yazılım',
      4: 'Donanım',
      5: 'Mobil',
      6: 'Oyun',
      7: 'İnternet',
      8: 'Sosyal Medya',
      9: 'Güvenlik',
      10: 'Yapay Zeka',
      11: 'Avrupa',
      // Diğer kategoriler eklenebilir
    };

    return categoryNames[categoryId] ?? 'Genel';
  }
}
