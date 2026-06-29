import 'package:orbit_app/features/workspaces/domain/entities/workstation_entity.dart';

class WorkstationModel extends WorkstationEntity {
  const WorkstationModel({
    required super.id,
    required super.name,
    required super.role,
    required super.color,
    required super.ownerId,
  });

  factory WorkstationModel.fromJson(Map<String, dynamic> json) {
    return WorkstationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      color: json['color'] as String,
      ownerId: json['owner_id'] as String,
    );
  }
}
