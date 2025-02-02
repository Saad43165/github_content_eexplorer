import 'package:flutter/material.dart';
import '../models/repository.dart';
import '../services/github_api_service.dart';

class RepositoryProvider extends ChangeNotifier {
  final GithubApiService _apiService = GithubApiService();

  List<Repository> _repositories = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _selectedFilter = 'Repository Name';

  List<Repository> get repositories => _repositories;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get selectedFilter => _selectedFilter;

  void setFilter(String filter) {
    _selectedFilter = filter;
    notifyListeners();
  }

  Future<void> searchRepositories(String query) async {
    if (query.trim().isEmpty) return;

    _isLoading = true;
    _errorMessage = '';
    _repositories = [];
    notifyListeners();

    try {
      final results = await _apiService.searchRepositories(query, filter: _selectedFilter, sort: '');
      _repositories = results;
    } catch (e) {
      _errorMessage = 'Error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
