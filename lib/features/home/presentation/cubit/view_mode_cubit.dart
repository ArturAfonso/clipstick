

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
}