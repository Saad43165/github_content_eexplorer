import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.deepPurpleAccent, Colors.blueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Header Row (Avatar and Name)
            Row(
              children: [
                Hero(
                  tag: 'avatar_${repository.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: SizedBox(
                      width: 48,
                      height: 48,
                      child: Image.network(
                        repository.ownerAvatarUrl,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.white,
                            child: Container(color: Colors.white),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // ✅ Repository Info with Title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        repository.fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

                // ✅ Favorite Button
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.redAccent : Colors.white70,
                    size: 28,
                  ),
                  onPressed: onFavoriteToggle,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ✅ Description (truncated if necessary)
            Text(
              repository.description.isNotEmpty
                  ? repository.description
                  : "No description available",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.85),
              ),
            ),
            const SizedBox(height: 10),

            // ✅ Stats Row (Stars, Forks, Language)
            Row(
              children: [
                _buildStat(Icons.star, Colors.amber, repository.stargazersCount),
                const SizedBox(width: 16),
                _buildStat(Icons.call_split, Colors.blueAccent, repository.forksCount),
                const SizedBox(width: 16),
                _buildLanguageBadge(repository.language ?? "Unknown"),
              ],
            ),
            const SizedBox(height: 8),

            // ✅ Dates (Created & Last Updated)
            Text(
              "Created: ${repository.createdAt}",
              style: TextStyle(fontSize: 12, color: Colors.grey[300]),
            ),
            Text(
              "Updated: ${repository.updatedAt}",
              style: TextStyle(fontSize: 12, color: Colors.grey[300]),
            ),

            // ✅ Share Button (Positioned at the bottom-right)
            Align(
              alignment: Alignment.bottomRight,
              child: IconButton(
                icon: const Icon(Icons.share, color: Colors.white70, size: 28),
                onPressed: () {
                  Share.share(
                      'Check out this repository: ${repository.fullName}\n${repository.htmlUrl}');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ Builds a stat row (Stars, Forks)
  Widget _buildStat(IconData icon, Color color, int count) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 6),
        Text(
          '$count',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ],
    );
  }

  /// ✅ Builds a language badge with dynamic color and full language name
  Widget _buildLanguageBadge(String language) {
    final Map<String, Color> languageColors = {
      'Dart': Colors.blue,
      'JavaScript': Colors.yellow[700]!,
      'Python': Colors.green,
      'Java': Colors.orange,
      'C++': Colors.purple,
      'Unknown': Colors.grey,
    };

    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: languageColors[language] ?? Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          language,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
