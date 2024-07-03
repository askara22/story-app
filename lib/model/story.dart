class Story {
  final String id;
  final String name;
  final String description;
  final String photoUrl;
  final String createdAt;

  Story({
    required this.id,
    required this.name,
    required this.description,
    required this.photoUrl,
    required this.createdAt,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      photoUrl: json['photoUrl'],
      createdAt: json['createdAt'],
    );
  }
}
