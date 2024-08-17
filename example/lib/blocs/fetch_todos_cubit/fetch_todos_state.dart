part of 'fetch_todos_cubit.dart';

@immutable
sealed class FetchTodosState {}

final class FetchTodosInitial extends FetchTodosState {}

final class FetchTodosLoading extends FetchTodosState {}

final class FetchTodosEmpty extends FetchTodosState {}

final class FetchTodosSuccess extends FetchTodosState {
  final List<Todo> todos;
  final bool isRetry;

  FetchTodosSuccess({
    required this.todos,
    required this.isRetry,
  });
}

final class FetchTodosError extends FetchTodosState {
  final Exception exception;

  FetchTodosError({
    required this.exception,
  });
}
