import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class SignInAnonymouslyUseCase
    implements UseCase<Either<Failure, User>, NoParams> {
  final AuthRepository repository;

  SignInAnonymouslyUseCase(this.repository);

  @override
  Future<Either<Failure, User>> call(NoParams params) async {
    return await repository.signInAnonymously();
  }
}
