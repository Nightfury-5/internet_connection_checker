import 'dart:convert';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:internet_connection_checker_example/blocs/internet_cubit/internet_cubit.dart';
import 'package:internet_connection_checker_example/models/todo.dart';

import 'package:http/http.dart' as http;

part 'fetch_todos_state.dart';

class FetchTodosCubit extends Cubit<FetchTodosState> {
  FetchTodosCubit({
    required this.internetCubit,
  }) : super(
          FetchTodosInitial(),
        );

  final InternetCubit internetCubit;

  void startListeningForInternetChanges() {
    internetCubit.stream.listen((status) {
      if (status == InternetConnectionStatus.connected) {
        debugPrint(
          'Internet is available',
        );

        /// Retry Fetch Todos
        fetchTodos(
          isRetry: true,
        );
      } else {
        debugPrint(
          'Internet is not available',
        );
      }
    });
  }

  void fetchTodos({
    bool isRetry = false,
  }) async {
    final http.Client client = http.Client();

    emit(FetchTodosLoading());
    try {
      final http.Response x = await client.get(
        Uri.parse(
          'https://jsonplaceholder.typicode.com/todos',
        ),
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
        emit(
          FetchTodosSuccess(
            todos: todos,
            isRetry: isRetry,
          ),
        );
      } else {
        emit(
          FetchTodosEmpty(),
        );
      }
    } on SocketException {
      emit(
        FetchTodosError(
          exception: SocketException(''),
        ),
      );
    }
  }

  @override
  Future<void> close() {
    internetCubit.close();
    return super.close();
  }
}
