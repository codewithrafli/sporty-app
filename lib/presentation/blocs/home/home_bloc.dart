import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/datasources/sportly_remote_data_source.dart';
import '../../../data/models/home_data_model.dart';

sealed class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class HomeLoadRequested extends HomeEvent {
  const HomeLoadRequested();
}

sealed class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  const HomeLoaded(this.data);

  final HomeData data;

  @override
  List<Object?> get props => [data];
}

class HomeFailure extends HomeState {
  const HomeFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc(this._remoteDataSource) : super(const HomeInitial()) {
    on<HomeLoadRequested>(_onLoadRequested);
  }

  final SportlyRemoteDataSource _remoteDataSource;

  Future<void> _onLoadRequested(
    HomeLoadRequested event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());
    try {
      emit(HomeLoaded(await _remoteDataSource.getHome()));
    } catch (error) {
      emit(HomeFailure(error.toString()));
    }
  }
}
