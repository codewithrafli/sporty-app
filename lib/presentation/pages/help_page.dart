import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 20),
          const Text(
            'Help Center',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          const Text(
            'Quick answers for registration, payment, and check-in.',
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 28),
          ...const [
            (
              Icons.confirmation_number_outlined,
              'Where is my ticket?',
              'Open My Event and enter your booking code and email.',
            ),
            (
              Icons.payments_outlined,
              'Payment is pending',
              'Complete payment in the Midtrans page, then refresh your ticket.',
            ),
            (
              Icons.qr_code_rounded,
              'Event check-in',
              'Show the QR code on your paid ticket to the event staff.',
            ),
          ].map(
            (item) => Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(item.$1, color: AppColors.purple),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.$2,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.$3,
                          style: const TextStyle(color: AppColors.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
