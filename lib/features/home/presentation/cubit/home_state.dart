
import 'package:clipstick/data/models/note_model.dart';
import 'package:equatable/equatable.dart';

abstract class HomeState extends Equatable {
  const HomeState();
  
  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<NoteModel> notes; 
  final String searchQuery;
  
  const HomeLoaded({
    required this.notes,
    this.searchQuery = '',
  });
  
  HomeLoaded copyWith({
    List<NoteModel>? notes,
    String? searchQuery,
  }) {
    return HomeLoaded(
      notes: notes ?? this.notes,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
  
  @override
  List<Object?> get props => [notes, searchQuery];
}

class HomeError extends HomeState {
  final String message;
  
  const HomeError({required this.message});
  
  @override
  List<Object?> get props => [message];
}