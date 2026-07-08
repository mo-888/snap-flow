import 'entities.dart';

abstract class ManualRepository {
  Future<List<Manual>> listManuals();
  Future<Manual?> getManual(String id);
  Future<void> saveManual(Manual manual);
  Future<void> deleteManual(String id);
}