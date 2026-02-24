import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/recording.dart';
import '../../infrastructure/repositories/recording_repository_impl.dart';

class RecordingListNotifier extends StateNotifier<List<Recording>> {
  final RecordingRepositoryImpl _repository;

  RecordingListNotifier(this._repository) : super([]) {
    loadRecordings();
  }

  Future<void> loadRecordings() async {
    state = await _repository.getAll();
  }

  Future<void> addRecording(Recording recording) async {
    await _repository.save(recording);
    await loadRecordings();
  }

  Future<void> deleteRecording(String id) async {
    await _repository.delete(id);
    await loadRecordings();
  }
}

final recordingListProvider =
    StateNotifierProvider<RecordingListNotifier, List<Recording>>((ref) {
  return RecordingListNotifier(RecordingRepositoryImpl());
});
