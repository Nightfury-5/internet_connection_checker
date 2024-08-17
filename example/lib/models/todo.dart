class Todo {
  Todo({
    required this.id,
    required this.userID,
    required this.title,
    required this.isCompleted,
  });

  final int id;
  final int userID;
  final String title;
  final bool isCompleted;

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as int,
      userID: json['userId'] as int,
      title: json['title'] as String,
      isCompleted: json['completed'] as bool,
    );
  }
}
