part of 'added_items_cubit.dart';

@immutable
sealed class AddedItemsState {}

final class AddedItemsInitial extends AddedItemsState {}

final class AddedItemsLoading extends AddedItemsState {}

final class AddedItemsLoadingSuccess extends AddedItemsState {
  final List<SpotifyTrack> tracks;
  final bool hasReachedMax;

  AddedItemsLoadingSuccess(this.tracks, this.hasReachedMax);
}

final class AddedItemsLoadingFailure extends AddedItemsState {
  final String error;

  AddedItemsLoadingFailure(this.error);
}
