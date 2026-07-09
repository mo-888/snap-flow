import 'entities.dart';

abstract class ManualRepository {
  Future<List<Manual>> listManuals();
  Future<Manual?> getManual(String id);
  Future<void> saveManual(Manual manual);
  Future<void> deleteManual(String id);

  // Tag CRUD
  Future<List<Tag>> listTags();
  Future<void> saveTag(Tag tag);
  Future<void> deleteTag(String id);
  Future<void> setManualTags(String manualId, Set<String> tagIds);
}