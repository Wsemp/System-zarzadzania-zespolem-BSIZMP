import 'package:flutter_test/flutter_test.dart';
import 'package:mobileapp/models/project_model.dart';

void main() {
  // ─── ProjectModel.fromJson – ownerId ─────────────────────────────────────

  group('ProjectModel.fromJson – ownerId', () {
    test('owner jako int', () {
      final json = {'id': 1, 'name': 'Projekt', 'description': '', 'owner': 28};
      expect(ProjectModel.fromJson(json).ownerId, equals(28));
    });

    test('owner jako URL string', () {
      final json = {
        'id': 1,
        'name': 'Projekt',
        'description': '',
        'owner':
            'https://system-zarzadzania-zespolem-bsizmp.onrender.com/api/users/28/',
      };
      expect(ProjectModel.fromJson(json).ownerId, equals(28));
    });

    test('owner jako Map z id', () {
      final json = {
        'id': 1,
        'name': 'Projekt',
        'description': '',
        'owner': {'id': 28, 'username': 'wiktor'},
      };
      expect(ProjectModel.fromJson(json).ownerId, equals(28));
    });

    test('owner_id jako fallback gdy brak owner', () {
      final json = {
        'id': 1,
        'name': 'Projekt',
        'description': '',
        'owner_id': 28,
      };
      expect(ProjectModel.fromJson(json).ownerId, equals(28));
    });

    test('created_by jako fallback gdy brak owner i owner_id', () {
      final json = {
        'id': 1,
        'name': 'Projekt',
        'description': '',
        'created_by': 28,
      };
      expect(ProjectModel.fromJson(json).ownerId, equals(28));
    });

    test('ownerId null gdy brak wszystkich pól', () {
      final json = {'id': 1, 'name': 'Projekt', 'description': ''};
      expect(ProjectModel.fromJson(json).ownerId, isNull);
    });
  });

  // ─── ProjectModel.fromJson – members ─────────────────────────────────────

  group('ProjectModel.fromJson – members', () {
    test('pusta lista members gdy brak pola', () {
      final json = {'id': 1, 'name': 'Projekt', 'description': ''};
      expect(ProjectModel.fromJson(json).members, isEmpty);
    });

    test('parsuje listę members', () {
      final json = {
        'id': 1,
        'name': 'Projekt',
        'description': '',
        'members': [
          {
            'id': 10,
            'username': 'ala',
            'email': 'ala@test.com',
            'is_staff': false,
            'is_active': true,
          },
          {
            'id': 11,
            'username': 'ola',
            'email': 'ola@test.com',
            'is_staff': false,
            'is_active': true,
          },
        ],
      };
      final project = ProjectModel.fromJson(json);
      expect(project.members.length, equals(2));
      expect(project.members[0].username, equals('ala'));
      expect(project.members[1].id, equals(11));
    });
  });

  // ─── ProjectModel – podstawowe pola ──────────────────────────────────────

  group('ProjectModel.fromJson – podstawowe pola', () {
    test('parsuje id i name', () {
      final json = {
        'id': 5,
        'name': 'Taskomat',
        'description': 'Opis projektu',
      };
      final project = ProjectModel.fromJson(json);
      expect(project.id, equals(5));
      expect(project.name, equals('Taskomat'));
      expect(project.description, equals('Opis projektu'));
    });

    test('description domyślnie pusty string gdy null', () {
      final json = {'id': 5, 'name': 'Taskomat', 'description': null};
      expect(ProjectModel.fromJson(json).description, equals(''));
    });
  });

  // ─── Logika isAdmin (symulacja z project_detail_screen) ──────────────────

  group('Logika isAdmin – owner vs member', () {
    test('zwraca true gdy currentUserId == ownerId', () {
      final project = ProjectModel(
        id: 1,
        name: 'P',
        description: '',
        ownerId: 28,
      );
      const currentUserId = 28;
      final isAdmin = project.ownerId != null
          ? project.ownerId == currentUserId
          : false;
      expect(isAdmin, isTrue);
    });

    test('zwraca false gdy currentUserId != ownerId', () {
      final project = ProjectModel(
        id: 1,
        name: 'P',
        description: '',
        ownerId: 28,
      );
      const currentUserId = 99;
      final isAdmin = project.ownerId != null
          ? project.ownerId == currentUserId
          : false;
      expect(isAdmin, isFalse);
    });

    test('fallback false gdy ownerId null', () {
      final project = ProjectModel(
        id: 1,
        name: 'P',
        description: '',
        ownerId: null,
      );
      const currentUserId = 28;
      final isAdmin = project.ownerId != null
          ? project.ownerId == currentUserId
          : false;
      expect(isAdmin, isFalse);
    });
  });
}
