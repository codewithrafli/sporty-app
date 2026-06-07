import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/booking_model.dart';
import '../blocs/booking/booking_bloc.dart';
import '../widgets/remote_image.dart';

class TicketPage extends StatefulWidget {
  const TicketPage({required this.booking, super.key});

  final Booking booking;

  @override
  State<TicketPage> createState() => _TicketPageState();
}

class _TicketPageState extends State<TicketPage> {
  late Booking _booking;

  @override
  void initState() {
    super.initState();
    _booking = widget.booking;
  }

  void _refresh() {
    context.read<BookingBloc>().add(
      BookingLookupRequested(code: _booking.code, email: _booking.email),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingBloc, BookingState>(
      listener: (context, state) {
        if (state is BookingLoaded) {
          setState(() => _booking = state.booking);
        }
        if (state is BookingFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Entrance Ticket'),
          actions: [
            BlocBuilder<BookingBloc, BookingState>(
              builder: (context, state) => IconButton(
                onPressed: state is BookingLoading ? null : _refresh,
                icon: state is BookingLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh_rounded),
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(18),
                    child: SizedBox(
                      height: 150,
                      width: double.infinity,
                      child: RemoteImage(url: _booking.event.imageUrl),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    _booking.event.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _TicketDetail(
                          label: 'Code',
                          value: _booking.code,
                        ),
                      ),
                      Expanded(
                        child: _TicketDetail(
                          label: 'Participant',
                          value: _booking.name,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _TicketDetail(
                          label: 'Status',
                          value: _booking.isCheckedIn
                              ? 'Checked In'
                              : 'Not Started',
                        ),
                      ),
                      Expanded(
                        child: _TicketDetail(
                          label: 'Booking',
                          value: _booking.paymentStatus.toUpperCase(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _TicketDetail(
                    label: 'Venue',
                    value: _booking.event.venue?.name ?? 'To be announced',
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _TicketDetail(
                          label: 'Post Code',
                          value: _booking.event.venue?.postalCode ?? 'N/A',
                        ),
                      ),
                      Expanded(
                        child: _TicketDetail(
                          label: 'Started At',
                          value: formatEventDate(_booking.event.date),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Entrance Ticket',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 18),
                  if (_booking.isPaid) ...[
                    const Text(
                      'Scan QR Code for Check-in',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 14),
                    QrImageView(
                      data: _booking.code,
                      size: 210,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: AppColors.dark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _booking.code,
                      style: const TextStyle(
                        color: AppColors.muted,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ] else ...[
                    const Icon(
                      Icons.schedule_rounded,
                      size: 52,
                      color: AppColors.orange,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Payment is still pending, so your check-in QR code is not available yet.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.muted, height: 1.45),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TicketDetail extends StatelessWidget {
  const _TicketDetail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.notes_rounded, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: AppColors.muted, fontSize: 12),
              ),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
