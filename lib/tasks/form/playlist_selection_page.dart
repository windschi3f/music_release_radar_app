import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:music_release_radar_app/auth/auth_cubit.dart';
import 'package:music_release_radar_app/spotify/model/spotify_playlist.dart';
import 'package:music_release_radar_app/tasks/form/task_form_cubit.dart';
import 'package:music_release_radar_app/tasks/form/create_playlist_dialog.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PlaylistSelectionPage extends StatelessWidget {
  const PlaylistSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
        onPopInvokedWithResult: (didPop, result) =>
            context.read<TaskFormCubit>().navigateBack(),
        child: MultiBlocListener(
          listeners: [
            BlocListener<AuthCubit, AuthState>(listener: (context, state) {
              if (state is AuthenticationRequired) {
                context.go('/');
              }
            }),
            BlocListener<TaskFormCubit, TaskFormState>(
                listener: (context, state) {
              if (state is TaskFormError) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(AppLocalizations.of(context)!.errorOccurred),
                  backgroundColor: Theme.of(context).colorScheme.error,
                ));
              }
            }),
          ],
          child: Scaffold(
            appBar: _buildAppBar(context),
            body: _buildBody(context),
            floatingActionButton: _buildFloatingActionButton(context),
          ),
        ));
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(title: Text(AppLocalizations.of(context)!.selectPlaylist));
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    final TaskFormCubit taskFormCubit = context.read<TaskFormCubit>();

    return FloatingActionButton(
      onPressed: () => showDialog(
        context: context,
        builder: (context) =>
            CreatePlaylistDialog(taskFormCubit: taskFormCubit),
      ),
      child: Icon(Icons.add),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: AppLocalizations.of(context)!.filterPlaylists,
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (query) =>
                context.read<TaskFormCubit>().filterPlaylists(query),
          ),
        ),
        Expanded(
          child: BlocBuilder<TaskFormCubit, TaskFormState>(
            builder: (context, state) {
              return Stack(
                children: [
                  _buildPlaylistSelectionList(
                      context: context,
                      filteredPlaylists: state is PlaylistSelectionState
                          ? state.filteredPlaylists
                          : state.formData.userPlaylists,
                      selectedPlaylist: state.formData.selectedPlaylist),
                  if (state is TaskFormLoading)
                    const Center(child: CircularProgressIndicator()),
                ],
              );
            },
          ),
        )
      ],
    );
  }

  Widget _buildPlaylistSelectionList(
      {required BuildContext context,
      required List<SpotifyPlaylist> filteredPlaylists,
      required SpotifyPlaylist? selectedPlaylist}) {
    List<SpotifyPlaylist> playlistsToShow = List.from(filteredPlaylists);
    if (selectedPlaylist != null &&
        !playlistsToShow.contains(selectedPlaylist)) {
      playlistsToShow.insert(0, selectedPlaylist);
    }

    return ListView.builder(
      itemCount: playlistsToShow.length,
      itemBuilder: (context, index) {
        final SpotifyPlaylist playlist = playlistsToShow[index];

        return ListTile(
            leading: playlist.images.isNotEmpty
                ? CircleAvatar(
                    backgroundImage: NetworkImage(playlist.images.first.url),
                  )
                : const CircleAvatar(child: Icon(Icons.playlist_play)),
            title: Text(playlist.name),
            subtitle: Text(
                '${playlist.isPublic ? AppLocalizations.of(context)!.public : AppLocalizations.of(context)!.private} - ${playlist.trackCount} ${AppLocalizations.of(context)!.tracks}'),
            onTap: () {
              context.read<TaskFormCubit>().selectPlaylist(playlist);
              context.read<TaskFormCubit>().navigateForward();
              context.push('/tasks/form/task-config');
            });
      },
    );
  }
}
