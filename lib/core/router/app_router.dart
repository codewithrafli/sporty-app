import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../data/datasources/sportly_remote_data_source.dart';
import '../../data/models/booking_model.dart';
import '../../data/models/event_model.dart';
import '../../presentation/blocs/booking/booking_bloc.dart';
import '../../presentation/blocs/event_detail/event_detail_bloc.dart';
import '../../presentation/pages/booking_page.dart';
import '../../presentation/pages/browse_page.dart';
import '../../presentation/pages/event_detail_page.dart';
import '../../presentation/pages/main_page.dart';
import '../../presentation/pages/payment_simulator_page.dart';
import '../../presentation/pages/ticket_page.dart';

class AppRouter {
  AppRouter._();

  static GoRouter create(SportlyRemoteDataSource remoteDataSource) {
    return GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              MainPage(remoteDataSource: remoteDataSource),
        ),
        GoRoute(
          path: '/browse',
          builder: (context, state) {
            final category = int.tryParse(
              state.uri.queryParameters['category'] ?? '',
            );
            return BrowsePage(initialCategoryId: category);
          },
        ),
        GoRoute(
          path: '/events/:slug',
          builder: (context, state) {
            final slug = state.pathParameters['slug']!;
            return BlocProvider(
              create: (_) =>
                  EventDetailBloc(remoteDataSource)
                    ..add(EventDetailLoadRequested(slug)),
              child: EventDetailPage(slug: slug),
            );
          },
        ),
        GoRoute(
          path: '/booking/:slug',
          builder: (context, state) {
            final event = state.extra;
            if (event is! SportEvent) {
              return const _RouteErrorPage(
                message: 'Open registration from an event detail page.',
              );
            }
            return BlocProvider(
              create: (_) => BookingBloc(remoteDataSource),
              child: BookingPage(event: event),
            );
          },
        ),
        GoRoute(
          path: '/payment/:code',
          builder: (context, state) {
            final booking = state.extra;
            if (booking is! Booking) {
              return const _RouteErrorPage(
                message: 'Open payment from a booking.',
              );
            }
            return PaymentSimulatorPage(
              booking: booking,
              remoteDataSource: remoteDataSource,
            );
          },
        ),
        GoRoute(
          path: '/ticket/:code',
          builder: (context, state) {
            final booking = state.extra;
            if (booking is! Booking) {
              return const _RouteErrorPage(
                message: 'Find your booking from the My Event tab.',
              );
            }
            return BlocProvider(
              create: (_) => BookingBloc(remoteDataSource),
              child: TicketPage(booking: booking),
            );
          },
        ),
      ],
    );
  }
}

class _RouteErrorPage extends StatelessWidget {
  const _RouteErrorPage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(message, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
