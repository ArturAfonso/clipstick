import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Importe

enum ViewMode { grid, list }

class ViewModeState {
  final ViewMode mode;
  
  const ViewModeState({this.mode = ViewMode.grid});
  
  ViewModeState copyWith({ViewMode? mode}) {
    return ViewModeState(mode: mode ?? this.mode);
  }
  
  bool get isGridView => mode == ViewMode.grid;
  bool get isListView => mode == ViewMode.list;
}

// Chave que usaremos para salvar no SharedPreferences
const String _viewModeKey = 'app_view_mode';

class ViewModeCubit extends Cubit<ViewModeState> {
  // Inicializa o estado padrão como 'grid'
  ViewModeCubit() : super(const ViewModeState()); 
  
  // 1. Método de Inicialização (Assíncrono)
  Future<void> initializeViewMode() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Tenta ler o valor salvo. Se for null, usa 'grid' como padrão.
    final savedModeString = prefs.getString(_viewModeKey);
    
    // Converte a string salva de volta para ViewMode
    ViewMode initialMode;
    if (savedModeString == ViewMode.list.name) {
      initialMode = ViewMode.list;
    } else {
      initialMode = ViewMode.grid;
    }
    
    // Emite o estado inicial
    emit(state.copyWith(mode: initialMode));
  }
  
  // 2. Método para Salvar a Preferência
  Future<void> _saveViewMode(ViewMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    // Salva o enum como string (ViewMode.grid.name resulta em 'grid')
    await prefs.setString(_viewModeKey, mode.name);
  }
  
  // 3. Métodos de Mudança (atualizados para salvar)
  
  @override
  void setGridView() {
    emit(state.copyWith(mode: ViewMode.grid));
    _saveViewMode(ViewMode.grid); // Salva imediatamente
  }
  
  @override
  void setListView() {
    emit(state.copyWith(mode: ViewMode.list));
    _saveViewMode(ViewMode.list); // Salva imediatamente
  }
  

  void toggleViewMode() {
    if (state.isGridView) {
      setListView();
    } else {
      setGridView();
    }
  }
}









/* 

import 'package:flutter_bloc/flutter_bloc.dart';

enum ViewMode { grid, list }

class ViewModeState {
  final ViewMode mode;
  
  const ViewModeState({this.mode = ViewMode.grid});
  
  ViewModeState copyWith({ViewMode? mode}) {
    return ViewModeState(mode: mode ?? this.mode);
  }
  
  bool get isGridView => mode == ViewMode.grid;
  bool get isListView => mode == ViewMode.list;
}

class ViewModeCubit extends Cubit<ViewModeState> {
  ViewModeCubit() : super(const ViewModeState());
  
  
  void setGridView() {
    emit(state.copyWith(mode: ViewMode.grid));
  }
  
  
  void setListView() {
    emit(state.copyWith(mode: ViewMode.list));
  }
  
 
  void toggleViewMode() {
    if (state.isGridView) {
      setListView();
    } else {
      setGridView();
    }
  }
} */