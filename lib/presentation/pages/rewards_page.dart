import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/event_model.dart';
import '../blocs/rewards/rewards_bloc.dart';
import '../widgets/error_view.dart';
import '../widgets/remote_image.dart';

class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key});

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => context.read<RewardsBloc>().add(const RewardsLoadRequested()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: BlocBuilder<RewardsBloc, RewardsState>(
        builder: (context, state) {
          if (state is RewardsLoading || state is RewardsInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is RewardsFailure) {
            return ErrorView(
              message: state.message,
              onRetry: () =>
                  context.read<RewardsBloc>().add(const RewardsLoadRequested()),
            );
          }

          final data = state as RewardsLoaded;
          return RefreshIndicator(
            onRefresh: () async {
              context.read<RewardsBloc>().add(const RewardsLoadRequested());
              await context.read<RewardsBloc>().stream.firstWhere(
                    (s) => s is RewardsLoaded || s is RewardsFailure,
                  );
            },
            child: CustomScrollView(
              slivers: [
                if (data.winners.isNotEmpty) ...[
                  const SliverToBoxAdapter(
                    child: _SectionHeader(title: 'Winners'),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList.builder(
                      itemCount: data.winners.length,
                      itemBuilder: (context, i) =>
                          _PrizeCard(event: data.winners[i]),
                    ),
                  ),
                ],
                const SliverToBoxAdapter(
                  child: _SectionHeader(title: 'Prize Leaderboard'),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
                  sliver: SliverList.builder(
                    itemCount: data.sortedByPrize.length,
                    itemBuilder: (context, i) => _PrizeCard(
                      event: data.sortedByPrize[i],
                      rank: i + 1,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _PrizeCard extends StatelessWidget {
  const _PrizeCard({required this.event, this.rank});

  final SportEvent event;
  final int? rank;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      margin: const EdgeInsets.only(bottom: 14),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
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
                colors: [Colors.transparent, Color(0xE6000000)],
                stops: [0.3, 1.0],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (rank != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: rank! <= 3 ? AppColors.lime : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '#$rank',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: rank! <= 3 ? AppColors.dark : AppColors.muted,
                      ),
                    ),
                  ),
                const Spacer(),
                Text(
                  event.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.monetization_on_outlined,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      formatCurrency(event.totalPrize),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (event.winnerName != null) ...[
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.emoji_events_rounded,
                        size: 14,
                        color: AppColors.lime,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          event.winnerName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: AppColors.lime,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
