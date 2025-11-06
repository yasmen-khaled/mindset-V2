class Task {
  final int id;
  final int categoryId;
    final int stars;

  final String title;
  final String description;
  final String? hint;

  bool completed;
  bool unlocked;

  final String? videoUrl;
  final String? image;
    final String? avatar;


  Task({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.description,
    required this.hint,
    required this.completed,
    required this.unlocked,
    required this.stars,
    required this.image,
        required this.avatar,

    this.videoUrl,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      categoryId: json['category_id'],
            stars: json['stars'],

      title: json['title'],
      description: json['description'],
      hint: json['hint'],

      completed: json['completed'],
      unlocked: json['unlocked'],

      videoUrl: json['video_url'],
      image: json['image'],
            avatar: json['avatar'],

    );
  }
}
