import 'package:orbit_app/features/authentication/domain/entities/user_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Maps a Supabase [User] onto the domain [UserEntity].
///
/// The web app derives the display name from `user_metadata.name` and falls
/// back to the email prefix — mirrored here for parity.
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    super.name,
    super.avatarUrl,
  });

  factory UserModel.fromSupabaseUser(User user) {
    final metadata = user.userMetadata ?? const <String, dynamic>{};
    final email = user.email ?? '';
    final rawName = (metadata['name'] ?? metadata['full_name']) as String?;
    final name = (rawName != null && rawName.trim().isNotEmpty)
        ? rawName.trim()
        : (email.contains('@') ? email.split('@').first : null);
    final avatarUrl =
        (metadata['avatar_url'] ?? metadata['picture']) as String?;

    return UserModel(
      id: user.id,
      email: email,
      name: name,
      avatarUrl: avatarUrl,
    );
  }
}
