import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:music_release_radar_app/auth/auth_cubit.dart';
import 'package:music_release_radar_app/spotify/model/spotify_playlist.dart';
import 'package:music_release_radar_app/tasks/added_items/added_item_type.dart';
import 'package:music_release_radar_app/tasks/added_items/added_items_cubit.dart';
import 'package:music_release_radar_app/tasks/form/task_form_cubit.dart';
import 'package:music_release_radar_app/tasks/tasks_cubit.dart';
import 'package:music_release_radar_app/tasks/task.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthenticationRequired) {
              context.go('/');
            }
          },
        ),
        BlocListener<TasksCubit, TasksState>(
          listenWhen: (previous, current) =>
              current is TasksLoadingError ||
              current is TasksDeletionError ||
              current is TasksExecutionError,
            listener: (context, state) =>
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(AppLocalizations.of(context)!.errorOccurred),
                ))
          
        ),
      ],
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
      title: Text(AppLocalizations.of(context)!.tasks),
      actions: [
        PopupMenuButton<String>(
          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              child: ListTile(title: Text(user.displayName)),
            ),
            PopupMenuItem<String>(
              onTap: () => context.read<AuthCubit>().logout(),
              child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text(AppLocalizations.of(context)!.logout)),
            ),
          ],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: user.images.isNotEmpty
                ? CircleAvatar(
                    backgroundImage: NetworkImage(user.images.first.url),
                  )
                : const Icon(Icons.account_circle),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<TasksCubit, TasksState>(
      builder: (context, state) {
        if (state is TasksLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is TasksLoadingError) {
          return Center(
              child: ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            label: Text(AppLocalizations.of(context)!.retry),
            onPressed: () => context.read<TasksCubit>().fetchTasks(),
          ));
        }

        return _buildTasksView(context, state.tasks, state.userPlaylists);
      },
    );
  }

  Widget _buildTasksView(BuildContext context, List<Task> tasks,
      List<SpotifyPlaylist> userPlaylists) {
    return RefreshIndicator(
        onRefresh: () => context.read<TasksCubit>().fetchTasks(),
        child: ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
                child: _buildTaskCard(context, tasks[index], userPlaylists)))
    );
  }

  Widget _buildTaskCard(
      BuildContext context, Task task, List<SpotifyPlaylist> userPlaylists) {
    final playlist = userPlaylists
        .where((playlist) => playlist.id == task.playlistId)
        .firstOrNull;

    final playlistName =
        playlist?.name ?? AppLocalizations.of(context)!.unknown;
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
            trailing: _buildPopupMenu(context, task),
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
          onTap: () => context.read<TasksCubit>().executeTask(task),
          enabled: !task.processing,
          child: ListTile(
            leading: Icon(Icons.play_arrow),
            title: Text(AppLocalizations.of(context)!.executeNow),
          ),
        ),
        PopupMenuItem<String>(
          onTap: () {
            context.read<TaskFormCubit>().modifyTask(task);
            context.go('/tasks/form/artists-selection');
          },
          enabled: !task.processing,
          child: ListTile(
            leading: Icon(Icons.edit),
            title: Text(AppLocalizations.of(context)!.editTask),
          ),
        ),
        PopupMenuItem<String>(
          onTap: () => _showDeleteConfirmationDialog(context, task),
          enabled: !task.processing,
          child: ListTile(
            leading: Icon(Icons.delete,
                color: task.processing ? Colors.grey : Colors.red),
            title: Text(AppLocalizations.of(context)!.deleteTask),
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
    final addedTrackItems = task.addedItems
        .where((item) => item.itemType == AddedItemType.TRACK)
        .toList();

    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () {
          if (addedTrackItems.isNotEmpty) {
            context.read<AddedItemsCubit>().init(task.addedItems);
            context.go('/tasks/added-items');
          }
        },
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
                AppLocalizations.of(context)!.addedTracks,
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
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  addedTrackItems.length.toString(),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
              const SizedBox(width: 4),
              if (addedTrackItems.isNotEmpty)
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
              AppLocalizations.of(context)!.trackingArtists,
              task.taskItems.length.toString(),
              Icons.person,
            ),
            _buildInfoRow(
              context,
              AppLocalizations.of(context)!.lastExecuted,
              task.processing
                  ? AppLocalizations.of(context)!.processing
                  : _formatDateTime(context, task.lastTimeExecuted),
              Icons.update,
              primaryColor: task.processing,
            ),
            _buildInfoRow(
              context,
              AppLocalizations.of(context)!.checkFrom,
              _formatDate(context, task.checkFrom),
              Icons.calendar_today,
            ),
            _buildInfoRow(
              context,
              AppLocalizations.of(context)!.executionInterval,
              AppLocalizations.of(context)!
                  .everyDays(task.executionIntervalDays),
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
    IconData icon, {
    bool primaryColor = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      minLeadingWidth: 0,
      leading: Icon(
        icon,
        size: 18,
        color:
            primaryColor ? colorScheme.primary : colorScheme.onSurfaceVariant,
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
              color: primaryColor ? colorScheme.primary : colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context, Task task) {
    final tasksCubit = context.read<TasksCubit>();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.deleteTask),
          content: Text(
              AppLocalizations.of(context)!.deleteTaskConfirmation(task.name)),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.delete,
                  style: TextStyle(color: Colors.red)),
              onPressed: () {
                tasksCubit.deleteTask(task);
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
      return AppLocalizations.of(context)!.never;
    }
    final locale = Localizations.localeOf(context).toString();
    final dateFormatter = DateFormat.yMMMd(locale);
    return dateFormatter.format(date);
  }

  String _formatDateTime(BuildContext context, DateTime? date) {
    if (date == null) {
      return AppLocalizations.of(context)!.never;
    }
    final locale = Localizations.localeOf(context).toString();
    final dateFormatter = DateFormat.yMMMd(locale);
    final timeFormatter = DateFormat.Hm(locale);
    return '${dateFormatter.format(date)} ${timeFormatter.format(date)}';
  }
}
