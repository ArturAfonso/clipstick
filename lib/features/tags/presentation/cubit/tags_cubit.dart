import 'package:clipstick/core/di/service_locator.dart';
import 'package:clipstick/data/models/tag_model.dart';
import 'package:clipstick/data/repositories/tag_repository.dart';
import 'package:clipstick/features/home/presentation/cubit/home_cubit.dart';
import 'package:clipstick/features/tags/presentation/cubit/tags_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TagsCubit extends Cubit<TagsState> {
  final TagRepository _tagRepository;

  TagsCubit({TagRepository? tagRepository})
    : _tagRepository = tagRepository ?? sl<TagRepository>(),
      super(TagsInitial());

  Future<void> loadTags() async {
    emit(TagsLoading());
    try {
      final tags = await _tagRepository.getAllTags();
      emit(TagsLoaded(tags: tags));
    } catch (e) {
      emit(TagsError(message: e.toString()));
    }
  }

  Future<void> addTag(TagModel tag) async {
    try {
      await _tagRepository.createTag(tag);
      await loadTags();
    } catch (e) {
      emit(TagsError(message: e.toString()));
    }
  }

  Future<bool> updateTag(TagModel tag, BuildContext context) async {
    try {
      await _tagRepository.updateTag(tag);
      await loadTags().then((_) {
        context.read<HomeCubit>().refreshNotes();
      });
      return true;
    } catch (e) {
      //emit(TagsError(message: e.toString()));
      return false;
    }
  }

  Future<bool> deleteTag(String tagId, BuildContext context) async {
    try {
      await _tagRepository.deleteTag(tagId);
      await loadTags().then((_) {
        context.read<HomeCubit>().refreshNotes();
      });
      return true;
    } catch (e) {
     // emit(TagsError(message: e.toString()));
      return false;
    }
  }
}
