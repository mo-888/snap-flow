import 'package:flutter/foundation.dart';

const Object _undefined = Object();

@immutable
class Manual {
  final String id;
  final String title;
  final String? coverImagePath;
  final bool isFavorite;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Step> steps;

  const Manual({
    required this.id,
    required this.title,
    required this.coverImagePath,
    required this.isFavorite,
    required this.createdAt,
    required this.updatedAt,
    required this.steps,
  });

  Manual copyWith({
    Object? id = _undefined,
    Object? title = _undefined,
    Object? coverImagePath = _undefined,
    Object? isFavorite = _undefined,
    Object? createdAt = _undefined,
    Object? updatedAt = _undefined,
    Object? steps = _undefined,
  }) {
    return Manual(
      id: id == _undefined ? this.id : id as String,
      title: title == _undefined ? this.title : title as String,
      coverImagePath:
          coverImagePath == _undefined
              ? this.coverImagePath
              : coverImagePath as String?,
      isFavorite:
          isFavorite == _undefined ? this.isFavorite : isFavorite as bool,
      createdAt:
          createdAt == _undefined ? this.createdAt : createdAt as DateTime,
      updatedAt:
          updatedAt == _undefined ? this.updatedAt : updatedAt as DateTime,
      steps: steps == _undefined ? this.steps : steps as List<Step>,
    );
  }
}

@immutable
class Step {
  final String id;
  final int order;
  final String? title;
  final String note;
  final bool completed;
  final List<StepImage> images;
  final Map<String, String> optionalFields;

  const Step({
    required this.id,
    required this.order,
    required this.title,
    required this.note,
    required this.completed,
    required this.images,
    required this.optionalFields,
  });

  Step copyWith({
    Object? id = _undefined,
    Object? order = _undefined,
    Object? title = _undefined,
    Object? note = _undefined,
    Object? completed = _undefined,
    Object? images = _undefined,
    Object? optionalFields = _undefined,
  }) {
    return Step(
      id: id == _undefined ? this.id : id as String,
      order: order == _undefined ? this.order : order as int,
      title: title == _undefined ? this.title : title as String?,
      note: note == _undefined ? this.note : note as String,
      completed: completed == _undefined ? this.completed : completed as bool,
      images: images == _undefined ? this.images : images as List<StepImage>,
      optionalFields:
          optionalFields == _undefined
              ? this.optionalFields
              : optionalFields as Map<String, String>,
    );
  }
}

@immutable
class StepImage {
  final String id;
  final int order;
  final String originalPath;
  final String? editedPath;
  final String thumbnailPath;

  const StepImage({
    required this.id,
    required this.order,
    required this.originalPath,
    required this.editedPath,
    required this.thumbnailPath,
  });

  String get displayPath => editedPath ?? originalPath;

  StepImage copyWith({
    Object? id = _undefined,
    Object? order = _undefined,
    Object? originalPath = _undefined,
    Object? editedPath = _undefined,
    Object? thumbnailPath = _undefined,
  }) {
    return StepImage(
      id: id == _undefined ? this.id : id as String,
      order: order == _undefined ? this.order : order as int,
      originalPath:
          originalPath == _undefined
              ? this.originalPath
              : originalPath as String,
      editedPath:
          editedPath == _undefined
              ? this.editedPath
              : editedPath as String?,
      thumbnailPath:
          thumbnailPath == _undefined
              ? this.thumbnailPath
              : thumbnailPath as String,
    );
  }
}