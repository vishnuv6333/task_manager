import '../../core/usecases/usecase.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginParams {
  final String email;
  final String password;

  LoginParams(this.email, this.password);
}

class LoginUseCase implements UseCase<User, LoginParams> {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  @override
  Future<User> call(LoginParams params) async {
    return await repository.login(params.email, params.password);
  }
}
