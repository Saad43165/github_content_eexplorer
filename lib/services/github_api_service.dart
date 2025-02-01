// lib/services/github_api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/repository.dart';

class GithubApiService {
  final String baseUrl = 'https://api.github.com';

  // Search repositories based on a query
  Future<List<Repository>> searchRepositories(String query, {int page = 1}) async {
    final url = '$baseUrl/search/repositories?q=$query&sort=stars&order=desc&page=$page';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List items = data['items'];
      return items.map((item) => Repository.fromJson(item)).toList();
    } else {
      throw Exception('Error fetching repositories: ${response.reasonPhrase}');
    }
  }
}
