part of 'fetch_todos_cubit.dart';

/// The base state class for `FetchTodosCubit`.
///
/// All states emitted by `FetchTodosCubit` extend from this sealed class.
/// It is marked as immutable to ensure that state objects are not modified
/// after they are created.
@immutable
sealed class FetchTodosState {}

/// The initial state for `FetchTodosCubit`.
///
/// This state is emitted when the cubit is first created and no action
/// has been taken yet. It represents the starting point of the state
/// machine before any todos have been fetched.
final class FetchTodosInitial extends FetchTodosState {}

/// The loading state for `FetchTodosCubit`.
///
/// This state is emitted when the cubit is in the process of fetching
/// todos from the remote API. It indicates that a fetch operation
/// is currently ongoing and the results are pending.
final class FetchTodosLoading extends FetchTodosState {}

/// The empty state for `FetchTodosCubit`.
///
/// This state is emitted when the fetch operation completes successfully,
/// but the response does not contain any todos. It indicates that the
/// server returned an empty list of todos.
final class FetchTodosEmpty extends FetchTodosState {}

/// The success state for `FetchTodosCubit`.
///
/// This state is emitted when the fetch operation completes successfully
/// and the server returns a non-empty list of todos. It contains the list
/// of todos and a flag indicating whether the fetch was a retry operation.
///
/// *Properties:*
/// — `todos`: A list of `Todo` objects representing the fetched todos.
/// - `isRetry`: A boolean flag indicating whether the fetch operation was a retry.
final class FetchTodosSuccess extends FetchTodosState {
  final List<Todo> todos;
  final bool isRetry;

  /// Creates an instance of `FetchTodosSuccess`.
  ///
  /// *Parameters:*
  /// - `todos`: A required list of `Todo` objects representing the fetched todos.
  /// - `isRetry`: A required boolean flag indicating whether the fetch operation was a retry.
  FetchTodosSuccess({
    required this.todos,
    required this.isRetry,
  });
}

/// The error state for `FetchTodosCubit`.
///
/// This state is emitted when an error occurs during the fetch operation.
/// It contains the exception that was thrown, providing details about the
/// error that occurred.
///
/// *Properties:*
/// — `exception`: An `Exception` object representing the error that occurred during the fetch operation.
final class FetchTodosError extends FetchTodosState {
  final Exception exception;

  /// Creates an instance of `FetchTodosError`.
  ///
  /// *Parameters:*
  /// - `exception`: A required `Exception` object representing the error that occurred during the fetch operation.
  FetchTodosError({
    required this.exception,
  });
}
