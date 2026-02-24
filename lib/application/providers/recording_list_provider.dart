import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/recording.dart';
import '../../infrastructure/repositories/recording_repository_impl.dart';

class RecordingListNotifier extends StateNotifier<List<Recording>> {
  final RecordingRepositoryImpl _repository;

  RecordingListNotifier(this._repository) : super([]) {
    loadRecordings();
  }

  Future<void> loadRecordings() async {
    print('📋 loadRecordings: 開始');
    state = await _repository.getAll();
    print('📋 loadRecordings: 読み込み完了 (件数 = ${state.length})');
  }

  Future<void> addRecording(Recording recording) async {
    print(
      '➕ addRecording: 開始 (id = ${recording.id}, title = ${recording.title})',
    );
    await _repository.save(recording);
    print('➕ addRecording: 保存完了');
    await loadRecordings();
    print('➕ addRecording: リロード完了');
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
