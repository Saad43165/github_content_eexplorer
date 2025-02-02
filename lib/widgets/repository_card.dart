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
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          gradient: LinearGradient(
            colors: [Colors.indigo.withOpacity(0.6), Colors.blue.withOpacity(0.4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 10,
              spreadRadius: 3,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ✅ Owner Avatar with Hero Animation & Shimmer Effect
            Hero(
              tag: 'avatar_${repository.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: SizedBox(
                  width: 64,
                  height: 64,
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
            const SizedBox(width: 12),

            // ✅ Repository Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ✅ Repository Name
                  Text(
                    repository.fullName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // ✅ Description
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
                  const SizedBox(height: 8),

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
                  const SizedBox(height: 6),

                  // ✅ Dates (Created & Last Updated)
                  Text(
                    "Created: ${repository.createdAt}",
                    style: TextStyle(fontSize: 12, color: Colors.grey[300]),
                  ),
                  Text(
                    "Updated: ${repository.updatedAt}",
                    style: TextStyle(fontSize: 12, color: Colors.grey[300]),
                  ),
                ],
              ),
            ),

            // ✅ Favorite & Share Buttons
            Column(
              children: [
                // Favorite Button with Animated Toggle
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: IconButton(
                    key: ValueKey<bool>(isFavorite),
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.redAccent : Colors.white70,
                      size: 28,
                    ),
                    onPressed: onFavoriteToggle,
                  ),
                ),
                // Share Button
                IconButton(
                  icon: const Icon(Icons.share, color: Colors.white70),
                  onPressed: () {
                    Share.share('Check out this repository: ${repository.fullName}\n${repository.htmlUrl}');
                  },
                ),
              ],
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
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 4),
        Text(
          '$count',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ],
    );
  }

  /// ✅ Builds a language badge with dynamic color
  Widget _buildLanguageBadge(String language) {
    final Map<String, Color> languageColors = {
      'Dart': Colors.blue,
      'JavaScript': Colors.yellow[700]!,
      'Python': Colors.green,
      'Java': Colors.orange,
      'C++': Colors.purple,
      'Unknown': Colors.grey,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: languageColors[language] ?? Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        language,
        style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }
}
