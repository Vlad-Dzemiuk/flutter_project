import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadContentEvent extends HomeEvent {
  const LoadContentEvent();
}

class SearchEvent extends HomeEvent {
  final String? query;
  final String? genreName;
  final int? year;
  final double? rating;
  final bool loadMore;

  const SearchEvent({
    this.query,
    this.genreName,
    this.year,
    this.rating,
    this.loadMore = false,
  });

  @override
  List<Object?> get props => [query, genreName, year, rating, loadMore];
}

class ClearSearchEvent extends HomeEvent {
  const ClearSearchEvent();
}

