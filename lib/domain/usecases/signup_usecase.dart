import '../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class SignupParams {
  final String email;
  final String password;

  SignupParams(this.email, this.password);
}

class SignupUseCase implements UseCase<User, SignupParams> {
  final AuthRepository repository;

  SignupUseCase(this.repository);

  @override
  Future<User> call(SignupParams params) async {
    return await repository.signup(params.email, params.password);
  }
}
