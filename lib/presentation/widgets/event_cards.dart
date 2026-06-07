import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/event_model.dart';
import 'remote_image.dart';

class PopularEventCard extends StatelessWidget {
  const PopularEventCard({required this.event, super.key});

  final SportEvent event;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/events/${event.slug}'),
      child: Container(
        width: 208,
        margin: const EdgeInsets.only(right: 16),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.14),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            RemoteImage(url: event.imageUrl),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xE6000000)],
                  stops: [0.3, 1],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _WhiteMeta(
                    icon: Icons.monetization_on_outlined,
                    text: formatCurrency(event.totalPrize),
                  ),
                  const SizedBox(height: 4),
                  _WhiteMeta(
                    icon: Icons.emoji_events_outlined,
                    text: event.category.name,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: AppColors.lime,
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: const Text(
                      'See Event',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.dark,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FreshEventCard extends StatelessWidget {
  const FreshEventCard({required this.event, super.key});

  final SportEvent event;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/events/${event.slug}'),
      child: Container(
        height: 164,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.border),
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
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.2,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _DarkMeta(
                    icon: Icons.monetization_on_outlined,
                    text: formatCurrency(event.price),
                  ),
                  const SizedBox(height: 6),
                  _DarkMeta(
                    icon: Icons.emoji_events_outlined,
                    text: event.category.name,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BrowseEventCard extends StatelessWidget {
  const BrowseEventCard({required this.event, super.key});

  final SportEvent event;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/events/${event.slug}'),
      child: AspectRatio(
        aspectRatio: 0.68,
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              RemoteImage(url: event.imageUrl),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xD9000000)],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _WhiteMeta(
                      icon: Icons.monetization_on_outlined,
                      text: formatCurrency(event.price),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WhiteMeta extends StatelessWidget {
  const _WhiteMeta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: Colors.white),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _DarkMeta extends StatelessWidget {
  const _DarkMeta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17, color: AppColors.muted),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }
}
