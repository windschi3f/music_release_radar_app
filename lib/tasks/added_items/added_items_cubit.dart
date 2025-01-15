import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_release_radar_app/auth/auth_cubit.dart';
import 'package:music_release_radar_app/core/retry_policy.dart';
import 'package:music_release_radar_app/core/token_service.dart';
import 'package:music_release_radar_app/core/unauthorized_exception.dart';
import 'package:music_release_radar_app/spotify/spotify_client.dart';
import 'package:music_release_radar_app/tasks/added_items/added_item.dart';
import 'package:music_release_radar_app/spotify/model/spotify_track.dart';

part 'added_items_state.dart';

class AddedItemsCubit extends Cubit<AddedItemsState> {
  static const int _pageSize = 50;

  final SpotifyClient _spotifyClient;
  final RetryPolicy _retryPolicy;
  final AuthCubit _authCubit;

  List<AddedItem> _addedItems = [];
  int _currentPage = 0;

  AddedItemsCubit({
    required SpotifyClient spotifyClient,
    required TokenService tokenService,
    required AuthCubit authCubit,
  })  : _spotifyClient = spotifyClient,
        _retryPolicy = RetryPolicy(tokenService, spotifyClient),
        _authCubit = authCubit,
        super(AddedItemsInitial());

  Future<void> init(List<AddedItem> addedItems) async {
    _addedItems = addedItems;
    _currentPage = 0;
    await fetchAddedItems();
  }

  Future<void> fetchAddedItems() async {
    if (state is AddedItemsLoading ||
        (state is AddedItemsLoadingSuccess &&
            (state as AddedItemsLoadingSuccess).hasReachedMax)) {
      return;
    }

    emit(AddedItemsLoading());

    try {
      final startIndex = _currentPage * _pageSize;
      final endIndex = min(startIndex + _pageSize, _addedItems.length);

      if (startIndex >= _addedItems.length) {
        emit(AddedItemsLoadingSuccess(
          (state is AddedItemsLoadingSuccess
              ? (state as AddedItemsLoadingSuccess).tracks
              : []),
          true,
        ));
        return;
      }

      final itemsToFetch = _addedItems.sublist(startIndex, endIndex);
      final trackIds =
          itemsToFetch.map((item) => item.externalId.split(':').last).toList();

      final tracks = await _retryPolicy
          .execute((token) => _spotifyClient.getSeveralTracks(token, trackIds));

      final hasReachedMax = endIndex >= _addedItems.length;
      _currentPage++;

      emit(AddedItemsLoadingSuccess(
        [
          ...(state is AddedItemsLoadingSuccess
              ? (state as AddedItemsLoadingSuccess).tracks
              : []),
          ...tracks
        ],
        hasReachedMax,
      ));
    } on UnauthorizedException {
      _authCubit.logout();
    } catch (e) {
      emit(AddedItemsLoadingFailure(e.toString()));
    }
  }
}
