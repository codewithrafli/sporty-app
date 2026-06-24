import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/datasources/sportly_remote_data_source.dart';
import '../../../data/models/event_model.dart';

sealed class RewardsEvent extends Equatable {
  const RewardsEvent();

  @override
  List<Object?> get props => [];
}

class RewardsLoadRequested extends RewardsEvent {
  const RewardsLoadRequested();
}

sealed class RewardsState extends Equatable {
  const RewardsState();

  @override
  List<Object?> get props => [];
}

class RewardsInitial extends RewardsState {
  const RewardsInitial();
}

class RewardsLoading extends RewardsState {
  const RewardsLoading();
}

class RewardsLoaded extends RewardsState {
  const RewardsLoaded({required this.events});

  final List<SportEvent> events;

  double get totalPrizePool =>
      events.fold(0, (sum, e) => sum + e.totalPrize);

  List<SportEvent> get sortedByPrize => [...events]
    ..sort((a, b) => b.totalPrize.compareTo(a.totalPrize));

  List<SportEvent> get winners =>
      events.where((e) => e.winnerName != null).toList();

  @override
  List<Object?> get props => [events];
}

class RewardsFailure extends RewardsState {
  const RewardsFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class RewardsBloc extends Bloc<RewardsEvent, RewardsState> {
  RewardsBloc(this._remoteDataSource) : super(const RewardsInitial()) {
    on<RewardsLoadRequested>(_onLoadRequested);
  }

  final SportlyRemoteDataSource _remoteDataSource;

  Future<void> _onLoadRequested(
    RewardsLoadRequested event,
    Emitter<RewardsState> emit,
  ) async {
    emit(const RewardsLoading());
    try {
      final events = await _remoteDataSource.getEvents();
      emit(RewardsLoaded(events: events));
    } catch (error) {
      emit(RewardsFailure(error.toString()));
    }
  }
}
