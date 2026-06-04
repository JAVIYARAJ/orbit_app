import 'package:orbit_app/core/utils/typedefs.dart';
import 'package:orbit_app/core/utils/use_case.dart';
import 'package:orbit_app/features/authentication/domain/repositories/auth_repository.dart';

/// Starts the Google OAuth sign-in flow.
class LoginWithGoogleUseCase extends UseCaseWithoutParams<void> {
  const LoginWithGoogleUseCase(this._repository);

  final AuthRepository _repository;

  @override
  ResultVoid call() => _repository.loginWithGoogle();
}
