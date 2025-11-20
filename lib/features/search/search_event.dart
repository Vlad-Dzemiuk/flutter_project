import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchByFilters extends SearchEvent {
  final String? genre;
  final int? year;
  final double? rating;

  const SearchByFilters({this.genre, this.year, this.rating});

  @override
  List<Object?> get props => [genre, year, rating];
}
