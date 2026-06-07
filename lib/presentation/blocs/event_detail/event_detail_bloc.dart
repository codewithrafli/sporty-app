import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/datasources/sportly_remote_data_source.dart';
import '../../../data/models/event_model.dart';

sealed class EventDetailEvent extends Equatable {
  const EventDetailEvent();

  @override
  List<Object?> get props => [];
}

class EventDetailLoadRequested extends EventDetailEvent {
  const EventDetailLoadRequested(this.slug);

  final String slug;

  @override
  List<Object?> get props => [slug];
}

sealed class EventDetailState extends Equatable {
  const EventDetailState();

  @override
  List<Object?> get props => [];
}

class EventDetailLoading extends EventDetailState {
  const EventDetailLoading();
}

class EventDetailLoaded extends EventDetailState {
  const EventDetailLoaded(this.event);

  final SportEvent event;

  @override
  List<Object?> get props => [event];
}

class EventDetailFailure extends EventDetailState {
  const EventDetailFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class EventDetailBloc extends Bloc<EventDetailEvent, EventDetailState> {
  EventDetailBloc(this._remoteDataSource) : super(const EventDetailLoading()) {
    on<EventDetailLoadRequested>(_onLoadRequested);
  }

  final SportlyRemoteDataSource _remoteDataSource;

  Future<void> _onLoadRequested(
    EventDetailLoadRequested event,
    Emitter<EventDetailState> emit,
  ) async {
    emit(const EventDetailLoading());
    try {
      emit(EventDetailLoaded(await _remoteDataSource.getEvent(event.slug)));
    } catch (error) {
      emit(EventDetailFailure(error.toString()));
    }
  }
}
