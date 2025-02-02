import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/repository.dart';

class SharedPrefsService {
  static const String _recentSearchesKey = 'recent_searches';
  static const String _favoriteReposKey = 'favorite_repos';

  // 🔹 Save recent searches
  Future<void> saveSearchHistory(List<String> searches) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_recentSearchesKey, searches);
  }

  // 🔹 Load recent searches
  Future<List<String>> getSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_recentSearchesKey) ?? [];
  }

  // 🔹 Save favorite repositories
  Future<void> saveFavoriteRepositories(List<Repository> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = favorites.map((repo) => jsonEncode(repo.toJson())).toList();
    await prefs.setStringList(_favoriteReposKey, jsonList);
  }

  // 🔹 Load favorite repositories
  Future<List<Repository>> getFavoriteRepositories() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_favoriteReposKey) ?? [];
    return jsonList.map((json) => Repository.fromJson(jsonDecode(json))).toList();
  }

  // 🔹 Clear all saved data (Optional)
  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_recentSearchesKey);
    await prefs.remove(_favoriteReposKey);
  }
}
