import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:music_release_radar_app/auth/auth_cubit.dart';
import 'package:music_release_radar_app/spotify/model/spotify_artist.dart';
import 'package:music_release_radar_app/tasks/form/task_form_cubit.dart';

class ArtistsSelectionPage extends StatelessWidget {
  const ArtistsSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) =>
          context.read<TaskFormCubit>().navigateBack(),
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
      title: Text('Select Artists'),
      actions: [
        BlocBuilder<TaskFormCubit, TaskFormState>(
          builder: (context, state) {
            if (state is ArtistSelectionState &&
                state.formData.selectedArtists.isNotEmpty) {
              return IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: () {
                    context.read<TaskFormCubit>().navigateForward();
                    context.push('/tasks/form/playlist-selection');
                  });
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
              hintText: 'Search artists...',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (query) {
              context.read<TaskFormCubit>().searchArtists(query);
            },
          ),
        ),
        Expanded(
          child: BlocBuilder<TaskFormCubit, TaskFormState>(
            builder: (context, state) {
              if (state is ArtistSelectionState) {
                return _buildArtistSelectionList(
                    context: context,
                    searchResults: state.searchResults,
                    selectedArtists: state.formData.selectedArtists);
              } else if (state is TaskFormError) {
                return Center(child: Text(state.message));
              }
              return Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ],
    );
  }

  Widget _buildArtistSelectionList(
      {required BuildContext context,
      required List<SpotifyArtist> searchResults,
      required List<SpotifyArtist> selectedArtists}) {
    final combinedList = [
      ...selectedArtists,
      ...searchResults.where((artist) => !selectedArtists.contains(artist))
    ];

    return ListView.builder(
      itemCount: combinedList.length,
      itemBuilder: (context, index) {
        final artist = combinedList[index];
        final isSelected = selectedArtists.contains(artist);

        return ListTile(
          leading: artist.images.isNotEmpty
              ? CircleAvatar(
                  backgroundImage: NetworkImage(artist.images.first.url),
                )
              : CircleAvatar(child: Icon(Icons.person)),
          title: Text(artist.name),
          subtitle: Text(artist.genres.join(', ')),
          selected: isSelected,
          selectedColor: Theme.of(context).colorScheme.onPrimaryContainer,
          selectedTileColor: Theme.of(context).colorScheme.primaryContainer,
          onTap: () =>
              context.read<TaskFormCubit>().toggleArtistSelection(artist),
        );
      },
    );
  }
}
