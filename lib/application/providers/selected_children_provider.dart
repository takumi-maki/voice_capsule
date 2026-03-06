import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectedChildrenNotifier extends StateNotifier<List<String>> {
  SelectedChildrenNotifier() : super([]);

  void initialize(List<String> childIds) {
    state = List.from(childIds);
  }

  void toggle(String childId) {
    if (state.contains(childId)) {
      state = state.where((id) => id != childId).toList();
    } else {
      state = [...state, childId];
    }
  }

  void selectAll(List<String> childIds) {
    state = List.from(childIds);
  }
}

final selectedChildrenProvider =
    StateNotifierProvider<SelectedChildrenNotifier, List<String>>((ref) {
      return SelectedChildrenNotifier();
    });
