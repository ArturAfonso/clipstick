import 'package:clipstick/data/models/tag_model.dart';
import 'package:equatable/equatable.dart';

abstract class TagsState extends Equatable {
  const TagsState();
  
  @override
  List<Object?> get props => [];
}

class TagsInitial extends TagsState {}

class TagsLoading extends TagsState {}

class TagsLoaded extends TagsState {
  final List<TagModel> tags; 
  final String searchQuery;
  
  const TagsLoaded({
    required this.tags,
    this.searchQuery = '',
  });
  
  TagsLoaded copyWith({
    List<TagModel>? tags,
    String? searchQuery,
  }) {
    return TagsLoaded(
      tags: tags ?? this.tags,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
  
  @override
  List<Object?> get props => [tags, searchQuery];
}


class TagsError extends TagsState {
  final String message;
  
  const TagsError({required this.message});
  
  @override
  List<Object?> get props => [message];
}