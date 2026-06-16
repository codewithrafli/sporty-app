import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/datasources/sportly_remote_data_source.dart';
import '../../data/models/booking_model.dart';
import '../widgets/primary_button.dart';
import '../widgets/remote_image.dart';

class PaymentSimulatorPage extends StatefulWidget {
  const PaymentSimulatorPage({
    required this.booking,
    required this.paymentUrl,
    required this.remoteDataSource,
    super.key,
  });

  final Booking booking;
  final String? paymentUrl;
  final SportlyRemoteDataSource remoteDataSource;

  @override
  State<PaymentSimulatorPage> createState() => _PaymentSimulatorPageState();
}

class _PaymentSimulatorPageState extends State<PaymentSimulatorPage> {
  bool _openingPayment = false;
  bool _checkingStatus = false;
  String? _error;
  String? _message;

  Future<void> _openMidtrans() async {
    final paymentUrl = widget.paymentUrl;
    final uri = paymentUrl == null ? null : Uri.tryParse(paymentUrl);
    if (uri == null || !uri.hasScheme) {
      setState(() {
        _error = 'Payment link is not available. Please create a new booking.';
        _message = null;
      });
      return;
    }

    setState(() {
      _openingPayment = true;
      _error = null;
      _message = null;
    });
    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!mounted) return;
      setState(() {
        _openingPayment = false;
        _message = opened
            ? 'Complete the payment in Midtrans, then refresh your status here.'
            : null;
        _error = opened ? null : 'Unable to open the Midtrans payment page.';
      });
    } catch (e) {
      setState(() {
        _openingPayment = false;
        _error = e.toString();
        _message = null;
      });
    }
  }

  Future<void> _refreshPaymentStatus() async {
    setState(() {
      _checkingStatus = true;
      _error = null;
      _message = null;
    });
    try {
      final booking = await widget.remoteDataSource.getBooking(
        code: widget.booking.code,
        email: widget.booking.email,
      );
      if (!mounted) return;
      if (booking.isPaid) {
        context.go('/ticket/${booking.code}', extra: booking);
        return;
      }
      setState(() {
        _checkingStatus = false;
        _message = 'Payment is still pending. Finish the Midtrans payment, then refresh again.';
      });
    } catch (e) {
      setState(() {
        _checkingStatus = false;
        _error = e.toString();
        _message = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Payment'),
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontFamily: 'Satoshi',
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 20, 18, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    width: 90,
                    height: 104,
                    child: RemoteImage(url: booking.event.imageUrl),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.event.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        booking.event.category.name,
                        style: const TextStyle(
                          color: AppColors.muted,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order Summary',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 16),
                _SummaryRow(
                  label: 'Participant',
                  value: booking.name,
                ),
                _SummaryRow(
                  label: 'Booking ID',
                  value: booking.code,
                ),
                const Divider(color: AppColors.border, height: 28),
                _SummaryRow(
                  label: 'Subtotal',
                  value: formatCurrency(booking.subtotal),
                ),
                _SummaryRow(
                  label: 'Tax (11%)',
                  value: formatCurrency(booking.tax),
                ),
                if (booking.insurance > 0)
                  _SummaryRow(
                    label: 'Insurance',
                    value: formatCurrency(booking.insurance),
                  ),
                const Divider(color: AppColors.border, height: 28),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Text(
                      formatCurrency(booking.total),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.lime.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.lime),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'You will be redirected to Midtrans to complete payment securely.',
                    style: TextStyle(fontSize: 12, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
          if (_message != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFFBE8),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                _message!,
                style: const TextStyle(color: AppColors.dark),
              ),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFECE9),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                _error!,
                style: const TextStyle(color: AppColors.error),
              ),
            ),
          ],
          const SizedBox(height: 24),
          PrimaryButton(
            label: 'Pay with Midtrans',
            icon: Icons.open_in_new_rounded,
            loading: _openingPayment,
            onPressed: _openMidtrans,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: _checkingStatus ? null : _refreshPaymentStatus,
              icon: _checkingStatus
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh_rounded),
              label: const Text('Refresh Payment Status'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.dark,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Satoshi',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: AppColors.muted),
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
