import 'package:equatable/equatable.dart';

class WorkstationEntity extends Equatable {
  const WorkstationEntity({
    required this.id,
    required this.name,
    required this.role,
    required this.color,
    required this.ownerId,
  });

  final String id;
  final String name;
  final String role;
  final String color;
  final String ownerId;

  @override
  List<Object?> get props => [id, name, role, color, ownerId];
}
