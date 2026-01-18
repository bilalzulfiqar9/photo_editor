import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
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

 class PaymentCubit extends Cubit<PaymentState> {
  final PaymentRepository repository;

  PaymentCubit(this.repository) : super(PaymentInitial());

  Future<void> makePayment(int amount, String currency) async {
    emit(PaymentLoading());
    final result = await repository.makePayment(amount, currency);
    result.fold(
      (failure) => emit(PaymentFailure(failure.message)),
      (_) => emit(PaymentSuccess()),
    );
  }

  Future<void> subscribeToPlan(String planId) async {
    emit(PaymentLoading());
    final result = await repository.subscribeToPlan(planId);
    result.fold(
      (failure) => emit(PaymentFailure(failure.message)),
      (_) => emit(PaymentSuccess()),
    );
  }
}
