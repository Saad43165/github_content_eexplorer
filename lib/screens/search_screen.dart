// lib/screens/search_screen.dart
import 'package:flutter/material.dart';
import '../models/repository.dart';
import '../services/github_api_service.dart';
import '../widgets/repository_card.dart';
import 'details_screen.dart';

class SearchScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  const SearchScreen({Key? key, required this.toggleTheme}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final GithubApiService _apiService = GithubApiService();

  List<Repository> _repositories = [];
  bool _isLoading = false;
  String _errorMessage = '';
  final Set<int> _favoriteRepoIds = {};
  final List<String> _recentSearches = [];

  Future<void> _searchRepositories(String query) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _repositories = [];
    });

    try {
      final repos = await _apiService.searchRepositories(query);
      setState(() {
        _repositories = repos;
        // Add to recent searches if new and not empty.
        if (query.isNotEmpty && !_recentSearches.contains(query)) {
          _recentSearches.insert(0, query);
          if (_recentSearches.length > 5) _recentSearches.removeLast();
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isNotEmpty) {
      _searchRepositories(query.trim());
    }
  }

  void _toggleFavorite(Repository repo) {
    setState(() {
      if (_favoriteRepoIds.contains(repo.id)) {
        _favoriteRepoIds.remove(repo.id);
      } else {
        _favoriteRepoIds.add(repo.id);
      }
    });
  }

  void _showFavoritesBottomSheet() {
    final favoriteRepos =
    _repositories.where((repo) => _favoriteRepoIds.contains(repo.id)).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          constraints: BoxConstraints(
            minHeight: 200,
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          child: favoriteRepos.isEmpty
              ? Center(
            child: Text(
              'No favorites yet.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          )
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Text(
                'Your Favorites',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: favoriteRepos.length,
                  itemBuilder: (context, index) {
                    final repo = favoriteRepos[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(repo.ownerAvatarUrl),
                        ),
                        title: Text(
                          repo.fullName,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          repo.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailsScreen(repository: repo),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showRecentSearches() {
    if (_recentSearches.isEmpty) return;
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16),
          constraints: BoxConstraints(
            minHeight: 150,
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Text(
                'Recent Searches',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: _recentSearches.length,
                  itemBuilder: (context, index) {
                    final query = _recentSearches[index];
                    return ListTile(
                      leading: Icon(Icons.history),
                      title: Text(query),
                      onTap: () {
                        Navigator.pop(context);
                        _searchController.text = query;
                        _onSearchSubmitted(query);
                      },
                    );
                  },
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GitHub Explorer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Search Input Field
            TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Search Repositories',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onSubmitted: _onSearchSubmitted,
            ),
            SizedBox(height: 12),
            if (_isLoading)
              Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_errorMessage.isNotEmpty)
              Expanded(child: Center(child: Text(_errorMessage)))
            else if (_repositories.isEmpty)
                Expanded(child: Center(child: Text('No results. Enter a search query.')))
              else
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      if (_searchController.text.trim().isNotEmpty) {
                        _onSearchSubmitted(_searchController.text.trim());
                      }
                    },
                    child: ListView.builder(
                      itemCount: _repositories.length,
                      itemBuilder: (context, index) {
                        final repo = _repositories[index];
                        return RepositoryCard(
                          repository: repo,
                          isFavorite: _favoriteRepoIds.contains(repo.id),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DetailsScreen(repository: repo),
                              ),
                            );
                          },
                          onFavoriteToggle: () => _toggleFavorite(repo),
                        );
                      },
                    ),
                  ),
                ),
          ],
        ),
      ),
      // New Bottom Bar with History, Favorites, and Dark Mode Buttons
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BottomAppBar(
          color: Colors.indigoAccent,
          shape: CircularNotchedRectangle(),
          elevation: 8,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  tooltip: 'Recent Searches',
                  icon: Icon(Icons.history, size: 28),
                  onPressed: _showRecentSearches,
                ),
                IconButton(
                  tooltip: 'Favorites',
                  icon: Icon(Icons.favorite, size: 28),
                  onPressed: _showFavoritesBottomSheet,
                ),
                IconButton(
                  tooltip: 'Toggle Theme',
                  icon: Icon(Icons.brightness_6, size: 28),
                  onPressed: widget.toggleTheme,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
