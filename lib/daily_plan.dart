class DailyPlan {
  final int? id;
  final String title;
  final String desc;
  final String startTime;
  final String finishTime;
  final String weekday;

  DailyPlan({
    this.id,
    required this.title,
    required this.desc,
    required this.startTime,
    required this.finishTime,
    required this.weekday,
  });

  factory DailyPlan.fromMap(Map<String, dynamic> json) => DailyPlan(
    id: json['id'],
    title: json['title'],
    desc: json['desc'],
    startTime: json['startTime'],
    finishTime: json['finishTime'],
    weekday: json['weekday'] ?? '',
  );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'desc': desc,
      'startTime': startTime,
      'finishTime': finishTime,
      'weekday': weekday,
    };
  }
}
