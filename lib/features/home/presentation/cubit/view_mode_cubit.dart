import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart'; 

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


const String _viewModeKey = 'app_view_mode';

class ViewModeCubit extends Cubit<ViewModeState> {
  
  ViewModeCubit() : super(const ViewModeState()); 
  
  
  Future<void> initializeViewMode() async {
    final prefs = await SharedPreferences.getInstance();
    
    
    final savedModeString = prefs.getString(_viewModeKey);
    
    
    ViewMode initialMode;
    if (savedModeString == ViewMode.list.name) {
      initialMode = ViewMode.list;
    } else {
      initialMode = ViewMode.grid;
    }
    
    
    emit(state.copyWith(mode: initialMode));
  }
  
  
  Future<void> _saveViewMode(ViewMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString(_viewModeKey, mode.name);
  }
  
  
  
  void setGridView() {
    emit(state.copyWith(mode: ViewMode.grid));
    _saveViewMode(ViewMode.grid); 
  }
  
  void setListView() {
    emit(state.copyWith(mode: ViewMode.list));
    _saveViewMode(ViewMode.list); 
  }
  

  void toggleViewMode() {
    if (state.isGridView) {
      setListView();
    } else {
      setGridView();
    }
  }
}









