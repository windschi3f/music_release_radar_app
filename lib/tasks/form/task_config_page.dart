import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:music_release_radar_app/auth/auth_cubit.dart';
import 'package:music_release_radar_app/tasks/form/task_form_cubit.dart';
import 'package:music_release_radar_app/tasks/tasks_cubit.dart';

class TaskConfigPage extends StatefulWidget {
  const TaskConfigPage({super.key});

  @override
  State<TaskConfigPage> createState() => _TaskConfigPageState();
}

class _TaskConfigPageState extends State<TaskConfigPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController checkFromController = TextEditingController();
  final TextEditingController executionIntervalDaysController =
      TextEditingController(text: '7');
  DateTime _selectedDate = DateTime.now();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    checkFromController.text =
        MaterialLocalizations.of(context).formatCompactDate(_selectedDate);
  }

  @override
  void dispose() {
    nameController.dispose();
    checkFromController.dispose();
    executionIntervalDaysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        onPopInvokedWithResult: (didPop, result) =>
            context.read<TaskFormCubit>().navigateBack(),
        child: MultiBlocListener(
          listeners: [
            BlocListener<AuthCubit, AuthState>(
              listener: (context, state) {
                if (state is AuthenticationRequired) {
                  context.go('/');
                }
              },
            ),
            BlocListener<TaskFormCubit, TaskFormState>(
                listener: (context, state) {
              if (state is TaskFormError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        "An error occurred: ${state.message}. Please try again."),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              } else if (state is TaskFormSaved) {
                context.read<TasksCubit>().fetchTasks();
                context.go('/tasks');
              }
            }),
          ],
          child: Scaffold(
            appBar: _buildAppBar(context),
            body: _buildBody(context),
          ),
        ));
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Create Task'),
      actions: [
        IconButton(
          icon: const Icon(Icons.save),
          onPressed: () {
            final error = _validateForm();
            if (error != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(error),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ),
              );
            } else {
              context.read<TaskFormCubit>().saveTask(
                    name: nameController.text,
                    checkFrom: _selectedDate,
                    executionIntervalDays:
                        int.parse(executionIntervalDaysController.text),
                  );
            }
          },
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Name'),
          ),
          TextField(
            controller: checkFromController,
            decoration: const InputDecoration(labelText: 'Check From'),
            keyboardType: TextInputType.datetime,
            readOnly: true,
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (pickedDate != null) {
                setState(() {
                  _selectedDate = pickedDate;
                  checkFromController.text = MaterialLocalizations.of(context)
                      .formatCompactDate(_selectedDate);
                });
              }
            },
          ),
          TextField(
            controller: executionIntervalDaysController,
            decoration:
                const InputDecoration(labelText: 'Execution Interval Days'),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  String? _validateForm() {
    if (nameController.text.isEmpty) {
      return 'Name is required';
    }

    final intervalDays = int.tryParse(executionIntervalDaysController.text);
    if (intervalDays == null || intervalDays <= 0) {
      return 'Execution interval must be a positive number';
    }

    return null;
  }
}
