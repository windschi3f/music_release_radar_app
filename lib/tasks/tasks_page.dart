import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:music_release_radar_app/auth/auth_cubit.dart';
import 'package:music_release_radar_app/spotify/model/spotify_playlist.dart';
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
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    final user = context.read<AuthCubit>().user!;

    return AppBar(
      title: const Text('Tasks'),
      actions: [
        PopupMenuButton<String>(
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              child: ListTile(title: Text(user.displayName)),
            ),
            PopupMenuItem<String>(
              onTap: () => context.read<AuthCubit>().logout(),
              child:
                  ListTile(leading: Icon(Icons.logout), title: Text('Logout')),
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
    return BlocBuilder<TasksCubit, TasksState>(
      builder: (context, state) {
        if (state is TasksLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is TasksSuccess) {
          return _buildTasksView(context, state.tasks, state.userPlaylists);
        } else {
          return const Center(
            child: Text('An error occurred while loading tasks.'),
          );
        }
      },
    );
  }

  Widget _buildTasksView(BuildContext context, List<Task> tasks,
      List<SpotifyPlaylist> userPlaylists) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildTaskCard(context, tasks[index], userPlaylists),
      ),
    );
  }

  Widget _buildTaskCard(
      BuildContext context, Task task, List<SpotifyPlaylist> userPlaylists) {
    final playlist = userPlaylists
        .where((playlist) => playlist.id == task.playlistId)
        .firstOrNull;

    final playlistName = playlist?.name ?? 'Unknown';
    final imageUrl = playlist?.images.firstOrNull?.url;

    return Card(
      elevation: 2,
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(imageUrl, fit: BoxFit.cover),
                  )
                : null,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.name,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(children: [
                  Icon(
                    Icons.playlist_play,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      playlistName,
                      style: Theme.of(context).textTheme.bodyMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ]),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Transform.scale(
                  scale: 0.8,
                  child: Switch(value: task.active, onChanged: (bool value) {}),
                ),
                _buildPopupMenu(context, task),
              ],
            ),
          ),
          _buildTaskInfosView(context, task),
        ],
      ),
    );
  }

  PopupMenuButton<String> _buildPopupMenu(BuildContext context, Task task) {
    return PopupMenuButton<String>(
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          onTap: () => _showDeleteConfirmationDialog(context, task),
          child: ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: Text('Delete Task', style: TextStyle(color: Colors.red)),
          ),
        ),
      ],
      icon: const Icon(Icons.more_vert),
    );
  }

  Widget _buildTaskInfosView(BuildContext context, Task task) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAddedTrackWidget(context, task),
            const SizedBox(height: 16),
            _buildInfoWidget(context, task),
          ],
        ));
  }

  Widget _buildAddedTrackWidget(BuildContext context, Task task) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => context.go('/tasks/${task.id}/tracks'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.audiotrack,
                size: 24,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Text(
                'Added Tracks',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  task.addedItems.length.toString(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoWidget(BuildContext context, Task task) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: colorScheme.surfaceContainerHighest,
              width: 2,
            ),
          ),
        ),
        child: Column(
          children: [
            _buildInfoRow(
              context,
              'Tracking Artists',
              task.taskItems.length.toString(),
              Icons.person,
            ),
            _buildInfoRow(
              context,
              'Last Executed',
              _formatDate(context, task.lastTimeExecuted),
              Icons.update,
            ),
            _buildInfoRow(
              context,
              'Check From',
              _formatDate(context, task.checkFrom),
              Icons.calendar_today,
            ),
            _buildInfoRow(
              context,
              'Execution Interval',
              'Every ${task.executionIntervalDays} days',
              Icons.timer,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      minLeadingWidth: 0,
      leading: Icon(
        icon,
        size: 18,
        color: colorScheme.onSurfaceVariant,
      ),
      title: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
      ),
      trailing: Text(
        value,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context, Task task) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: Text('Are you sure you want to delete "${task.name}"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String _formatDate(BuildContext context, DateTime? date) {
    if (date == null) {
      return 'never';
    }
    final locale = Localizations.localeOf(context).toString();
    final dateFormatter = DateFormat.yMMMd(locale);
    return dateFormatter.format(date);
  }
}
