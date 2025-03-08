import 'package:flutter/material.dart';
import '../models/topic_model.dart';

class TopicCard extends StatelessWidget {
  final TopicModel topic;
  final Function(int) onSaveTap;
  final VoidCallback onTap;

  const TopicCard({
    super.key,
    required this.topic,
    required this.onSaveTap,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
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
        child: Row(
          children: [
            // Konu ikonu
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  _getIconForTopic(topic.name),
                  color: Colors.blue.shade800,
                  size: 24,
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Konu bilgileri
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    topic.description,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Kaydet butonu
            TextButton(
              onPressed: () => onSaveTap(topic.id),
              style: TextButton.styleFrom(
                backgroundColor:
                    topic.isSaved ? Colors.blue.shade50 : Colors.grey.shade50,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                topic.isSaved ? 'Kaydedildi' : 'Kaydet',
                style: TextStyle(
                  color: topic.isSaved ? Colors.blue : Colors.grey[700],
                  fontWeight:
                      topic.isSaved ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForTopic(String topicName) {
    switch (topicName.toLowerCase()) {
      case 'sanatçılar':
        return Icons.music_note;
      case 'bilim adamları':
        return Icons.science;
      case 'yeni oyunlar':
        return Icons.games;
      case 'android':
        return Icons.android;
      case 'oyun':
        return Icons.sports_esports;
      case 'edebiyat':
        return Icons.book;
      case 'apple':
        return Icons.apple;
      case 'tiyatro':
        return Icons.theater_comedy;
      case 'seo ve arama':
        return Icons.search;
      case 'işadamları':
        return Icons.business;
      default:
        return Icons.topic;
    }
  }
}
