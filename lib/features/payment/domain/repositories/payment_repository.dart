import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

abstract class PaymentRepository {
  Future<Either<Failure, void>> makePayment(int amount, String currency);
  Future<Either<Failure, void>> subscribeToPlan(String planId);
}
