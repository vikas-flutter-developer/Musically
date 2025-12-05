
import 'package:equatable/equatable.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class FetchSongsInitial extends HomeEvent {
  final String searchTerm;
  const FetchSongsInitial(this.searchTerm);

  @override
  List<Object> get props => [searchTerm];
}

class FetchSongsNextPage extends HomeEvent {}
