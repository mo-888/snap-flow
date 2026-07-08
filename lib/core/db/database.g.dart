// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ManualsTable extends Manuals with TableInfo<$ManualsTable, Manual> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ManualsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _coverImagePathMeta =
      const VerificationMeta('coverImagePath');
  @override
  late final GeneratedColumn<String> coverImagePath = GeneratedColumn<String>(
      'cover_image_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isFavoriteMeta =
      const VerificationMeta('isFavorite');
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
      'is_favorite', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_favorite" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, coverImagePath, isFavorite, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'manuals';
  @override
  VerificationContext validateIntegrity(Insertable<Manual> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('cover_image_path')) {
      context.handle(
          _coverImagePathMeta,
          coverImagePath.isAcceptableOrUnknown(
              data['cover_image_path']!, _coverImagePathMeta));
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
          _isFavoriteMeta,
          isFavorite.isAcceptableOrUnknown(
              data['is_favorite']!, _isFavoriteMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Manual map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Manual(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      coverImagePath: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}cover_image_path']),
      isFavorite: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_favorite'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ManualsTable createAlias(String alias) {
    return $ManualsTable(attachedDatabase, alias);
  }
}

class Manual extends DataClass implements Insertable<Manual> {
  final String id;
  final String title;
  final String? coverImagePath;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Manual(
      {required this.id,
      required this.title,
      this.coverImagePath,
      required this.isFavorite,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || coverImagePath != null) {
      map['cover_image_path'] = Variable<String>(coverImagePath);
    }
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ManualsCompanion toCompanion(bool nullToAbsent) {
    return ManualsCompanion(
      id: Value(id),
      title: Value(title),
      coverImagePath: coverImagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverImagePath),
      isFavorite: Value(isFavorite),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Manual.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Manual(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      coverImagePath: serializer.fromJson<String?>(json['coverImagePath']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'coverImagePath': serializer.toJson<String?>(coverImagePath),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Manual copyWith(
          {String? id,
          String? title,
          Value<String?> coverImagePath = const Value.absent(),
          bool? isFavorite,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Manual(
        id: id ?? this.id,
        title: title ?? this.title,
        coverImagePath:
            coverImagePath.present ? coverImagePath.value : this.coverImagePath,
        isFavorite: isFavorite ?? this.isFavorite,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Manual copyWithCompanion(ManualsCompanion data) {
    return Manual(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      coverImagePath: data.coverImagePath.present
          ? data.coverImagePath.value
          : this.coverImagePath,
      isFavorite:
          data.isFavorite.present ? data.isFavorite.value : this.isFavorite,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Manual(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('coverImagePath: $coverImagePath, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, coverImagePath, isFavorite, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Manual &&
          other.id == this.id &&
          other.title == this.title &&
          other.coverImagePath == this.coverImagePath &&
          other.isFavorite == this.isFavorite &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ManualsCompanion extends UpdateCompanion<Manual> {
  final Value<String> id;
  final Value<String> title;
  final Value<String?> coverImagePath;
  final Value<bool> isFavorite;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ManualsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.coverImagePath = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ManualsCompanion.insert({
    required String id,
    this.title = const Value.absent(),
    this.coverImagePath = const Value.absent(),
    this.isFavorite = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<Manual> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? coverImagePath,
    Expression<bool>? isFavorite,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (coverImagePath != null) 'cover_image_path': coverImagePath,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ManualsCompanion copyWith(
      {Value<String>? id,
      Value<String>? title,
      Value<String?>? coverImagePath,
      Value<bool>? isFavorite,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return ManualsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      coverImagePath: coverImagePath ?? this.coverImagePath,
      isFavorite: isFavorite ?? this.isFavorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (coverImagePath.present) {
      map['cover_image_path'] = Variable<String>(coverImagePath.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ManualsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('coverImagePath: $coverImagePath, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StepsTable extends Steps with TableInfo<$StepsTable, Step> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StepsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _manualIdMeta =
      const VerificationMeta('manualId');
  @override
  late final GeneratedColumn<String> manualId = GeneratedColumn<String>(
      'manual_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
      'order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _completedMeta =
      const VerificationMeta('completed');
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
      'completed', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("completed" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _optionalFieldsJsonMeta =
      const VerificationMeta('optionalFieldsJson');
  @override
  late final GeneratedColumn<String> optionalFieldsJson =
      GeneratedColumn<String>('optional_fields_json', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('{}'));
  @override
  List<GeneratedColumn> get $columns =>
      [id, manualId, order, title, note, completed, optionalFieldsJson];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'steps';
  @override
  VerificationContext validateIntegrity(Insertable<Step> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('manual_id')) {
      context.handle(_manualIdMeta,
          manualId.isAcceptableOrUnknown(data['manual_id']!, _manualIdMeta));
    } else if (isInserting) {
      context.missing(_manualIdMeta);
    }
    if (data.containsKey('order')) {
      context.handle(
          _orderMeta, order.isAcceptableOrUnknown(data['order']!, _orderMeta));
    } else if (isInserting) {
      context.missing(_orderMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('completed')) {
      context.handle(_completedMeta,
          completed.isAcceptableOrUnknown(data['completed']!, _completedMeta));
    }
    if (data.containsKey('optional_fields_json')) {
      context.handle(
          _optionalFieldsJsonMeta,
          optionalFieldsJson.isAcceptableOrUnknown(
              data['optional_fields_json']!, _optionalFieldsJsonMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Step map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Step(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      manualId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}manual_id'])!,
      order: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title']),
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note'])!,
      completed: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}completed'])!,
      optionalFieldsJson: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}optional_fields_json'])!,
    );
  }

  @override
  $StepsTable createAlias(String alias) {
    return $StepsTable(attachedDatabase, alias);
  }
}

class Step extends DataClass implements Insertable<Step> {
  final String id;
  final String manualId;
  final int order;
  final String? title;
  final String note;
  final bool completed;
  final String optionalFieldsJson;
  const Step(
      {required this.id,
      required this.manualId,
      required this.order,
      this.title,
      required this.note,
      required this.completed,
      required this.optionalFieldsJson});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['manual_id'] = Variable<String>(manualId);
    map['order'] = Variable<int>(order);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    map['note'] = Variable<String>(note);
    map['completed'] = Variable<bool>(completed);
    map['optional_fields_json'] = Variable<String>(optionalFieldsJson);
    return map;
  }

  StepsCompanion toCompanion(bool nullToAbsent) {
    return StepsCompanion(
      id: Value(id),
      manualId: Value(manualId),
      order: Value(order),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      note: Value(note),
      completed: Value(completed),
      optionalFieldsJson: Value(optionalFieldsJson),
    );
  }

  factory Step.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Step(
      id: serializer.fromJson<String>(json['id']),
      manualId: serializer.fromJson<String>(json['manualId']),
      order: serializer.fromJson<int>(json['order']),
      title: serializer.fromJson<String?>(json['title']),
      note: serializer.fromJson<String>(json['note']),
      completed: serializer.fromJson<bool>(json['completed']),
      optionalFieldsJson:
          serializer.fromJson<String>(json['optionalFieldsJson']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'manualId': serializer.toJson<String>(manualId),
      'order': serializer.toJson<int>(order),
      'title': serializer.toJson<String?>(title),
      'note': serializer.toJson<String>(note),
      'completed': serializer.toJson<bool>(completed),
      'optionalFieldsJson': serializer.toJson<String>(optionalFieldsJson),
    };
  }

  Step copyWith(
          {String? id,
          String? manualId,
          int? order,
          Value<String?> title = const Value.absent(),
          String? note,
          bool? completed,
          String? optionalFieldsJson}) =>
      Step(
        id: id ?? this.id,
        manualId: manualId ?? this.manualId,
        order: order ?? this.order,
        title: title.present ? title.value : this.title,
        note: note ?? this.note,
        completed: completed ?? this.completed,
        optionalFieldsJson: optionalFieldsJson ?? this.optionalFieldsJson,
      );
  Step copyWithCompanion(StepsCompanion data) {
    return Step(
      id: data.id.present ? data.id.value : this.id,
      manualId: data.manualId.present ? data.manualId.value : this.manualId,
      order: data.order.present ? data.order.value : this.order,
      title: data.title.present ? data.title.value : this.title,
      note: data.note.present ? data.note.value : this.note,
      completed: data.completed.present ? data.completed.value : this.completed,
      optionalFieldsJson: data.optionalFieldsJson.present
          ? data.optionalFieldsJson.value
          : this.optionalFieldsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Step(')
          ..write('id: $id, ')
          ..write('manualId: $manualId, ')
          ..write('order: $order, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('completed: $completed, ')
          ..write('optionalFieldsJson: $optionalFieldsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, manualId, order, title, note, completed, optionalFieldsJson);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Step &&
          other.id == this.id &&
          other.manualId == this.manualId &&
          other.order == this.order &&
          other.title == this.title &&
          other.note == this.note &&
          other.completed == this.completed &&
          other.optionalFieldsJson == this.optionalFieldsJson);
}

class StepsCompanion extends UpdateCompanion<Step> {
  final Value<String> id;
  final Value<String> manualId;
  final Value<int> order;
  final Value<String?> title;
  final Value<String> note;
  final Value<bool> completed;
  final Value<String> optionalFieldsJson;
  final Value<int> rowid;
  const StepsCompanion({
    this.id = const Value.absent(),
    this.manualId = const Value.absent(),
    this.order = const Value.absent(),
    this.title = const Value.absent(),
    this.note = const Value.absent(),
    this.completed = const Value.absent(),
    this.optionalFieldsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StepsCompanion.insert({
    required String id,
    required String manualId,
    required int order,
    this.title = const Value.absent(),
    this.note = const Value.absent(),
    this.completed = const Value.absent(),
    this.optionalFieldsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        manualId = Value(manualId),
        order = Value(order);
  static Insertable<Step> custom({
    Expression<String>? id,
    Expression<String>? manualId,
    Expression<int>? order,
    Expression<String>? title,
    Expression<String>? note,
    Expression<bool>? completed,
    Expression<String>? optionalFieldsJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (manualId != null) 'manual_id': manualId,
      if (order != null) 'order': order,
      if (title != null) 'title': title,
      if (note != null) 'note': note,
      if (completed != null) 'completed': completed,
      if (optionalFieldsJson != null)
        'optional_fields_json': optionalFieldsJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StepsCompanion copyWith(
      {Value<String>? id,
      Value<String>? manualId,
      Value<int>? order,
      Value<String?>? title,
      Value<String>? note,
      Value<bool>? completed,
      Value<String>? optionalFieldsJson,
      Value<int>? rowid}) {
    return StepsCompanion(
      id: id ?? this.id,
      manualId: manualId ?? this.manualId,
      order: order ?? this.order,
      title: title ?? this.title,
      note: note ?? this.note,
      completed: completed ?? this.completed,
      optionalFieldsJson: optionalFieldsJson ?? this.optionalFieldsJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (manualId.present) {
      map['manual_id'] = Variable<String>(manualId.value);
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (optionalFieldsJson.present) {
      map['optional_fields_json'] = Variable<String>(optionalFieldsJson.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StepsCompanion(')
          ..write('id: $id, ')
          ..write('manualId: $manualId, ')
          ..write('order: $order, ')
          ..write('title: $title, ')
          ..write('note: $note, ')
          ..write('completed: $completed, ')
          ..write('optionalFieldsJson: $optionalFieldsJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StepImagesTable extends StepImages
    with TableInfo<$StepImagesTable, StepImage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StepImagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _stepIdMeta = const VerificationMeta('stepId');
  @override
  late final GeneratedColumn<String> stepId = GeneratedColumn<String>(
      'step_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _orderMeta = const VerificationMeta('order');
  @override
  late final GeneratedColumn<int> order = GeneratedColumn<int>(
      'order', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _originalPathMeta =
      const VerificationMeta('originalPath');
  @override
  late final GeneratedColumn<String> originalPath = GeneratedColumn<String>(
      'original_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _editedPathMeta =
      const VerificationMeta('editedPath');
  @override
  late final GeneratedColumn<String> editedPath = GeneratedColumn<String>(
      'edited_path', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _thumbnailPathMeta =
      const VerificationMeta('thumbnailPath');
  @override
  late final GeneratedColumn<String> thumbnailPath = GeneratedColumn<String>(
      'thumbnail_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, stepId, order, originalPath, editedPath, thumbnailPath];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'step_images';
  @override
  VerificationContext validateIntegrity(Insertable<StepImage> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('step_id')) {
      context.handle(_stepIdMeta,
          stepId.isAcceptableOrUnknown(data['step_id']!, _stepIdMeta));
    } else if (isInserting) {
      context.missing(_stepIdMeta);
    }
    if (data.containsKey('order')) {
      context.handle(
          _orderMeta, order.isAcceptableOrUnknown(data['order']!, _orderMeta));
    } else if (isInserting) {
      context.missing(_orderMeta);
    }
    if (data.containsKey('original_path')) {
      context.handle(
          _originalPathMeta,
          originalPath.isAcceptableOrUnknown(
              data['original_path']!, _originalPathMeta));
    } else if (isInserting) {
      context.missing(_originalPathMeta);
    }
    if (data.containsKey('edited_path')) {
      context.handle(
          _editedPathMeta,
          editedPath.isAcceptableOrUnknown(
              data['edited_path']!, _editedPathMeta));
    }
    if (data.containsKey('thumbnail_path')) {
      context.handle(
          _thumbnailPathMeta,
          thumbnailPath.isAcceptableOrUnknown(
              data['thumbnail_path']!, _thumbnailPathMeta));
    } else if (isInserting) {
      context.missing(_thumbnailPathMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StepImage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StepImage(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      stepId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}step_id'])!,
      order: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order'])!,
      originalPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}original_path'])!,
      editedPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}edited_path']),
      thumbnailPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}thumbnail_path'])!,
    );
  }

  @override
  $StepImagesTable createAlias(String alias) {
    return $StepImagesTable(attachedDatabase, alias);
  }
}

class StepImage extends DataClass implements Insertable<StepImage> {
  final String id;
  final String stepId;
  final int order;
  final String originalPath;
  final String? editedPath;
  final String thumbnailPath;
  const StepImage(
      {required this.id,
      required this.stepId,
      required this.order,
      required this.originalPath,
      this.editedPath,
      required this.thumbnailPath});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['step_id'] = Variable<String>(stepId);
    map['order'] = Variable<int>(order);
    map['original_path'] = Variable<String>(originalPath);
    if (!nullToAbsent || editedPath != null) {
      map['edited_path'] = Variable<String>(editedPath);
    }
    map['thumbnail_path'] = Variable<String>(thumbnailPath);
    return map;
  }

  StepImagesCompanion toCompanion(bool nullToAbsent) {
    return StepImagesCompanion(
      id: Value(id),
      stepId: Value(stepId),
      order: Value(order),
      originalPath: Value(originalPath),
      editedPath: editedPath == null && nullToAbsent
          ? const Value.absent()
          : Value(editedPath),
      thumbnailPath: Value(thumbnailPath),
    );
  }

  factory StepImage.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StepImage(
      id: serializer.fromJson<String>(json['id']),
      stepId: serializer.fromJson<String>(json['stepId']),
      order: serializer.fromJson<int>(json['order']),
      originalPath: serializer.fromJson<String>(json['originalPath']),
      editedPath: serializer.fromJson<String?>(json['editedPath']),
      thumbnailPath: serializer.fromJson<String>(json['thumbnailPath']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'stepId': serializer.toJson<String>(stepId),
      'order': serializer.toJson<int>(order),
      'originalPath': serializer.toJson<String>(originalPath),
      'editedPath': serializer.toJson<String?>(editedPath),
      'thumbnailPath': serializer.toJson<String>(thumbnailPath),
    };
  }

  StepImage copyWith(
          {String? id,
          String? stepId,
          int? order,
          String? originalPath,
          Value<String?> editedPath = const Value.absent(),
          String? thumbnailPath}) =>
      StepImage(
        id: id ?? this.id,
        stepId: stepId ?? this.stepId,
        order: order ?? this.order,
        originalPath: originalPath ?? this.originalPath,
        editedPath: editedPath.present ? editedPath.value : this.editedPath,
        thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      );
  StepImage copyWithCompanion(StepImagesCompanion data) {
    return StepImage(
      id: data.id.present ? data.id.value : this.id,
      stepId: data.stepId.present ? data.stepId.value : this.stepId,
      order: data.order.present ? data.order.value : this.order,
      originalPath: data.originalPath.present
          ? data.originalPath.value
          : this.originalPath,
      editedPath:
          data.editedPath.present ? data.editedPath.value : this.editedPath,
      thumbnailPath: data.thumbnailPath.present
          ? data.thumbnailPath.value
          : this.thumbnailPath,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StepImage(')
          ..write('id: $id, ')
          ..write('stepId: $stepId, ')
          ..write('order: $order, ')
          ..write('originalPath: $originalPath, ')
          ..write('editedPath: $editedPath, ')
          ..write('thumbnailPath: $thumbnailPath')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, stepId, order, originalPath, editedPath, thumbnailPath);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StepImage &&
          other.id == this.id &&
          other.stepId == this.stepId &&
          other.order == this.order &&
          other.originalPath == this.originalPath &&
          other.editedPath == this.editedPath &&
          other.thumbnailPath == this.thumbnailPath);
}

class StepImagesCompanion extends UpdateCompanion<StepImage> {
  final Value<String> id;
  final Value<String> stepId;
  final Value<int> order;
  final Value<String> originalPath;
  final Value<String?> editedPath;
  final Value<String> thumbnailPath;
  final Value<int> rowid;
  const StepImagesCompanion({
    this.id = const Value.absent(),
    this.stepId = const Value.absent(),
    this.order = const Value.absent(),
    this.originalPath = const Value.absent(),
    this.editedPath = const Value.absent(),
    this.thumbnailPath = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StepImagesCompanion.insert({
    required String id,
    required String stepId,
    required int order,
    required String originalPath,
    this.editedPath = const Value.absent(),
    required String thumbnailPath,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        stepId = Value(stepId),
        order = Value(order),
        originalPath = Value(originalPath),
        thumbnailPath = Value(thumbnailPath);
  static Insertable<StepImage> custom({
    Expression<String>? id,
    Expression<String>? stepId,
    Expression<int>? order,
    Expression<String>? originalPath,
    Expression<String>? editedPath,
    Expression<String>? thumbnailPath,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (stepId != null) 'step_id': stepId,
      if (order != null) 'order': order,
      if (originalPath != null) 'original_path': originalPath,
      if (editedPath != null) 'edited_path': editedPath,
      if (thumbnailPath != null) 'thumbnail_path': thumbnailPath,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StepImagesCompanion copyWith(
      {Value<String>? id,
      Value<String>? stepId,
      Value<int>? order,
      Value<String>? originalPath,
      Value<String?>? editedPath,
      Value<String>? thumbnailPath,
      Value<int>? rowid}) {
    return StepImagesCompanion(
      id: id ?? this.id,
      stepId: stepId ?? this.stepId,
      order: order ?? this.order,
      originalPath: originalPath ?? this.originalPath,
      editedPath: editedPath ?? this.editedPath,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (stepId.present) {
      map['step_id'] = Variable<String>(stepId.value);
    }
    if (order.present) {
      map['order'] = Variable<int>(order.value);
    }
    if (originalPath.present) {
      map['original_path'] = Variable<String>(originalPath.value);
    }
    if (editedPath.present) {
      map['edited_path'] = Variable<String>(editedPath.value);
    }
    if (thumbnailPath.present) {
      map['thumbnail_path'] = Variable<String>(thumbnailPath.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StepImagesCompanion(')
          ..write('id: $id, ')
          ..write('stepId: $stepId, ')
          ..write('order: $order, ')
          ..write('originalPath: $originalPath, ')
          ..write('editedPath: $editedPath, ')
          ..write('thumbnailPath: $thumbnailPath, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ManualsTable manuals = $ManualsTable(this);
  late final $StepsTable steps = $StepsTable(this);
  late final $StepImagesTable stepImages = $StepImagesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [manuals, steps, stepImages];
}

typedef $$ManualsTableCreateCompanionBuilder = ManualsCompanion Function({
  required String id,
  Value<String> title,
  Value<String?> coverImagePath,
  Value<bool> isFavorite,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$ManualsTableUpdateCompanionBuilder = ManualsCompanion Function({
  Value<String> id,
  Value<String> title,
  Value<String?> coverImagePath,
  Value<bool> isFavorite,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

class $$ManualsTableFilterComposer
    extends Composer<_$AppDatabase, $ManualsTable> {
  $$ManualsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get coverImagePath => $composableBuilder(
      column: $table.coverImagePath,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ManualsTableOrderingComposer
    extends Composer<_$AppDatabase, $ManualsTable> {
  $$ManualsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get coverImagePath => $composableBuilder(
      column: $table.coverImagePath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ManualsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ManualsTable> {
  $$ManualsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get coverImagePath => $composableBuilder(
      column: $table.coverImagePath, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
      column: $table.isFavorite, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ManualsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ManualsTable,
    Manual,
    $$ManualsTableFilterComposer,
    $$ManualsTableOrderingComposer,
    $$ManualsTableAnnotationComposer,
    $$ManualsTableCreateCompanionBuilder,
    $$ManualsTableUpdateCompanionBuilder,
    (Manual, BaseReferences<_$AppDatabase, $ManualsTable, Manual>),
    Manual,
    PrefetchHooks Function()> {
  $$ManualsTableTableManager(_$AppDatabase db, $ManualsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ManualsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ManualsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ManualsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> coverImagePath = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ManualsCompanion(
            id: id,
            title: title,
            coverImagePath: coverImagePath,
            isFavorite: isFavorite,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String> title = const Value.absent(),
            Value<String?> coverImagePath = const Value.absent(),
            Value<bool> isFavorite = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              ManualsCompanion.insert(
            id: id,
            title: title,
            coverImagePath: coverImagePath,
            isFavorite: isFavorite,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ManualsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ManualsTable,
    Manual,
    $$ManualsTableFilterComposer,
    $$ManualsTableOrderingComposer,
    $$ManualsTableAnnotationComposer,
    $$ManualsTableCreateCompanionBuilder,
    $$ManualsTableUpdateCompanionBuilder,
    (Manual, BaseReferences<_$AppDatabase, $ManualsTable, Manual>),
    Manual,
    PrefetchHooks Function()>;
typedef $$StepsTableCreateCompanionBuilder = StepsCompanion Function({
  required String id,
  required String manualId,
  required int order,
  Value<String?> title,
  Value<String> note,
  Value<bool> completed,
  Value<String> optionalFieldsJson,
  Value<int> rowid,
});
typedef $$StepsTableUpdateCompanionBuilder = StepsCompanion Function({
  Value<String> id,
  Value<String> manualId,
  Value<int> order,
  Value<String?> title,
  Value<String> note,
  Value<bool> completed,
  Value<String> optionalFieldsJson,
  Value<int> rowid,
});

class $$StepsTableFilterComposer extends Composer<_$AppDatabase, $StepsTable> {
  $$StepsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get manualId => $composableBuilder(
      column: $table.manualId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get order => $composableBuilder(
      column: $table.order, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get completed => $composableBuilder(
      column: $table.completed, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get optionalFieldsJson => $composableBuilder(
      column: $table.optionalFieldsJson,
      builder: (column) => ColumnFilters(column));
}

class $$StepsTableOrderingComposer
    extends Composer<_$AppDatabase, $StepsTable> {
  $$StepsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get manualId => $composableBuilder(
      column: $table.manualId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get order => $composableBuilder(
      column: $table.order, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get completed => $composableBuilder(
      column: $table.completed, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get optionalFieldsJson => $composableBuilder(
      column: $table.optionalFieldsJson,
      builder: (column) => ColumnOrderings(column));
}

class $$StepsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StepsTable> {
  $$StepsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get manualId =>
      $composableBuilder(column: $table.manualId, builder: (column) => column);

  GeneratedColumn<int> get order =>
      $composableBuilder(column: $table.order, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<String> get optionalFieldsJson => $composableBuilder(
      column: $table.optionalFieldsJson, builder: (column) => column);
}

class $$StepsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StepsTable,
    Step,
    $$StepsTableFilterComposer,
    $$StepsTableOrderingComposer,
    $$StepsTableAnnotationComposer,
    $$StepsTableCreateCompanionBuilder,
    $$StepsTableUpdateCompanionBuilder,
    (Step, BaseReferences<_$AppDatabase, $StepsTable, Step>),
    Step,
    PrefetchHooks Function()> {
  $$StepsTableTableManager(_$AppDatabase db, $StepsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StepsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StepsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StepsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> manualId = const Value.absent(),
            Value<int> order = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<String> note = const Value.absent(),
            Value<bool> completed = const Value.absent(),
            Value<String> optionalFieldsJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StepsCompanion(
            id: id,
            manualId: manualId,
            order: order,
            title: title,
            note: note,
            completed: completed,
            optionalFieldsJson: optionalFieldsJson,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String manualId,
            required int order,
            Value<String?> title = const Value.absent(),
            Value<String> note = const Value.absent(),
            Value<bool> completed = const Value.absent(),
            Value<String> optionalFieldsJson = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StepsCompanion.insert(
            id: id,
            manualId: manualId,
            order: order,
            title: title,
            note: note,
            completed: completed,
            optionalFieldsJson: optionalFieldsJson,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$StepsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StepsTable,
    Step,
    $$StepsTableFilterComposer,
    $$StepsTableOrderingComposer,
    $$StepsTableAnnotationComposer,
    $$StepsTableCreateCompanionBuilder,
    $$StepsTableUpdateCompanionBuilder,
    (Step, BaseReferences<_$AppDatabase, $StepsTable, Step>),
    Step,
    PrefetchHooks Function()>;
typedef $$StepImagesTableCreateCompanionBuilder = StepImagesCompanion Function({
  required String id,
  required String stepId,
  required int order,
  required String originalPath,
  Value<String?> editedPath,
  required String thumbnailPath,
  Value<int> rowid,
});
typedef $$StepImagesTableUpdateCompanionBuilder = StepImagesCompanion Function({
  Value<String> id,
  Value<String> stepId,
  Value<int> order,
  Value<String> originalPath,
  Value<String?> editedPath,
  Value<String> thumbnailPath,
  Value<int> rowid,
});

class $$StepImagesTableFilterComposer
    extends Composer<_$AppDatabase, $StepImagesTable> {
  $$StepImagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get stepId => $composableBuilder(
      column: $table.stepId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get order => $composableBuilder(
      column: $table.order, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get originalPath => $composableBuilder(
      column: $table.originalPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get editedPath => $composableBuilder(
      column: $table.editedPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get thumbnailPath => $composableBuilder(
      column: $table.thumbnailPath, builder: (column) => ColumnFilters(column));
}

class $$StepImagesTableOrderingComposer
    extends Composer<_$AppDatabase, $StepImagesTable> {
  $$StepImagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get stepId => $composableBuilder(
      column: $table.stepId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get order => $composableBuilder(
      column: $table.order, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get originalPath => $composableBuilder(
      column: $table.originalPath,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get editedPath => $composableBuilder(
      column: $table.editedPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get thumbnailPath => $composableBuilder(
      column: $table.thumbnailPath,
      builder: (column) => ColumnOrderings(column));
}

class $$StepImagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $StepImagesTable> {
  $$StepImagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get stepId =>
      $composableBuilder(column: $table.stepId, builder: (column) => column);

  GeneratedColumn<int> get order =>
      $composableBuilder(column: $table.order, builder: (column) => column);

  GeneratedColumn<String> get originalPath => $composableBuilder(
      column: $table.originalPath, builder: (column) => column);

  GeneratedColumn<String> get editedPath => $composableBuilder(
      column: $table.editedPath, builder: (column) => column);

  GeneratedColumn<String> get thumbnailPath => $composableBuilder(
      column: $table.thumbnailPath, builder: (column) => column);
}

class $$StepImagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StepImagesTable,
    StepImage,
    $$StepImagesTableFilterComposer,
    $$StepImagesTableOrderingComposer,
    $$StepImagesTableAnnotationComposer,
    $$StepImagesTableCreateCompanionBuilder,
    $$StepImagesTableUpdateCompanionBuilder,
    (StepImage, BaseReferences<_$AppDatabase, $StepImagesTable, StepImage>),
    StepImage,
    PrefetchHooks Function()> {
  $$StepImagesTableTableManager(_$AppDatabase db, $StepImagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StepImagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StepImagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StepImagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> stepId = const Value.absent(),
            Value<int> order = const Value.absent(),
            Value<String> originalPath = const Value.absent(),
            Value<String?> editedPath = const Value.absent(),
            Value<String> thumbnailPath = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              StepImagesCompanion(
            id: id,
            stepId: stepId,
            order: order,
            originalPath: originalPath,
            editedPath: editedPath,
            thumbnailPath: thumbnailPath,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String stepId,
            required int order,
            required String originalPath,
            Value<String?> editedPath = const Value.absent(),
            required String thumbnailPath,
            Value<int> rowid = const Value.absent(),
          }) =>
              StepImagesCompanion.insert(
            id: id,
            stepId: stepId,
            order: order,
            originalPath: originalPath,
            editedPath: editedPath,
            thumbnailPath: thumbnailPath,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$StepImagesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StepImagesTable,
    StepImage,
    $$StepImagesTableFilterComposer,
    $$StepImagesTableOrderingComposer,
    $$StepImagesTableAnnotationComposer,
    $$StepImagesTableCreateCompanionBuilder,
    $$StepImagesTableUpdateCompanionBuilder,
    (StepImage, BaseReferences<_$AppDatabase, $StepImagesTable, StepImage>),
    StepImage,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ManualsTableTableManager get manuals =>
      $$ManualsTableTableManager(_db, _db.manuals);
  $$StepsTableTableManager get steps =>
      $$StepsTableTableManager(_db, _db.steps);
  $$StepImagesTableTableManager get stepImages =>
      $$StepImagesTableTableManager(_db, _db.stepImages);
}
