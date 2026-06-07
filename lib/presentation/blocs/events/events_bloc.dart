import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/datasources/sportly_remote_data_source.dart';
import '../../../data/models/category_model.dart';
import '../../../data/models/event_model.dart';

sealed class EventsEvent extends Equatable {
  const EventsEvent();

  @override
  List<Object?> get props => [];
}

class EventsLoadRequested extends EventsEvent {
  const EventsLoadRequested({this.query, this.categoryId});

  final String? query;
  final int? categoryId;

  @override
  List<Object?> get props => [query, categoryId];
}

sealed class EventsState extends Equatable {
  const EventsState();

  @override
  List<Object?> get props => [];
}

class EventsInitial extends EventsState {
  const EventsInitial();
}

class EventsLoading extends EventsState {
  const EventsLoading();
}

class EventsLoaded extends EventsState {
  const EventsLoaded({
    required this.events,
    required this.categories,
    this.query,
    this.categoryId,
  });

  final List<SportEvent> events;
  final List<EventCategory> categories;
  final String? query;
  final int? categoryId;

  @override
  List<Object?> get props => [events, categories, query, categoryId];
}

class EventsFailure extends EventsState {
  const EventsFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class EventsBloc extends Bloc<EventsEvent, EventsState> {
  EventsBloc(this._remoteDataSource) : super(const EventsInitial()) {
    on<EventsLoadRequested>(_onLoadRequested);
  }

  final SportlyRemoteDataSource _remoteDataSource;
  List<EventCategory>? _categories;

  Future<void> _onLoadRequested(
    EventsLoadRequested event,
    Emitter<EventsState> emit,
  ) async {
    emit(const EventsLoading());
    try {
      _categories ??= await _remoteDataSource.getCategories();
      final events = await _remoteDataSource.getEvents(
        query: event.query,
        categoryId: event.categoryId,
      );
      emit(
        EventsLoaded(
          events: events,
          categories: _categories!,
          query: event.query,
          categoryId: event.categoryId,
        ),
      );
    } catch (error) {
      emit(EventsFailure(error.toString()));
    }
  }
}
