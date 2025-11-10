import 'package:flutter_bloc/flutter_bloc.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeInitial());
  
  // Métodos para gerenciar estado da home
  void loadNotes() {
    emit(HomeLoading());
    
    try {
      // TODO: Carregar notas do repository
      // List<Note> notes = await notesRepository.getAllNotes();
      
      // Por enquanto, simular carregamento
      Future.delayed(Duration(seconds: 1), () {
        emit(HomeLoaded(notes: [])); // Lista vazia por enquanto
      });
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }
  
  void refreshNotes() {
    loadNotes();
  }
  
  void searchNotes(String query) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      // TODO: Implementar busca
      emit(currentState.copyWith(searchQuery: query));
    }
  }
}