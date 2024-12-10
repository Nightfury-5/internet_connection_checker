import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:internet_connection_checker_example/blocs/internet_cubit/internet_cubit.dart';
import 'package:internet_connection_checker_example/models/todo.dart';
import 'package:http/http.dart' as http;

part 'fetch_todos_state.dart';

/// A `Cubit` that handles the fetching of Todos from a remote API.
///
/// The `FetchTodosCubit` class is responsible for managing the state related
/// to fetching a list of todos from a remote API. It listens for internet
/// connection changes and attempts to fetch the todos when the internet is
/// available. The cubit emits different states depending on the result of
/// the fetch operation, such as `FetchTodosLoading`, `FetchTodosSuccess`,
/// `FetchTodosEmpty`, or `FetchTodosError`.
class FetchTodosCubit extends Cubit<FetchTodosState> {
  /// Creates an instance of `FetchTodosCubit`.
  ///
  /// The constructor initializes the cubit with an initial state of
  /// `FetchTodosInitial`. It requires an `InternetCubit` instance, which
  /// is used to listen for changes in internet connectivity.
  ///
  /// *Parameters:*
  /// - `internetCubit`: An instance of `InternetCubit` used to monitor
  ///    the internet connection status.
  FetchTodosCubit({
    required this.internetCubit,
  }) : super(FetchTodosInitial());

  /// The `InternetCubit` instance used to monitor internet connectivity.
  final InternetCubit internetCubit;

  /// Starts listening for changes in internet connectivity.
  ///
  /// This method sets up a listener on the `internetCubit`'s stream. If the
  /// internet connection status changes to `connected`, it attempts to fetch
  /// the todos. If the internet is not available, it logs a message but does
  /// not attempt to fetch the todos.
  void startListeningForInternetChanges() {
    internetCubit.stream.listen((status) {
      if (status == InternetConnectionStatus.connected) {
        debugPrint('Internet is available');

        /// Retry Fetch Todos
        fetchTodos(isRetry: true);
      } else {
        debugPrint('Internet is not available');
      }
    });
  }

  /// Fetches the list of todos from the remote API.
  ///
  /// This method makes an HTTP GET request to a remote API to retrieve a list
  /// of todos. It emits a `FetchTodosLoading` state while the request is in
  /// progress. Depending on the result, it emits a `FetchTodosSuccess` state
  /// if todos are successfully retrieved, a `FetchTodosEmpty` state if the
  /// response is empty, or a `FetchTodosError` state if there is an error
  /// during the request.
  ///
  /// *Parameters:*
  /// - `isRetry`: A boolean flag indicating whether the fetch attempt is a
  ///   retry. Defaults to `false`.
  void fetchTodos({bool isRetry = false}) async {
    final http.Client client = http.Client();

    emit(FetchTodosLoading());
    try {
      final http.Response x = await client.get(
        Uri.parse('https://jsonplaceholder.typicode.com/todos'),
        headers: <String, String>{
          'content-type': 'application/json',
        },
      );

      final List<dynamic> responseBody = json.decode(x.body) as List<dynamic>;

      final List<Todo> todos = responseBody.map(
        (dynamic todo) {
          return Todo.fromJson(todo as Map<String, dynamic>);
        },
      ).toList();

      if (todos.isNotEmpty) {
        emit(FetchTodosSuccess(todos: todos, isRetry: isRetry));
      } else {
        emit(FetchTodosEmpty());
      }
    } on SocketException {
      emit(FetchTodosError(exception: const SocketException('')));
    } on http.ClientException {
      emit(FetchTodosError(exception: const SocketException('')));
    }
  }

  /// Closes the cubit and any resources it holds.
  ///
  /// This method closes the `internetCubit` to clean up resources and then
  /// calls the `super.close()` method to close the cubit. This ensures that
  /// no resources are leaked when the cubit is no longer in use.
  @override
  Future<void> close() {
    internetCubit.close();
    return super.close();
  }
}
