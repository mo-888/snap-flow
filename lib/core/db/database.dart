import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [Manuals, Steps, StepImages, Tags, ManualTags, UserTemplates])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'snapflow'));

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) => m.createAll(),
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(tags);
            await m.createTable(manualTags);
            await m.createTable(userTemplates);
            await m.addColumn(steps, steps.createdAt);
            await m.addColumn(steps, steps.completedAt);
            await m.addColumn(manuals, manuals.sortKey);
          }
        },
      );
}