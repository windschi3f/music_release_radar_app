import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:music_release_radar_app/auth/auth_cubit.dart';
import 'package:music_release_radar_app/spotify/model/spotify_artist.dart';
import 'package:music_release_radar_app/tasks/form/task_form_cubit.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ArtistsSelectionPage extends StatelessWidget {
  const ArtistsSelectionPage({super.key});

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
          ),
        ));
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(AppLocalizations.of(context)!.selectArtists),
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
    return BlocBuilder<TaskFormCubit, TaskFormState>(builder: (context, state) {
      return Column(
        children: [
          _buildArtistSearch(context, state),
          Expanded(
              child: Stack(
            children: [
              _buildArtistSelectionList(
                  context: context,
                  searchResults:
                      state is ArtistSelectionState ? state.searchResults : [],
                  selectedArtists: state is ArtistSelectionState
                      ? state.formData.selectedArtists
                      : []),
              if (state is TaskFormLoading)
                const Center(child: CircularProgressIndicator()),
            ],
          ))
        ],
      );
    });
  }

  Widget _buildArtistSearch(BuildContext context, TaskFormState state) {
    bool isFollowedArtistsMode =
        state is ArtistSelectionState ? state.isFollowedArtistsMode : false;
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: isFollowedArtistsMode
                  ? AppLocalizations.of(context)!.filterFollowedArtists
                  : AppLocalizations.of(context)!.searchArtists,
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (query) =>
                context.read<TaskFormCubit>().onSearchQueryChanged(query),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              FilterChip(
                selected: isFollowedArtistsMode,
                label: Text(AppLocalizations.of(context)!.followedArtists),
                onSelected: (selected) =>
                    context.read<TaskFormCubit>().toggleFollowedArtistsMode(),
              ),
            ],
          ),
      ],
      ),
    );
  }

  Widget _buildArtistSelectionList(
      {required BuildContext context,
      required List<SpotifyArtist> searchResults,
      required List<SpotifyArtist> selectedArtists}) {
    final combinedList = [
      ...selectedArtists.where((artist) => !searchResults.contains(artist)),
      ...searchResults
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
