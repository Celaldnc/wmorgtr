import 'package:flutter/material.dart';
import '../models/topic_model.dart';

class AuthorCard extends StatelessWidget {
  final AuthorModel author;
  final Function(int) onFollowTap;
  final VoidCallback onTap;

  const AuthorCard({
    Key? key,
    required this.author,
    required this.onFollowTap,
    required this.onTap,
  }) : super(key: key);

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
            // Yazar avatarı
            CircleAvatar(
              radius: 25,
              backgroundImage: NetworkImage(author.avatarUrl),
            ),

            const SizedBox(width: 12),

            // Yazar bilgileri
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    author.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    author.bio,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${author.articleCount} makale',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),

            // Takip et butonu
            TextButton(
              onPressed: () => onFollowTap(author.id),
              style: TextButton.styleFrom(
                backgroundColor:
                    author.isFollowing
                        ? Colors.blue.shade50
                        : Colors.grey.shade50,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(
                author.isFollowing ? 'Takip Ediliyor' : 'Takip Et',
                style: TextStyle(
                  color: author.isFollowing ? Colors.blue : Colors.grey[700],
                  fontWeight:
                      author.isFollowing ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
