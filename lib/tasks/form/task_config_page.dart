import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:music_release_radar_app/auth/auth_cubit.dart';
import 'package:music_release_radar_app/tasks/form/task_form_cubit.dart';
import 'package:music_release_radar_app/tasks/tasks_cubit.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TaskConfigPage extends StatefulWidget {
  const TaskConfigPage({super.key});

  @override
  State<TaskConfigPage> createState() => _TaskConfigPageState();
}

class _TaskConfigPageState extends State<TaskConfigPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController checkFromController = TextEditingController();
  final TextEditingController executionIntervalDaysController =
      TextEditingController();
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
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(AppLocalizations.of(context)!.errorOccurred),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ));
              } else if (state is TaskFormSaved) {
                context.read<TasksCubit>().fetchTasks();
                context.go('/tasks');
              }
            }),
          ],
            child: BlocBuilder<TaskFormCubit, TaskFormState>(
                builder: (context, state) {
              return Scaffold(
                appBar: _buildAppBar(context, state),
                body: _buildBody(context, state),
              );
            })));
  }

  AppBar _buildAppBar(BuildContext context, TaskFormState state) {
    return AppBar(
      title: state.formData.modifyTask != null
          ? Text(AppLocalizations.of(context)!.updateTask)
          : Text(AppLocalizations.of(context)!.createTask),
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

  Widget _buildBody(BuildContext context, TaskFormState state) {
    if (state is TaskConfigState) {
      if (state.formData.modifyTask != null && nameController.text.isEmpty) {
        nameController.text = state.formData.modifyTask!.name;
        checkFromController.text = MaterialLocalizations.of(context)
            .formatCompactDate(state.formData.modifyTask!.checkFrom);
        executionIntervalDaysController.text =
            state.formData.modifyTask!.executionIntervalDays.toString();
      }

      if (executionIntervalDaysController.text.isEmpty) {
        executionIntervalDaysController.text = '7';
      }

      return _buildForm(context);
    } else if (state is TaskFormLoading || state is TaskFormSaved) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return Center(
        child: Text(AppLocalizations.of(context)!.errorOccurred),
      );
    }
  }

  Widget _buildForm(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            controller: nameController,
            decoration:
                InputDecoration(labelText: AppLocalizations.of(context)!.name),
          ),
          TextField(
            controller: checkFromController,
            decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.checkFrom),
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
                InputDecoration(
                labelText: AppLocalizations.of(context)!.executionIntervalDays),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }

  String? _validateForm() {
    if (nameController.text.isEmpty) {
      return AppLocalizations.of(context)!.nameRequired;
    }

    final intervalDays = int.tryParse(executionIntervalDaysController.text);
    if (intervalDays == null || intervalDays <= 0) {
      return AppLocalizations.of(context)!.executionIntervalPositive;
    }

    return null;
  }
}
