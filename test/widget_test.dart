import 'package:flutter_test/flutter_test.dart';
import 'package:orbit_app/features/authentication/domain/entities/user_entity.dart';

void main() {
  group('UserEntity.avatarInitial', () {
    test('uses the first letter of the name when present', () {
      const user = UserEntity(id: '1', email: 'alex@example.com', name: 'Alex');
      expect(user.avatarInitial, 'A');
    });

    test('falls back to the email when name is blank', () {
      const user = UserEntity(id: '1', email: 'zoe@example.com', name: '  ');
      expect(user.avatarInitial, 'Z');
    });

    test('returns "?" when both name and email are empty', () {
      const user = UserEntity(id: '1', email: '');
      expect(user.avatarInitial, '?');
    });
  });
}
