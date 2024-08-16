import 'package:flutter/material.dart';
import 'package:flutter_drawing_board/src/src.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('UndoRedoStack Tests', () {
    late ValueNotifier<List<Stroke>> strokesNotifier;
    late ValueNotifier<Stroke?> currentStrokeNotifier;
    late UndoRedoStack undoRedoStack;

    setUp(() {
      strokesNotifier = ValueNotifier([]);
      currentStrokeNotifier = ValueNotifier(null);
      undoRedoStack = UndoRedoStack(
        strokesNotifier: strokesNotifier,
        currentStrokeNotifier: currentStrokeNotifier,
      );
    });

    test('Initial State', () {
      expect(strokesNotifier.value, isEmpty);
      expect(currentStrokeNotifier.value, isNull);
      expect(undoRedoStack.canRedo.value, isFalse);
    });

    test('Add Stroke and Undo', () {
      final stroke = NormalStroke(points: [Offset.zero]);
      strokesNotifier.value = [stroke];

      undoRedoStack.undo();
      expect(strokesNotifier.value, isEmpty);
      expect(undoRedoStack.canRedo.value, isTrue);
    });

    test('Redo Operation', () {
      final stroke = NormalStroke(points: [Offset.zero]);
      strokesNotifier.value = [stroke];

      // First, perform an undo
      undoRedoStack.undo();
      expect(strokesNotifier.value, isEmpty);
      expect(undoRedoStack.canRedo.value, isTrue);

      // Now, test the redo functionality
      undoRedoStack.redo();
      expect(strokesNotifier.value, isNotEmpty);
      expect(strokesNotifier.value.length, equals(1));
      expect(undoRedoStack.canRedo.value, isFalse);
    });

    test('Clear Operation', () {
      undoRedoStack.clear();
      expect(strokesNotifier.value, isEmpty);
      expect(currentStrokeNotifier.value, isNull);
      expect(undoRedoStack.canRedo.value, isFalse);
    });
  });
}
