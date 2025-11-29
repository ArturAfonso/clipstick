import 'package:clipstick/core/di/service_locator.dart';
import 'package:clipstick/data/models/note_model.dart';
import 'package:clipstick/data/repositories/note_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
    final NoteRepository _noteRepository;
   HomeCubit({NoteRepository? noteRepository})
      : _noteRepository = noteRepository ?? sl<NoteRepository>(),
        super(HomeInitial());

  Future<void> loadNotes() async {
    emit(HomeLoading());
    try {
      final notes = await _noteRepository.getAllNotes();
      emit(HomeLoaded(notes: notes));
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  void refreshNotes() {
    loadNotes();
  }

  Future<void> addNote(NoteModel note) async {
  emit(HomeLoading());
  try {
    await _noteRepository.createNote(note);
    await loadNotes(); 
  } catch (e) {
    emit(HomeError(message: e.toString()));
  }
}




Future<void> addNotesBatch(List<NoteModel> notes) async {
  emit(HomeLoading());
  try {
    await _noteRepository.addNotesBatch(notes);
    await loadNotes();
  } catch (e) {
    emit(HomeError(message: e.toString()));
  }
}

Future<void> updateNote(NoteModel note) async {

  
  emit(HomeLoading());
  try {
    await _noteRepository.updateNote(note);
    await loadNotes(); 
  } catch (e) {
    emit(HomeError(message: e.toString()));
  }
}


Future<void> updateNotesBatch(List<NoteModel> notes) async {
  emit(HomeLoading());
  try {
    await _noteRepository.updateNotesBatch(notes);
    await loadNotes();
  } catch (e) {
    emit(HomeError(message: e.toString()));
  }
}

Future<void> deleteNote(String id) async {
  emit(HomeLoading());
  try {
    await _noteRepository.deleteNote(id);
    await loadNotes(); 
  } catch (e) {
    emit(HomeError(message: e.toString()));
  }
}

Future<void> deleteNotesBatch(List<String> ids) async {
  emit(HomeLoading());
  try {
    await _noteRepository.deleteNotes(ids);
    await loadNotes(); 
  } catch (e) {
    emit(HomeError(message: e.toString()));
  }
}

Future<void> searchNotes(String query) async {
  emit(HomeLoading());
  try {
    final notes = await _noteRepository.searchNotes(query);
    emit(HomeLoaded(notes: notes));
  } catch (e) {
    emit(HomeError(message: e.toString()));
  }
}

Future<void> reorderNotes(List<NoteModel> reorderedNotes) async {
  emit(HomeLoading());
  try {
    
    for (int i = 0; i < reorderedNotes.length; i++) {
      reorderedNotes[i] = reorderedNotes[i].copyWith(position: i);
    }
    
    await _noteRepository.updateNotesPositions(reorderedNotes);
    await loadNotes(); 
  } catch (e) {
    emit(HomeError(message: e.toString()));
  }
}


}
