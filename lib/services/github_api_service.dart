import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/repository.dart';

class GithubApiService {
  final String baseUrl = 'https://api.github.com';

  Future<List<Repository>> searchRepositories(String query, {int page = 1, required String filter, required String sort}) async {
    String url = '';

    if (filter == 'Repository Name') {
      url = '$baseUrl/search/repositories?q=$query+in:name&sort=stars&order=desc&page=$page';
    } else if (filter == 'Programming Language') {
      url = '$baseUrl/search/repositories?q=language:$query&sort=stars&order=desc&page=$page';
    } else if (filter == 'Owner Account Name') {
      url = '$baseUrl/search/repositories?q=user:$query&page=$page';
    }

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
