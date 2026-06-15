import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/id_document.dart';

final idListProvider =
    StateNotifierProvider<IdListController, List<IdDocument>>((ref) {
  final controller = IdListController();
  controller.loadDocuments();
  return controller;
});

class IdListController extends StateNotifier<List<IdDocument>> {
  IdListController() : super([]);

  static const _storageKey = 'saved_id_documents';

  Future<void> loadDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_storageKey);
    if (saved != null && saved.isNotEmpty) {
      state = saved.map(IdDocument.fromJson).toList();
    } else {
      state = [];
    }
  }

  Future<void> _save(List<IdDocument> docs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, docs.map((d) => d.toJson()).toList());
  }

  void addDocument(IdDocument doc) {
    final next = [doc, ...state];
    state = next;
    _save(next);
  }

  void removeDocument(String id) {
    final next = state.where((d) => d.id != id).toList();
    state = next;
    _save(next);
  }

  void updateDocument(int index, IdDocument doc) {
    final next = [...state];
    next[index] = doc;
    state = next;
    _save(next);
  }
}
