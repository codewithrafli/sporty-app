import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/event_model.dart';
import '../blocs/booking/booking_bloc.dart';
import '../widgets/primary_button.dart';
import '../widgets/remote_image.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({required this.event, super.key});

  final SportEvent event;

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<BookingBloc>().add(const BookingResetRequested());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<BookingBloc>().add(
      BookingCreateRequested(
        eventSlug: widget.event.slug,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
      ),
    );
  }

  void _handleSuccess(BookingLoaded state) {
    if (!mounted) return;
    if (state.paymentRequired) {
      context.go('/payment/${state.booking.code}', extra: state.booking);
    } else {
      context.go('/ticket/${state.booking.code}', extra: state.booking);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingBloc, BookingState>(
      listener: (context, state) {
        if (state is BookingLoaded) {
          _handleSuccess(state);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.purple,
          foregroundColor: Colors.white,
          title: const Text(
            'Registration',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: ListView(
          children: [
            const _ProgressHeader(),
            Transform.translate(
              offset: const Offset(0, -28),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _EventSummary(event: widget.event),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Personal Information',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _FormField(
                              controller: _nameController,
                              label: 'Complete Name',
                              hint: "What's your name",
                              icon: Icons.person_outline_rounded,
                              validator: (value) =>
                                  value == null || value.trim().length < 2
                                  ? 'Enter your complete name.'
                                  : null,
                            ),
                            _FormField(
                              controller: _phoneController,
                              label: 'Phone Number',
                              hint: "What's your phone number",
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              validator: (value) =>
                                  value == null || value.trim().length < 8
                                  ? 'Enter a valid phone number.'
                                  : null,
                            ),
                            _FormField(
                              controller: _emailController,
                              label: 'Email Address',
                              hint: "What's your email address",
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                final email = value?.trim() ?? '';
                                return RegExp(
                                      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                    ).hasMatch(email)
                                    ? null
                                    : 'Enter a valid email address.';
                              },
                            ),
                            BlocBuilder<BookingBloc, BookingState>(
                              builder: (context, state) {
                                return Column(
                                  children: [
                                    if (state is BookingFailure) ...[
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(12),
                                        margin: const EdgeInsets.only(
                                          bottom: 14,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFFFECE9),
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        child: Text(
                                          state.message,
                                          style: const TextStyle(
                                            color: AppColors.error,
                                          ),
                                        ),
                                      ),
                                    ],
                                    PrimaryButton(
                                      label: widget.event.price > 0
                                          ? 'Continue to Payment'
                                          : 'Complete Registration',
                                      loading: state is BookingLoading,
                                      onPressed: _submit,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
      color: AppColors.purple,
      padding: const EdgeInsets.fromLTRB(38, 30, 38, 50),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 24,
            left: 64,
            right: 64,
            child: Row(
              children: [
                Expanded(
                  child: _DashedLine(),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _ProgressStep(
                icon: Icons.event_note_outlined,
                number: '1',
                label: 'Booking',
                active: true,
              ),
              _ProgressStep(
                icon: Icons.credit_card_outlined,
                number: '2',
                label: 'Payment',
              ),
              _ProgressStep(
                icon: Icons.flag_outlined,
                number: '3',
                label: 'Get Ready',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DashedLine extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedLinePainter(),
      child: const SizedBox(height: 2, width: double.infinity),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..strokeWidth = 2;
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    double startX = 0;
    while (startX < size.width) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ProgressStep extends StatelessWidget {
  const _ProgressStep({
    required this.icon,
    required this.number,
    required this.label,
    this.active = false,
  });

  final IconData icon;
  final String number;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: active ? AppColors.orange : AppColors.dark,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white),
            ),
            Positioned(
              bottom: -8,
              left: 16,
              child: Container(
                width: 21,
                height: 21,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active ? AppColors.lime : Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  number,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}

class _EventSummary extends StatelessWidget {
  const _EventSummary({required this.event});

  final SportEvent event;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 164,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SizedBox(
              width: 118,
              height: 140,
              child: RemoteImage(url: event.imageUrl),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 12),
                Text(formatCurrency(event.price)),
                Text(
                  event.category.name,
                  style: const TextStyle(color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FormField extends StatelessWidget {
  const _FormField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.validator,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final String? Function(String?) validator;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 9),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon)),
          ),
        ],
      ),
    );
  }
}
