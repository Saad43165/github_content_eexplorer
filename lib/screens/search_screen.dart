import 'package:flutter/material.dart';
import '../models/repository.dart';
import '../services/github_api_service.dart';
import '../widgets/repository_card.dart';
import 'details_screen.dart';

class SearchScreen extends StatefulWidget {
  final VoidCallback toggleTheme;
  const SearchScreen({super.key, required this.toggleTheme});

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
  String _selectedFilter = 'Repository Name';
  final List<Repository> _favoriteRepositories = [];

  Future<void> _searchRepositories(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _repositories = [];
    });

    try {
      final repos = await _apiService.searchRepositories(query, filter: _selectedFilter, sort: '');
      setState(() {
        _repositories = repos;
        if (!_recentSearches.contains(query)) {
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

  void _toggleFavorite(Repository repo) {
    setState(() {
      if (_favoriteRepoIds.contains(repo.id)) {
        _favoriteRepoIds.remove(repo.id);
        _favoriteRepositories.removeWhere((item) => item.id == repo.id);
      } else {
        _favoriteRepoIds.add(repo.id);
        _favoriteRepositories.add(repo);
      }
    });
  }

  Widget _buildFilterButton(String filter) {
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = filter),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: _selectedFilter == filter ? Colors.blueAccent : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.blueAccent),
          boxShadow: [
            if (_selectedFilter == filter)
              BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 8, spreadRadius: 2),
          ],
        ),
        child: Text(
          filter,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _selectedFilter == filter ? Colors.white : Colors.blueAccent,
          ),
        ),
      ),
    );
  }

  void _showRecentSearches() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: _recentSearches
              .map(
                (query) => ListTile(
              title: Text(query),
              trailing: const Icon(Icons.search, color: Colors.blueAccent),
              onTap: () {
                _searchController.text = query;
                _searchRepositories(query);
                Navigator.pop(context);
              },
            ),
          )
              .toList(),
        );
      },
    );
  }

  void _showFavorites() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: _favoriteRepositories.isEmpty
              ? [const Center(child: Text('No favorites yet.'))]
              : _favoriteRepositories
              .map(
                (repo) => RepositoryCard(
              repository: repo,
              isFavorite: _favoriteRepoIds.contains(repo.id),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DetailsScreen(repository: repo)),
              ),
              onFavoriteToggle: () => _toggleFavorite(repo),
            ),
          )
              .toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text('GitHub Explorer', style: TextStyle(fontWeight: FontWeight.bold)),
          centerTitle: true,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blueAccent, Colors.indigoAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                ),
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Search GitHub...',
                    prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                  onSubmitted: _searchRepositories,
                ),
              ),
              const SizedBox(height: 16),
              if (_recentSearches.isNotEmpty)
                Wrap(
                  children: _recentSearches
                      .map((query) => GestureDetector(
                    onTap: () => _searchRepositories(query),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(query),
                    ),
                  ))
                      .toList(),
                ),
              const SizedBox(height: 16),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildFilterButton('Repository Name'),
                    _buildFilterButton('Programming Language'),
                    _buildFilterButton('Owner Account Name'),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (_isLoading)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else if (_errorMessage.isNotEmpty)
                Expanded(child: Center(child: Text(_errorMessage, style: TextStyle(color: Colors.redAccent))))
              else if (_repositories.isEmpty)
                  const Expanded(child: Center(child: Text('No results found. Try searching something.')))
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: _repositories.length,
                      itemBuilder: (context, index) {
                        final repo = _repositories[index];
                        return RepositoryCard(
                          repository: repo,
                          isFavorite: _favoriteRepoIds.contains(repo.id),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => DetailsScreen(repository: repo)),
                          ),
                          onFavoriteToggle: () => _toggleFavorite(repo),
                        );
                      },
                    ),
                  ),
            ],
          ),
        ),

        bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(), // Adds a notch for FAB if needed
          color: Colors.blueAccent, // Makes it stand out
          elevation: 10, // Adds depth effect
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12), // Adds spacing for better touch
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: const Icon(Icons.history, color: Colors.white, size: 28),
                  onPressed: _showRecentSearches,
                  tooltip: 'Search History',
                ),
                IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.white, size: 28),
                  onPressed: _showFavorites,
                  tooltip: 'Favorites',
                ),
                IconButton(
                  icon: const Icon(Icons.brightness_6, color: Colors.white, size: 28),
                  onPressed: widget.toggleTheme,
                  tooltip: 'Toggle Theme',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
