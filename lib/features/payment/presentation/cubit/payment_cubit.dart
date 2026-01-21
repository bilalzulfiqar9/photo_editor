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
    final result = await repository.subscribeToPlan(product);
    result.fold(
      (failure) => emit(PaymentFailure(failure.message)),
      (_) => null,
    );
  }

  Future<void> restorePurchases() async {
    emit(PaymentLoading());
    final result = await repository.restorePurchases();
    result.fold(
      (failure) => emit(PaymentFailure(failure.message)),
      (_) => emit(PaymentSuccess()),
    );
  }

  Future<bool> get isPremium => repository.isUserPremium();
}
