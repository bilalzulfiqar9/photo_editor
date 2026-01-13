import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/stripe_service.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final StripeService stripeService;

  PaymentRepositoryImpl(this.stripeService);

  @override
  Future<Either<Failure, void>> makePayment(int amount, String currency) async {
    try {
      await stripeService.makePayment(amount, currency);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> subscribeToPlan(String planId) async {
    try {
      await stripeService.subscribeToPlan(planId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
