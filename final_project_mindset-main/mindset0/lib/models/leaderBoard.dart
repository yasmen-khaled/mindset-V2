class LeaderboardUser {
  final String name;
  final int stars;
  final double  score;
  final int level;
  final String rank;
  final String avatar;
  final int problemsSolved;
  final int daysStreak;
  final List<String> achievements;

  LeaderboardUser({
    required this.name,
    required this.stars,
    this.score = 0,
    required this.level,
    this.rank = 'Beginner',            
    this.avatar = 'Assets/items/default_avatar.svg', // مسار افتراضي
    this.problemsSolved = 0,
    this.daysStreak = 0,
    this.achievements = const [],
  });
factory LeaderboardUser.fromJson(Map<String, dynamic> json) {
  print('Parsing LeaderboardUser from JSON: $json');

  final name = json['name'] ?? '';
  print('name: $name');

  final starsRaw = json['stars'];
  print('stars raw: $starsRaw');
  final stars = starsRaw is int
      ? starsRaw
      : int.tryParse(starsRaw.toString()) ?? 0;
  print('stars parsed: $stars');

 final scoreRaw = json['score'];
    print('score raw: $scoreRaw');
    final score = scoreRaw is double
        ? scoreRaw
        : double.tryParse(scoreRaw?.toString() ?? '0') ?? 0.0;
    print('score parsed: $score');

  final levelRaw = json['level'];
  print('level raw: $levelRaw');
  final level = levelRaw is int
      ? levelRaw
      : int.tryParse(levelRaw.toString()) ?? 0;
  print('level parsed: $level');

  final rank = json['rank'] ?? 'Beginner';
  print('rank: $rank');

  final avatar = json['avatar'] ?? 'Assets/items/default_avatar.svg';
  print('avatar: $avatar');

  final problemsSolvedRaw = json['problemsSolved'];
  print('problemsSolved raw: $problemsSolvedRaw');
  final problemsSolved = problemsSolvedRaw is int
      ? problemsSolvedRaw
      : int.tryParse(problemsSolvedRaw?.toString() ?? '0') ?? 0;
  print('problemsSolved parsed: $problemsSolved');

  final daysStreakRaw = json['heart'];
  print('daysStreak raw: $daysStreakRaw');
  final daysStreak = daysStreakRaw is int
      ? daysStreakRaw
      : int.tryParse(daysStreakRaw?.toString() ?? '0') ?? 0;
  print('daysStreak parsed: $daysStreak');

  final achievementsRaw = json['achievements'];
  print('achievements raw: $achievementsRaw');
  final achievements = (achievementsRaw is List)
      ? achievementsRaw.whereType<String>().toList()
      : <String>[];
  print('achievements parsed: $achievements');

  return LeaderboardUser(
    name: name,
    stars: stars,
    score: score,
    level: level,
    rank: rank,
    avatar: avatar,
    problemsSolved: problemsSolved,
    daysStreak: daysStreak,
    achievements: achievements,
  );
}

}

/*class LeaderboardUser {
  final String name;
  final int stars;
  final int score;
  final int level;

  LeaderboardUser({
    required this.name,
    required this.stars,
    required this.score,
    required this.level,
  });

  factory LeaderboardUser.fromJson(Map<String, dynamic> json) {
    return LeaderboardUser(
      name: json['name'],
      stars: json['stars'],
      score: json['score'],
      level: json['level'],
    );
  }
}*/

/*
class LeaderboardUser {
  final String name;
  final int stars;
  final int level;
  final String rank;
  final String avatar;
  final int problemsSolved;
  final int daysStreak;
  final List<String> achievements;

  LeaderboardUser({
    required this.name,
    required this.stars,
    required this.level,
    required this.rank,
    required this.avatar,
    this.problemsSolved = 0,
    this.daysStreak = 0,
    this.achievements = const [],
  });
}


*/