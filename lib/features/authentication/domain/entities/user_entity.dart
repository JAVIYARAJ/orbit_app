import 'package:equatable/equatable.dart';

/// A signed-in Orbit user — the domain-level representation, decoupled from
/// Supabase's `User` type.
class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.email,
    this.name,
    this.avatarUrl,
  });

  final String id;
  final String email;
  final String? name;
  final String? avatarUrl;

  /// Single uppercase letter used as a fallback avatar (mirrors the web app).
  String get avatarInitial {
    final source = (name?.trim().isNotEmpty ?? false) ? name!.trim() : email;
    return source.isEmpty ? '?' : source[0].toUpperCase();
  }

  @override
  List<Object?> get props => [id, email, name, avatarUrl];
}
