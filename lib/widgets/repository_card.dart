// lib/widgets/repository_card.dart
import 'package:flutter/material.dart';
import '../models/repository.dart';

class RepositoryCard extends StatelessWidget {
  final Repository repository;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final bool isFavorite;

  const RepositoryCard({
    Key? key,
    required this.repository,
    this.onTap,
    this.onFavoriteToggle,
    this.isFavorite = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Owner Avatar
              CircleAvatar(
                backgroundImage: NetworkImage(repository.ownerAvatarUrl),
                radius: 30,
              ),
              SizedBox(width: 12),
              // Repository Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      repository.fullName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      repository.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.star, size: 16, color: Colors.yellow[700]),
                        SizedBox(width: 4),
                        Text('${repository.stargazersCount}'),
                        SizedBox(width: 16),
                        Icon(Icons.call_split, size: 16),
                        SizedBox(width: 4),
                        Text('${repository.forksCount}'),
                      ],
                    )
                  ],
                ),
              ),
              // Favorite Icon (if applicable)
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : Colors.grey,
                ),
                onPressed: onFavoriteToggle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
