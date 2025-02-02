class Repository {
  final int id;
  final String name;
  final String fullName;
  final String description;
  final int stargazersCount;
  final int forksCount;
  final String ownerAvatarUrl;
  final String ownerLogin;
  final String ownerName; // Added field for owner name
  final String? language;
  final String htmlUrl; // ✅ Repository URL
  final String createdAt; // ✅ Repository Creation Date
  final String updatedAt; // ✅ Last Updated Date

  Repository({
    required this.id,
    required this.name,
    required this.fullName,
    required this.description,
    required this.stargazersCount,
    required this.forksCount,
    required this.ownerAvatarUrl,
    required this.ownerLogin,
    required this.ownerName, // Added owner name
    this.language,
    required this.htmlUrl, // ✅ Repository URL
    required this.createdAt, // ✅ Repository Creation Date
    required this.updatedAt, // ✅ Last Updated Date
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
      ownerName: json['owner']['name'] ?? 'Unknown', // Handle null case by providing default value
      language: json['language'],
      htmlUrl: json['html_url'], // ✅ Repository URL
      createdAt: json['created_at'] ?? '', // ✅ Repository Creation Date
      updatedAt: json['updated_at'] ?? '', // ✅ Last Updated Date
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
        'name': ownerName, // Include owner name
      },
      'language': language,
      'html_url': htmlUrl, // ✅ Include Repository URL
      'created_at': createdAt, // ✅ Include Created Date
      'updated_at': updatedAt, // ✅ Include Updated Date
    };
  }
}
