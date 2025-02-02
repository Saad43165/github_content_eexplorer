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
  final ScrollController _scrollController = ScrollController();

  List<Repository> _repositories = [];
  bool _isLoading = false;
  String _errorMessage = '';
  final Set<int> _favoriteRepoIds = {};
  final List<String> _recentSearches = [];
  String _selectedFilter = 'Repository Name';
  final List<Repository> _favoriteRepositories = [];
  int _page = 1; // Start with page 1 for pagination
  bool _hasMore = true; // Flag to check if there are more results to load

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener); // Add listener for infinite scroll
  }

  void _scrollListener() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && _hasMore) {
      _loadMoreResults(); // Load more data when user reaches the bottom
    }
  }

  Future<void> _loadMoreResults() async {
    if (_isLoading) return; // Avoid multiple requests at the same time
    setState(() {
      _isLoading = true;
    });

    try {
      final repos = await _apiService.searchRepositories(
        _searchController.text,
        filter: _selectedFilter,
        sort: '',
        page: _page + 1, // Fetch next page
      );
      setState(() {
        _repositories.addAll(repos);
        _page++; // Increment page number
        if (repos.isEmpty) {
          _hasMore = false; // No more results to load
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

  Future<void> _searchRepositories(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _repositories = [];
      _favoriteRepoIds.clear(); // Reset favorite repositories on new search
      _favoriteRepositories.clear(); // Reset favorites list
      _hasMore = true;
      _page = 1; // Reset to page 1
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
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        margin: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: _selectedFilter == filter ? Colors.blueAccent : Colors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: Colors.blueAccent, width: 2),
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
            children: <Widget>[
              const SizedBox(height: 60),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
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
              const SizedBox(height: 13),
              if (_isLoading)
                const Expanded(child: Center(child: CircularProgressIndicator()))
              else if (_errorMessage.isNotEmpty)
                Expanded(child: Center(child: Text(_errorMessage, style: TextStyle(color: Colors.redAccent))))
              else if (_repositories.isEmpty)
                  const Expanded(child: Center(child: Text('No results found. Try searching something.')))
                else
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
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
        bottomNavigationBar: ClipRRect(
          borderRadius: BorderRadius.circular(20), // Rounded corners for circular effect
          child: BottomAppBar(
            color: Colors.transparent, // Make the background transparent for gradient
            elevation: 20, // Adds shadow effect
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.indigo], // Gradient colors
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20), // Ensures the curve matches the app bar
              ),
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


      ),
    );
  }
}