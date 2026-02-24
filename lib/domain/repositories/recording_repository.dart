import '../entities/recording.dart';

abstract class RecordingRepository {
  Future<List<Recording>> getAll();
  Future<void> save(Recording recording);
  Future<void> delete(String id);
}
