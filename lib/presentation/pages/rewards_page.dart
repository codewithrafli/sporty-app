import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class RewardsPage extends StatelessWidget {
  const RewardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ComingSoonPage(
      icon: Icons.card_giftcard_rounded,
      title: 'Rewards',
      message: 'Event rewards and challenges will appear here.',
    );
  }
}

class _ComingSoonPage extends StatelessWidget {
  const _ComingSoonPage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: const BoxDecoration(
                  color: AppColors.lime,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 40),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
