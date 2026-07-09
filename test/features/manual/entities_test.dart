import 'package:flutter_test/flutter_test.dart';
import 'package:snapflow/features/manual/domain/entities.dart';

void main() {
  group('Manual', () {
    test('copyWith updates only specified fields', () {
      final created = DateTime(2026, 1, 1);
      final m = Manual(
        id: 'm1',
        title: 'A',
        coverImagePath: null,
        isFavorite: false,
        createdAt: created,
        updatedAt: created,
        steps: const [],
      );
      final m2 = m.copyWith(title: 'B', isFavorite: true);
      expect(m2.title, 'B');
      expect(m2.id, 'm1');
      expect(m2.isFavorite, isTrue);
      expect(m2.steps, isEmpty);
      expect(m2.createdAt, created);
    });
  });

  group('Step', () {
    test('copyWith updates note and completed', () {
      final s = Step(
        id: 's1',
        order: 100,
        title: 't',
        note: '',
        completed: false,
        images: [],
        optionalFields: {},
      createdAt: DateTime(2026, 1, 1),
      );
      final s2 = s.copyWith(note: 'new', completed: true);
      expect(s2.note, 'new');
      expect(s2.title, 't');
      expect(s2.completed, isTrue);
    });
  });

  group('StepImage', () {
    test('displayPath prefers editedPath over originalPath', () {
      const img = StepImage(
        id: 'i1',
        order: 100,
        originalPath: '/orig.jpg',
        editedPath: '/edit.jpg',
        thumbnailPath: '/thumb.jpg',
      );
      expect(img.displayPath, '/edit.jpg');

      final unedited = img.copyWith(editedPath: null);
      expect(unedited.displayPath, '/orig.jpg');
    });
  });
}