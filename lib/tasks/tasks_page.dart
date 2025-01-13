import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:music_release_radar_app/auth/auth_cubit.dart';
import 'package:music_release_radar_app/tasks/form/task_form_cubit.dart';
import 'package:music_release_radar_app/tasks/tasks_cubit.dart';
import 'package:music_release_radar_app/tasks/task.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthenticationRequired) {
          context.go('/');
        }
      },
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: _buildBody(context),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            context.read<TaskFormCubit>().navigateForward();
            context.go('/tasks/form/artists-selection');
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final user = context.read<AuthCubit>().user!;

    return AppBar(
      title: Text('Tasks'),
      actions: [
        PopupMenuButton<String>(
          onSelected: (String result) {
            if (result == 'logout') {
              context.read<AuthCubit>().logout();
            }
          },
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              child: ListTile(
                title: Text(user.displayName),
              ),
            ),
            const PopupMenuItem<String>(
              value: 'logout',
              child: ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout'),
              ),
            ),
          ],
          child: user.images.isNotEmpty
              ? CircleAvatar(
                  backgroundImage: NetworkImage(user.images.first.url),
                )
              : const Icon(Icons.account_circle),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    context.read<TasksCubit>().fetchTasks();
    return BlocBuilder<TasksCubit, TasksState>(
      builder: (context, state) {
        if (state is TasksLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (state is TasksSuccess) {
          return _buildTasksView(context, state.tasks);
        } else {
          return const Center(
            child: Text('An error occurred while loading tasks.'),
          );
        }
      },
    );
  }

  Widget _buildTasksView(BuildContext context, List<Task> tasks) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return ListTile(
          title: Text(task.name),
          trailing: IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {},
          ),
        );
      },
    );
  }
}
