import 'package:equatable/equatable.dart';
import '../home/home_media_item.dart';

abstract class MediaCollectionsEvent extends Equatable {
  const MediaCollectionsEvent();

  @override
  List<Object?> get props => [];
}

class LoadCollectionsEvent extends MediaCollectionsEvent {
  const LoadCollectionsEvent();
}

class ToggleFavoriteEvent extends MediaCollectionsEvent {
  final HomeMediaItem item;

  const ToggleFavoriteEvent(this.item);

  @override
  List<Object?> get props => [item];
}

class RecordWatchEvent extends MediaCollectionsEvent {
  final HomeMediaItem item;

  const RecordWatchEvent(this.item);

  @override
  List<Object?> get props => [item];
}

