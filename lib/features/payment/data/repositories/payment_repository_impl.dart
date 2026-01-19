import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/repositories/payment_repository.dart';
import '../datasources/iap_service.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final IAPService iapService;
  // Stubbing StripeService usage or removing it if completely replacing.
  // Assuming full replacement based on user request.

  PaymentRepositoryImpl(this.iapService);

  @override
  Future<Either<Failure, void>> makePayment(int amount, String currency) async {
    return Left(ServerFailure('Deprecated'));
  }

  @override
  Future<Either<Failure, void>> subscribeToPlan(ProductDetails product) async {
    try {
      await iapService.buyProduct(product);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ProductDetails>>> getProducts() async {
    try {
      final products = await iapService.getProducts({
        'subscription_monthly',
        'subscription_yearly',
        'lifetime_access',
      });
      return Right(products);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> restorePurchases() async {
    try {
      await iapService.restorePurchases();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
