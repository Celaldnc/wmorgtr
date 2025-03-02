class TopicModel {
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final bool isSaved;
  final int count;

  TopicModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    this.isSaved = false,
    this.count = 0,
  });

  TopicModel copyWith({
    int? id,
    String? name,
    String? description,
    String? imageUrl,
    bool? isSaved,
    int? count,
  }) {
    return TopicModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isSaved: isSaved ?? this.isSaved,
      count: count ?? this.count,
    );
  }
}

class AuthorModel {
  final int id;
  final String name;
  final String avatarUrl;
  final String bio;
  final int articleCount;
  final bool isFollowing;

  AuthorModel({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.bio,
    this.articleCount = 0,
    this.isFollowing = false,
  });

  AuthorModel copyWith({
    int? id,
    String? name,
    String? avatarUrl,
    String? bio,
    int? articleCount,
    bool? isFollowing,
  }) {
    return AuthorModel(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      articleCount: articleCount ?? this.articleCount,
      isFollowing: isFollowing ?? this.isFollowing,
    );
  }
}
