import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_release_radar_app/spotify/model/spotify_track.dart';
import 'added_items_cubit.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddedItemsPage extends StatelessWidget {
  const AddedItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.addedTracks)),
      body: BlocBuilder<AddedItemsCubit, AddedItemsState>(
        builder: (context, state) {
          if (state is AddedItemsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AddedItemsLoadingFailure) {
          } else if (state is AddedItemsLoadingSuccess) {
            return _buildTracksList(state);
          }
          return Center(
              child: Text(AppLocalizations.of(context)!.loadingFailed));
        },
      ),
    );
  }

  Widget _buildTracksList(AddedItemsLoadingSuccess state) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: state.tracks.length + (state.hasReachedMax ? 0 : 1),
      itemBuilder: (context, index) {
        if (index >= state.tracks.length) {
          context.read<AddedItemsCubit>().fetchAddedItems();
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final SpotifyTrack track = state.tracks[index];
        final imageUrl = track.album.images.firstOrNull?.url;

        return Card(
          elevation: 2,
          child: ListTile(
            leading: imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(imageUrl, fit: BoxFit.cover),
                  )
                : null,
            title: Text(
              track.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              track.artists.map((a) => a.name).join(', '),
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        );
      },
    );
  }
}
