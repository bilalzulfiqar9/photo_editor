import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';

import 'package:in_app_purchase/in_app_purchase.dart';

abstract class PaymentRepository {
  Future<Either<Failure, void>> makePayment(
    int amount,
    String currency,
  ); // Keeping for backward compatibility if needed, or deprecating
  Future<Either<Failure, void>> subscribeToPlan(ProductDetails product);
  Future<Either<Failure, List<ProductDetails>>> getProducts();
  Future<Either<Failure, void>> restorePurchases();
}
