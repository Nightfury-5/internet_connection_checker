import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_example/blocs/fetch_todos_cubit/fetch_todos_cubit.dart';
import 'package:internet_connection_checker_example/models/todo.dart';

/// A `StatelessWidget` that automatically refreshes the UI when the network becomes available.
///
/// The `AutoRefreshWhenNetworkIsAvailablePage` class is a `StatelessWidget` that demonstrates
/// how to automatically refresh the UI when network connectivity is restored. It listens to the
/// `FetchTodosCubit` for changes in the state related to fetching a list of todos, and displays
/// appropriate content based on the state.
class AutoRefreshWhenNetworkIsAvailablePage extends StatelessWidget {
  const AutoRefreshWhenNetworkIsAvailablePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Auto Refresh Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: BlocConsumer<FetchTodosCubit, FetchTodosState>(
          listener: (context, state) {
            if (state is FetchTodosSuccess) {
              if (state.isRetry) {
                const SnackBar snackBar = SnackBar(
                  content: Text('You are back online.'),
                );

                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(snackBar);
              }
            }
          },
          builder: (context, state) {
            switch (state) {
              case FetchTodosInitial():
                return const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              case FetchTodosLoading():
                return const Center(
                  child: CircularProgressIndicator.adaptive(),
                );
              case FetchTodosEmpty():
                return const Center(
                  child: Text('No Todos'),
                );
              case FetchTodosSuccess(todos: List<Todo> todos):
                return ListView.builder(
                  itemCount: todos.length,
                  itemBuilder: (context, i) {
                    return ListTile(
                      title: Text(todos[i].title),
                    );
                  },
                );
              case FetchTodosError():
                // Start listening for network changes when an error occurs
                context
                    .read<FetchTodosCubit>()
                    .startListeningForInternetChanges();
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    const Align(
                      child: Text('No Internet'),
                    ),
                    const SizedBox(height: 8),
                    Align(
                      child: ElevatedButton(
                        onPressed: () {
                          context.read<FetchTodosCubit>().fetchTodos(
                                isRetry: true,
                              );
                        },
                        child: const Text('Retry'),
                      ),
                    ),
                  ],
                );
            }
          },
        ),
      ),
    );
  }
}
