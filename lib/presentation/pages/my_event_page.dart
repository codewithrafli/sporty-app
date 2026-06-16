import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../blocs/booking/booking_bloc.dart';
import '../widgets/primary_button.dart';

class MyEventPage extends StatefulWidget {
  const MyEventPage({super.key});

  @override
  State<MyEventPage> createState() => _MyEventPageState();
}

class _MyEventPageState extends State<MyEventPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _lookup() {
    if (!_formKey.currentState!.validate()) return;
    context.read<BookingBloc>().add(
      BookingLookupRequested(
        code: _codeController.text,
        email: _emailController.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BookingBloc, BookingState>(
      listener: (context, state) {
        if (state is BookingLoaded) {
          context.push('/ticket/${state.booking.code}', extra: state.booking);
        }
      },
      child: ColoredBox(
        color: AppColors.purple,
        child: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 110),
            children: [
              Image.asset(
                'assets/images/group.png',
                height: 280,
                fit: BoxFit.contain,
              ),
              Transform.translate(
                offset: const Offset(0, -10),
                child: Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Text(
                          'Check Your Booking',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(
                          color: AppColors.border,
                          height: 1,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _codeController,
                          textCapitalization: TextCapitalization.characters,
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Enter your booking ID.'
                              : null,
                          decoration: const InputDecoration(
                            labelText: 'Booking ID',
                            hintText: "What's your booking ID",
                            prefixIcon: Icon(
                              Icons.confirmation_number_outlined,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) =>
                              value == null || !value.contains('@')
                              ? 'Enter your booking email.'
                              : null,
                          decoration: const InputDecoration(
                            labelText: 'Email Address',
                            hintText: "What's your email address",
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(
                          color: AppColors.border,
                          height: 1,
                        ),
                        const SizedBox(height: 16),
                        BlocBuilder<BookingBloc, BookingState>(
                          builder: (context, state) {
                            return Column(
                              children: [
                                if (state is BookingFailure) ...[
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    margin: const EdgeInsets.only(bottom: 14),
                                    decoration: BoxDecoration(
                                      color: AppColors.orange,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Text(
                                      state.message,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                                PrimaryButton(
                                  label: 'Find My Booking',
                                  icon: Icons.search_rounded,
                                  loading: state is BookingLoading,
                                  onPressed: _lookup,
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
