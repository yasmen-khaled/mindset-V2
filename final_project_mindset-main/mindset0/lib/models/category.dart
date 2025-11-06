class Category {
  final int id;
  final String name;
  final int level;
  final double progress;
  final int stars;
  final bool unlocked;   
    final String? image;
 final bool completed; 

  Category({
    required this.id,
    required this.name,
    required this.level,
    required this.progress,
    required this.stars,
     required this.unlocked,
       required this.image, 
   required this.completed,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      level: json['level'],
      progress: (json['progress'] as num).toDouble(),
      stars: json['stars'],
      image: json['image'],
      
       unlocked: json['unlocked'] ?? false,    
      completed: json['completed'] ?? false, 
    );
  }
}
