import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/datasources/sportly_remote_data_source.dart';
import '../../data/models/booking_model.dart';
import '../widgets/primary_button.dart';
import '../widgets/remote_image.dart';

class PaymentSimulatorPage extends StatefulWidget {
  const PaymentSimulatorPage({
    required this.booking,
    required this.remoteDataSource,
    super.key,
  });

  final Booking booking;
  final SportlyRemoteDataSource remoteDataSource;

  @override
  State<PaymentSimulatorPage> createState() => _PaymentSimulatorPageState();
}

class _PaymentSimulatorPageState extends State<PaymentSimulatorPage> {
  bool _loading = false;
  String? _error;

  Future<void> _pay() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final paid = await widget.remoteDataSource.simulatePayment(
        widget.booking.code,
      );
      if (!mounted) return;
      context.go('/ticket/${paid.code}', extra: paid);
    } catch (e) {
      setState(() {
        _loading = false;
        _error = e.toString();
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
              color: AppColors.lime.withOpacity(0.25),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.lime),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'This is a simulated payment for testing. No real transaction will occur.',
                    style: TextStyle(fontSize: 12, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
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
            label: 'Pay ${formatCurrency(booking.total)}',
            loading: _loading,
            onPressed: _pay,
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
