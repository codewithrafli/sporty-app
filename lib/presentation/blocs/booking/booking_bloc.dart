import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/datasources/sportly_remote_data_source.dart';
import '../../../data/models/booking_model.dart';

sealed class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

class BookingCreateRequested extends BookingEvent {
  const BookingCreateRequested({
    required this.eventSlug,
    required this.name,
    required this.phone,
    required this.email,
  });

  final String eventSlug;
  final String name;
  final String phone;
  final String email;

  @override
  List<Object?> get props => [eventSlug, name, phone, email];
}

class BookingLookupRequested extends BookingEvent {
  const BookingLookupRequested({required this.code, required this.email});

  final String code;
  final String email;

  @override
  List<Object?> get props => [code, email];
}

class BookingResetRequested extends BookingEvent {
  const BookingResetRequested();
}

sealed class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {
  const BookingInitial();
}

class BookingLoading extends BookingState {
  const BookingLoading();
}

class BookingLoaded extends BookingState {
  const BookingLoaded({
    required this.booking,
    this.paymentRequired = false,
    this.paymentUrl,
  });

  final Booking booking;
  final bool paymentRequired;
  final String? paymentUrl;

  @override
  List<Object?> get props => [booking, paymentRequired, paymentUrl];
}

class BookingFailure extends BookingState {
  const BookingFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  BookingBloc(this._remoteDataSource) : super(const BookingInitial()) {
    on<BookingCreateRequested>(_onCreateRequested);
    on<BookingLookupRequested>(_onLookupRequested);
    on<BookingResetRequested>((event, emit) => emit(const BookingInitial()));
  }

  final SportlyRemoteDataSource _remoteDataSource;

  Future<void> _onCreateRequested(
    BookingCreateRequested event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());
    try {
      final result = await _remoteDataSource.createBooking(
        eventSlug: event.eventSlug,
        name: event.name,
        phone: event.phone,
        email: event.email,
      );
      emit(
        BookingLoaded(
          booking: result.booking,
          paymentRequired: result.paymentRequired,
          paymentUrl: result.paymentUrl,
        ),
      );
    } catch (error) {
      emit(BookingFailure(error.toString()));
    }
  }

  Future<void> _onLookupRequested(
    BookingLookupRequested event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());
    try {
      emit(
        BookingLoaded(
          booking: await _remoteDataSource.getBooking(
            code: event.code,
            email: event.email,
          ),
        ),
      );
    } catch (error) {
      emit(BookingFailure(error.toString()));
    }
  }
}
