import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../blocs/home/home_bloc.dart';
import '../widgets/error_view.dart';
import '../widgets/event_cards.dart';
import '../widgets/remote_image.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoading || state is HomeInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is HomeFailure) {
            return ErrorView(
              message: state.message,
              onRetry: () =>
                  context.read<HomeBloc>().add(const HomeLoadRequested()),
            );
          }

          final data = (state as HomeLoaded).data;
          return RefreshIndicator(
            onRefresh: () async {
              context.read<HomeBloc>().add(const HomeLoadRequested());
              await context.read<HomeBloc>().stream.firstWhere(
                (next) => next is HomeLoaded || next is HomeFailure,
              );
            },
            child: CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: _HomeHeader()),
                SliverToBoxAdapter(
                  child: _Section(
                    color: AppColors.background,
                    title: 'Most Popular',
                    subtitle: 'Backed by the community',
                    onViewAll: () => context.push('/browse'),
                    child: SizedBox(
                      height: 290,
                      child: ListView.builder(
                        padding: const EdgeInsets.only(left: 16, right: 4),
                        scrollDirection: Axis.horizontal,
                        itemCount: data.popularEvents.length,
                        itemBuilder: (context, index) =>
                            PopularEventCard(event: data.popularEvents[index]),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _Section(
                    color: Colors.white,
                    title: 'Best Categories',
                    child: SizedBox(
                      height: 158,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.only(left: 16, right: 4),
                        itemCount: data.categories.length,
                        itemBuilder: (context, index) {
                          final category = data.categories[index];
                          return GestureDetector(
                            onTap: () =>
                                context.push('/browse?category=${category.id}'),
                            child: Container(
                              width: 132,
                              margin: const EdgeInsets.only(right: 14),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    padding: const EdgeInsets.all(10),
                                    decoration: const BoxDecoration(
                                      color: AppColors.background,
                                      shape: BoxShape.circle,
                                    ),
                                    child: ClipOval(
                                      child: RemoteImage(
                                        url: category.iconUrl,
                                        fallbackAsset:
                                            'assets/images/medal.png',
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    category.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(
                                    '${category.eventsCount} Events',
                                    style: const TextStyle(
                                      color: AppColors.muted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _Section(
                    color: AppColors.background,
                    title: 'Fresh For You',
                    subtitle: 'Make every challenge count',
                    onViewAll: () => context.push('/browse'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: data.freshEvents
                            .map((event) => FreshEventCard(event: event))
                            .toList(),
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: _SkillsSection()),
                const SliverToBoxAdapter(child: SizedBox(height: 110)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: Image.asset('assets/images/medal.png'),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Howdy,',
                  style: TextStyle(color: AppColors.muted, fontSize: 12),
                ),
                Text(
                  'New Winner',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          _HeaderButton(icon: Icons.book_outlined, onTap: () {}),
          const SizedBox(width: 10),
          _HeaderButton(icon: Icons.notifications_none_rounded, onTap: () {}),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        child: Icon(icon, size: 21),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.color,
    required this.title,
    required this.child,
    this.subtitle,
    this.onViewAll,
  });

  final Color color;
  final String title;
  final String? subtitle;
  final Widget child;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: color,
      child: Padding(
        padding: const EdgeInsets.only(top: 22, bottom: 20),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (onViewAll != null)
                    OutlinedButton(
                      onPressed: onViewAll,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.dark,
                        side: const BorderSide(color: AppColors.border),
                      ),
                      child: const Text('View All'),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _SkillsSection extends StatelessWidget {
  const _SkillsSection();

  @override
  Widget build(BuildContext context) {
    const skills = [
      ('New Player Strategy', 'assets/images/football.png'),
      ('Save Energy Cycling', 'assets/images/cycling.png'),
      ('Learn How to Smash', 'assets/images/tenis.png'),
    ];

    return _Section(
      color: Colors.white,
      title: 'Improve Skills',
      child: SizedBox(
        height: 180,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: 16),
          itemCount: skills.length,
          itemBuilder: (context, index) {
            final skill = skills[index];
            return Container(
              width: 188,
              margin: const EdgeInsets.only(right: 14),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(13),
                    child: Image.asset(
                      skill.$2,
                      height: 105,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    skill.$1,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Text(
                    'by Sportly Coach',
                    style: TextStyle(color: AppColors.muted, fontSize: 10),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
