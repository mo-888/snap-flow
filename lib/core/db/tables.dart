import 'package:drift/drift.dart';

class Manuals extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get coverImagePath => text().nullable()();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
  IntColumn get sortKey => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

class Steps extends Table {
  TextColumn get id => text()();
  TextColumn get manualId =>
      text().references(Manuals, #id, onDelete: KeyAction.cascade)();
  IntColumn get order => integer()();
  TextColumn get title => text().nullable()();
  TextColumn get note => text().withDefault(const Constant(''))();
  BoolColumn get completed => boolean().withDefault(const Constant(false))();
  TextColumn get optionalFieldsJson =>
      text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get completedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class StepImages extends Table {
  TextColumn get id => text()();
  TextColumn get stepId =>
      text().references(Steps, #id, onDelete: KeyAction.cascade)();
  IntColumn get order => integer()();
  TextColumn get originalPath => text()();
  TextColumn get editedPath => text().nullable()();
  TextColumn get thumbnailPath => text()();

  @override
  Set<Column> get primaryKey => {id};
}

class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().unique()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class ManualTags extends Table {
  TextColumn get manualId =>
      text().references(Manuals, #id, onDelete: KeyAction.cascade)();
  TextColumn get tagId =>
      text().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {manualId, tagId};
}

class UserTemplates extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get stepsJson => text()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}