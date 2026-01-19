part of 'studio_cubit.dart';

abstract class StudioState extends Equatable {
  const StudioState();

  @override
  List<Object> get props => [];
}

class StudioInitial extends StudioState {}

class StudioReady extends StudioState {
  final File file;
  const StudioReady(this.file);

  @override
  List<Object> get props => [file];
}

class StudioSaving extends StudioState {}

class StudioSaved extends StudioState {
  final File result;
  const StudioSaved(this.result);
  @override
  List<Object> get props => [result];
}

class StudioError extends StudioState {
  final String message;
  const StudioError(this.message);
  @override
  List<Object> get props => [message];
}
