import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl({required this.remoteDataSource});

  @override
  Future<User> login(String email, String password) async {
    try {
      final userCredential = await remoteDataSource.login(email, password);
      final firebaseUser = userCredential.user!;
      return User(id: firebaseUser.uid, email: firebaseUser.email!);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'An unknown error occurred during login.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<User> signup(String email, String password) async {
    try {
      final userCredential = await remoteDataSource.signup(email, password);
      final firebaseUser = userCredential.user!;
      return User(id: firebaseUser.uid, email: firebaseUser.email!);
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'An unknown error occurred during signup.');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    await remoteDataSource.logout();
  }

  @override
  Future<User?> getCurrentUser() async {
    final firebaseUser = remoteDataSource.getCurrentUser();
    if (firebaseUser != null) {
      return User(id: firebaseUser.uid, email: firebaseUser.email!);
    }
    return null;
  }
}
