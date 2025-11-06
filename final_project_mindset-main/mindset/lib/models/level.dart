class Level {
  final int id;
  final int order;
  final String title;
  final bool unlocked;

  Level({
    required this.id,
    required this.order,
    required this.title,
    required this.unlocked,
  });

  factory Level.fromJson(Map<String, dynamic> json) {
    return Level(
      id: json['id'],
      order: json['order'],
      title: json['title'] ?? '',
      unlocked: json['unlocked'] ?? false,
    );
  }
}
