import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../../domain/repositories/payment_repository.dart';

abstract class PaymentState extends Equatable {
  const PaymentState();
  @override
  List<Object> get props => [];
}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentSuccess extends PaymentState {}

class PaymentFailure extends PaymentState {
  final String message;
  const PaymentFailure(this.message);
  @override
  List<Object> get props => [message];
}

class PaymentProductsLoaded extends PaymentState {
  final List<ProductDetails> products;
  const PaymentProductsLoaded(this.products);
  @override
  List<Object> get props => [products];
}

class PaymentCubit extends Cubit<PaymentState> {
  final PaymentRepository repository;

  PaymentCubit(this.repository) : super(PaymentInitial());

  Future<void> loadProducts() async {
    emit(PaymentLoading());
    final result = await repository.getProducts();
    result.fold(
      (failure) => emit(PaymentFailure(failure.message)),
      (products) => emit(PaymentProductsLoaded(products)),
    );
  }

  Future<void> subscribeToPlan(ProductDetails product) async {
    // Keep loading state or show overlay?
    // Usually IAP is async and handled by stream, but here we trigger the buy flow.
    // The stream listener in IAPService should handle success/updates.
    // Ideally we might not emit Loading here effectively if we want to keep showing products.
    // proper way: emit loading, wait for result.
    final result = await repository.subscribeToPlan(product);
    result.fold(
      (failure) => emit(PaymentFailure(failure.message)),
      (_) =>
          null, // Purchase flow initiated. Success handled via stream if we wired it up fully.
      // For this simplified version, assuming repo returns Right(null) when flow starts.
    );
  }

  Future<void> restorePurchases() async {
    emit(PaymentLoading());
    final result = await repository.restorePurchases();
    result.fold(
      (failure) => emit(PaymentFailure(failure.message)),
      (_) => emit(PaymentSuccess()), // Or reload products/check entitlements
    );
  }
}
