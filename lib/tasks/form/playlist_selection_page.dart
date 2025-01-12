import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:music_release_radar_app/auth/auth_cubit.dart';
import 'package:music_release_radar_app/spotify/model/spotify_playlist.dart';
import 'package:music_release_radar_app/tasks/form/task_form_cubit.dart';

class PlaylistSelectionPage extends StatelessWidget {
  const PlaylistSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) =>
          context.read<TaskFormCubit>().loadArtistsSelection(),
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthenticationRequired) {
            context.go('/');
          }
        },
        child: Scaffold(
          appBar: _buildAppBar(context),
          body: _buildBody(context),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text('Select Playlist'),
      actions: [
        BlocBuilder<TaskFormCubit, TaskFormState>(
          builder: (context, state) {
            if (state is PlaylistSelectionState &&
                state.selectedPlaylist != null) {
              return IconButton(
                  icon: Icon(Icons.arrow_forward), onPressed: () {});
            }
            return SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(8.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Filter playlists...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (query) =>
                context.read<TaskFormCubit>().filterPlaylists(query),
          ),
        ),
        Expanded(
          child: BlocBuilder<TaskFormCubit, TaskFormState>(
            builder: (context, state) {
              if (state is PlaylistSelectionState) {
                return _buildPlaylistSelectionList(
                    context: context,
                    filteredPlaylists: state.filteredPlaylists,
                    selectedPlaylist: state.selectedPlaylist);
              } else if (state is TaskFormError) {
                return Center(child: Text(state.message));
              }
              return Center(child: CircularProgressIndicator());
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
              '${playlist.isPublic ? 'Public' : 'Private'} - ${playlist.trackCount} tracks'),
          selected: selectedPlaylist == playlist,
          selectedColor: Theme.of(context).colorScheme.onPrimaryContainer,
          selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
          onTap: () => context.read<TaskFormCubit>().selectPlaylist(playlist),
        );
      },
    );
  }
}
