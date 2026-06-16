import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/event_model.dart';
import '../blocs/event_detail/event_detail_bloc.dart';
import '../widgets/error_view.dart';
import '../widgets/remote_image.dart';

class EventDetailPage extends StatelessWidget {
  const EventDetailPage({required this.slug, super.key});

  final String slug;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EventDetailBloc, EventDetailState>(
      builder: (context, state) {
        if (state is EventDetailLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is EventDetailFailure) {
          return Scaffold(
            appBar: AppBar(),
            body: ErrorView(
              message: state.message,
              onRetry: () => context.read<EventDetailBloc>().add(
                EventDetailLoadRequested(slug),
              ),
            ),
          );
        }

        final event = (state as EventDetailLoaded).event;
        return Scaffold(
          backgroundColor: Colors.white,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 360,
                pinned: true,
                backgroundColor: AppColors.dark,
                foregroundColor: Colors.white,
                title: const Text(
                  'Event Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.bookmark_border_rounded),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      RemoteImage(url: event.imageUrl),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0x33000000),
                              Color(0x99000000),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _EventContent(event: event)),
            ],
          ),
          bottomNavigationBar: SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatCurrency(event.price),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const Text(
                          'Fee One Person',
                          style: TextStyle(
                            color: AppColors.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton(
                    onPressed: event.isOpen
                        ? () => context.push(
                            '/booking/${event.slug}',
                            extra: event,
                          )
                        : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: event.isOpen
                          ? AppColors.lime
                          : AppColors.border,
                      foregroundColor: AppColors.dark,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 15,
                      ),
                    ),
                    child: Text(event.isOpen ? 'Join Event' : 'Event Closed'),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EventContent extends StatelessWidget {
  const _EventContent({required this.event});

  final SportEvent event;

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (event.status) {
      'open' => AppColors.purple,
      'closed' => AppColors.error,
      _ => AppColors.dark,
    };
    final statusText = switch (event.status) {
      'open' => 'STILL OPEN',
      'closed' => 'CLOSED',
      _ => 'EVENT ENDED',
    };

    return Transform.translate(
      offset: const Offset(0, -12),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 26, 20, 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(34)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withValues(alpha: 0.28),
                    blurRadius: 14,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Text(
                statusText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              event.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                height: 1.25,
                fontWeight: FontWeight.w900,
              ),
            ),
            if (event.status == 'ended' && event.winnerName != null) ...[
              const SizedBox(height: 22),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.lime,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_events_rounded),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '1st Event Winner\n${event.winnerName} • No ${event.winnerNumber ?? '-'}',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 1.16,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              children: [
                _InfoCard(
                  icon: Icons.monetization_on_outlined,
                  value: formatCurrency(event.totalPrize),
                  label: 'Total Prize',
                ),
                _InfoCard(
                  icon: Icons.calendar_month_outlined,
                  value: formatEventDate(event.date),
                  label: 'Event Started',
                ),
                _InfoCard(
                  icon: Icons.groups_outlined,
                  value: '${event.maxParticipants} People',
                  label: 'Total Participants',
                ),
                _InfoCard(
                  icon: Icons.emoji_events_outlined,
                  value: event.category.name,
                  label: 'Event Type',
                ),
              ],
            ),
            const SizedBox(height: 28),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Event With Us',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                event.description,
                style: const TextStyle(color: Color(0xFF5F6470), height: 1.55),
              ),
            ),
            if (event.prizes.isNotEmpty) ...[
              const SizedBox(height: 28),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Additional Prizes',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 170,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: event.prizes.length,
                  itemBuilder: (context, index) {
                    final prize = event.prizes[index];
                    return Container(
                      width: 148,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.border),
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
                              height: 94,
                              width: double.infinity,
                              child: RemoteImage(
                                url: prize.imageUrl,
                                fallbackAsset: 'assets/images/medal.png',
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            prize.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            prize.givenBy,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Important Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 10),
                  _DetailRow(
                    label: 'Participants',
                    value:
                        '${event.participantsCount} of ${event.maxParticipants} People',
                  ),
                  _DetailRow(
                    label: 'Venue',
                    value: event.venue?.name ?? 'To be announced',
                  ),
                  _DetailRow(
                    label: 'Post Code',
                    value: event.venue?.postalCode ?? 'N/A',
                  ),
                  _DetailRow(
                    label: 'Status',
                    value: event.isOpen
                        ? 'Open Registration'
                        : 'Registration Closed',
                    last: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.muted, size: 27),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w900),
          ),
          Text(
            label,
            style: const TextStyle(color: AppColors.muted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.last = false,
  });

  final String label;
  final String value;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        border: last
            ? null
            : const Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          const Icon(Icons.notes_rounded, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: const TextStyle(color: AppColors.muted)),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}
