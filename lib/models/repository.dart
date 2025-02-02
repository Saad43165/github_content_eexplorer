class Repository {
  final int id;
  final String name;
  final String fullName;
  final String description;
  final int stargazersCount;
  final int forksCount;
  final String ownerAvatarUrl;
  final String ownerLogin;
  final String? language;

  Repository({
    required this.id,
    required this.name,
    required this.fullName,
    required this.description,
    required this.stargazersCount,
    required this.forksCount,
    required this.ownerAvatarUrl,
    required this.ownerLogin,
    this.language,
  });

  // 🔹 Convert JSON to Repository
  factory Repository.fromJson(Map<String, dynamic> json) {
    return Repository(
      id: json['id'],
      name: json['name'],
      fullName: json['full_name'],
      description: json['description'] ?? 'No description available',
      stargazersCount: json['stargazers_count'],
      forksCount: json['forks_count'],
      ownerAvatarUrl: json['owner']['avatar_url'],
      ownerLogin: json['owner']['login'],
      language: json['language'],
    );
  }

  // 🔹 Convert Repository to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'full_name': fullName,
      'description': description,
      'stargazers_count': stargazersCount,
      'forks_count': forksCount,
      'owner': {
        'avatar_url': ownerAvatarUrl,
        'login': ownerLogin,
      },
      'language': language,
    };
  }
}
