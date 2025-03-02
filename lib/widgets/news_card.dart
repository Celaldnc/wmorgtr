import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/news_model.dart';

class NewsCard extends StatelessWidget {
  final NewsModel news;
  final VoidCallback onTap;
  final bool isTrending;

  const NewsCard({
    Key? key,
    required this.news,
    required this.onTap,
    this.isTrending = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resim
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              child: CachedNetworkImage(
                imageUrl: news.featuredImageUrl,
                height: isTrending ? 180 : 150,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder:
                    (context, url) => Container(
                      height: isTrending ? 180 : 150,
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                errorWidget:
                    (context, url, error) => Container(
                      height: isTrending ? 180 : 150,
                      color: Colors.grey[300],
                      child: const Icon(Icons.error),
                    ),
              ),
            ),

            // İçerik
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kategori
                  if (news.categories.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        getCategoryName(
                          news.categories.first,
                        ), // Kategori adını al
                        style: TextStyle(
                          color: Colors.blue.shade800,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  const SizedBox(height: 8),

                  // Başlık
                  Text(
                    news.title,
                    style: TextStyle(
                      fontSize: isTrending ? 18 : 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Özet (excerpt) - Sadece trending olmayan kartlarda göster
                  if (!isTrending && news.excerpt.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        news.excerpt,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                  const SizedBox(height: 8),

                  // Alt bilgiler (kaynak ve tarih)
                  Row(
                    children: [
                      // Kaynak logosu ve adı
                      Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Center(
                              child: Text(
                                'WM',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            news.source,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),

                      // Tarih
                      const Spacer(),
                      Text(
                        news.getFormattedDate(),
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),

                      // İkincil butonlar
                      const SizedBox(width: 8),
                      Icon(Icons.more_horiz, size: 16, color: Colors.grey[600]),
                    ],
                  ),
                ],
              ),
            ),
          ],
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
