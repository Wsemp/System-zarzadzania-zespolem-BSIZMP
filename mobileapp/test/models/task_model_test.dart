import 'package:flutter_test/flutter_test.dart';
import 'package:mobileapp/models/task_model.dart';

void main() {
  // ─── TaskModel.fromJson ───────────────────────────────────────────────────

  group('TaskModel.fromJson – podstawowe pola', () {
    test('parsuje pełny poprawny JSON', () {
      final json = {
        'id': 1,
        'title': 'Naprawić buga',
        'description': 'Opis zadania',
        'status': 'todo',
        'priority': 'high',
        'area': 'backend',
        'assigned_to': 5,
        'project': 3,
        'tag_ids': [1, 2],
        'due_date': '2026-06-01',
        'anonymous_reporter': false,
      };

      final task = TaskModel.fromJson(json);

      expect(task.id, equals(1));
      expect(task.title, equals('Naprawić buga'));
      expect(task.description, equals('Opis zadania'));
      expect(task.status, equals(TaskStatus.todo));
      expect(task.priority, equals(TaskPriority.high));
      expect(task.area, equals(TaskArea.backend));
      expect(task.assignedTo, equals(5));
      expect(task.project, equals(3));
      expect(task.tagIds, equals([1, 2]));
      expect(task.dueDate, equals('2026-06-01'));
      expect(task.anonymousReporter, isFalse);
    });

    test('domyślny priorytet = medium gdy brak pola', () {
      final json = {
        'id': 2,
        'title': 'Test',
        'description': '',
        'status': 'todo',
        'tag_ids': [],
      };
      expect(TaskModel.fromJson(json).priority, equals(TaskPriority.medium));
    });

    test('domyślny status = todo gdy nieznana wartość', () {
      final json = {
        'id': 3,
        'title': 'Test',
        'description': '',
        'status': 'nieznany_status',
        'tag_ids': [],
      };
      expect(TaskModel.fromJson(json).status, equals(TaskStatus.todo));
    });

    test('area = null gdy brak pola', () {
      final json = {
        'id': 4,
        'title': 'Test',
        'description': '',
        'status': 'todo',
        'tag_ids': [],
      };
      expect(TaskModel.fromJson(json).area, isNull);
    });

    test('tagIds puste gdy brak pola tag_ids i tags', () {
      final json = {
        'id': 5,
        'title': 'Test',
        'description': '',
        'status': 'todo',
      };
      expect(TaskModel.fromJson(json).tagIds, isEmpty);
    });
  });

  // ─── Parsowanie project ───────────────────────────────────────────────────

  group('TaskModel.fromJson – parsowanie project', () {
    test('projekt jako int', () {
      final json = {
        'id': 1,
        'title': 'x',
        'description': '',
        'status': 'todo',
        'tag_ids': [],
        'project': 7,
      };
      expect(TaskModel.fromJson(json).project, equals(7));
    });

    test('projekt jako URL (format Render)', () {
      final json = {
        'id': 1,
        'title': 'x',
        'description': '',
        'status': 'todo',
        'tag_ids': [],
        'project':
            'https://system-zarzadzania-zespolem-bsizmp.onrender.com/api/projects/6/',
      };
      expect(TaskModel.fromJson(json).project, equals(6));
    });

    test('projekt null gdy brak pola', () {
      final json = {
        'id': 1,
        'title': 'x',
        'description': '',
        'status': 'todo',
        'tag_ids': [],
      };
      expect(TaskModel.fromJson(json).project, isNull);
    });
  });

  // ─── Parsowanie assigned_to ───────────────────────────────────────────────

  group('TaskModel.fromJson – parsowanie assigned_to', () {
    test('assigned_to jako int', () {
      final json = {
        'id': 1,
        'title': 'x',
        'description': '',
        'status': 'todo',
        'tag_ids': [],
        'assigned_to': 29,
      };
      expect(TaskModel.fromJson(json).assignedTo, equals(29));
    });

    test('assigned_to jako Map z id', () {
      final json = {
        'id': 1,
        'title': 'x',
        'description': '',
        'status': 'todo',
        'tag_ids': [],
        'assigned_to': {'id': 29, 'username': 'wiktor'},
      };
      final task = TaskModel.fromJson(json);
      expect(task.assignedTo, equals(29));
      expect(task.assignedToUsername, equals('wiktor'));
    });

    test('assigned_to null gdy brak pola', () {
      final json = {
        'id': 1,
        'title': 'x',
        'description': '',
        'status': 'todo',
        'tag_ids': [],
      };
      expect(TaskModel.fromJson(json).assignedTo, isNull);
    });
  });

  // ─── Statusy ─────────────────────────────────────────────────────────────

  group('TaskStatus.fromString', () {
    test(
      'todo',
      () => expect(TaskStatusExt.fromString('todo'), TaskStatus.todo),
    );
    test(
      'In progress',
      () => expect(
        TaskStatusExt.fromString('In progress'),
        TaskStatus.inProgress,
      ),
    );
    test(
      'in_progress',
      () => expect(
        TaskStatusExt.fromString('in_progress'),
        TaskStatus.inProgress,
      ),
    );
    test(
      'done',
      () => expect(TaskStatusExt.fromString('done'), TaskStatus.done),
    );
    test(
      'null → todo',
      () => expect(TaskStatusExt.fromString(null), TaskStatus.todo),
    );
  });

  // ─── Priorytety ───────────────────────────────────────────────────────────

  group('TaskPriority.fromString', () {
    test(
      'low',
      () => expect(TaskPriorityExt.fromString('low'), TaskPriority.low),
    );
    test(
      'medium',
      () => expect(TaskPriorityExt.fromString('medium'), TaskPriority.medium),
    );
    test(
      'high',
      () => expect(TaskPriorityExt.fromString('high'), TaskPriority.high),
    );
    test(
      'null → medium',
      () => expect(TaskPriorityExt.fromString(null), TaskPriority.medium),
    );
    test(
      'nieznana wartość → medium',
      () => expect(TaskPriorityExt.fromString('urgent'), TaskPriority.medium),
    );
  });

  // ─── copyWith ─────────────────────────────────────────────────────────────

  group('TaskModel.copyWith', () {
    final base = TaskModel(
      id: 1,
      title: 'Oryginał',
      description: 'opis',
      status: TaskStatus.todo,
      priority: TaskPriority.low,
      tagIds: const [1, 2],
      assignedTo: 5,
      dueDate: '2026-06-01',
    );

    test('zmienia tylko title', () {
      final updated = base.copyWith(title: 'Nowy tytuł');
      expect(updated.title, equals('Nowy tytuł'));
      expect(updated.description, equals('opis'));
      expect(updated.status, equals(TaskStatus.todo));
    });

    test('clearAssignee usuwa przypisanie', () {
      final updated = base.copyWith(clearAssignee: true);
      expect(updated.assignedTo, isNull);
      expect(updated.assignedToUsername, isNull);
    });

    test('clearDueDate usuwa termin', () {
      final updated = base.copyWith(clearDueDate: true);
      expect(updated.dueDate, isNull);
    });

    test('id nigdy się nie zmienia', () {
      final updated = base.copyWith(title: 'coś');
      expect(updated.id, equals(1));
    });
  });
}
