import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../../domain/entities/recording.dart';
import '../../domain/repositories/recording_repository.dart';

class RecordingRepositoryImpl implements RecordingRepository {
  Future<File> get _file async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/recordings.json');
  }

  @override
  Future<List<Recording>> getAll() async {
    try {
      final file = await _file;
      if (!await file.exists()) return [];
      
      final contents = await file.readAsString();
      final List<dynamic> jsonList = json.decode(contents);
      return jsonList.map((json) => Recording.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> save(Recording recording) async {
    final recordings = await getAll();
    recordings.add(recording);
    
    final file = await _file;
    final jsonList = recordings.map((r) => r.toJson()).toList();
    await file.writeAsString(json.encode(jsonList));
  }

  @override
  Future<void> delete(String id) async {
    final recordings = await getAll();
    recordings.removeWhere((r) => r.id == id);
    
    final file = await _file;
    final jsonList = recordings.map((r) => r.toJson()).toList();
    await file.writeAsString(json.encode(jsonList));
  }
}
