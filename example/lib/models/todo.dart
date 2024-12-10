/// A model class representing a Todo item.
///
/// The `Todo` class is used to model a todo item retrieved from an API or
/// created within the application. It includes properties such as an ID,
/// user ID, title, and completion status.
class Todo {
  /// Creates an instance of `Todo`.
  ///
  /// The constructor initializes the `Todo` object with the required parameters.
  ///
  /// *Parameters:*
  /// - `id`: The unique identifier for the todo item.
  /// - `userID`: The identifier of the user to whom this todo item belongs.
  /// - `title`: The title or description of the todo item.
  /// - `isCompleted`: A boolean indicating whether the todo item has been completed.
  Todo({
    required this.id,
    required this.userID,
    required this.title,
    required this.isCompleted,
  });

  /// The unique identifier for the todo item.
  final int id;

  /// The identifier of the user to whom this todo item belongs.
  final int userID;

  /// The title or description of the todo item.
  final String title;

  /// A boolean indicating whether the todo item has been completed.
  final bool isCompleted;

  /// Creates a `Todo` instance from a JSON object.
  ///
  /// The `fromJson` factory method is used to create a `Todo` object from
  /// a JSON map. It extracts the relevant fields from the JSON and returns
  /// an instance of `Todo`.
  ///
  /// *Parameters:*
  /// - `json`: A `Map<String, dynamic>` representing the JSON object.
  ///
  /// *Returns:* 
  /// - A `Todo` object initialized with the values from the JSON map.
  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['id'] as int,
      userID: json['userId'] as int,
      title: json['title'] as String,
      isCompleted: json['completed'] as bool,
    );
  }
}
