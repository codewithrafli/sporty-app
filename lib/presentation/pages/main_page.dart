import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../data/datasources/sportly_remote_data_source.dart';
import '../blocs/booking/booking_bloc.dart';
import 'help_page.dart';
import 'home_page.dart';
import 'my_event_page.dart';
import 'rewards_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({required this.remoteDataSource, super.key});

  final SportlyRemoteDataSource remoteDataSource;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomePage(),
      BlocProvider(
        create: (_) => BookingBloc(widget.remoteDataSource),
        child: const MyEventPage(),
      ),
      const SizedBox(),
      const RewardsPage(),
      const HelpPage(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/browse'),
        backgroundColor: AppColors.lime,
        foregroundColor: AppColors.dark,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.search_rounded, size: 30),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 14,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.view_in_ar_outlined,
              label: 'Browse',
              selected: _index == 0,
              onTap: () => setState(() => _index = 0),
            ),
            _NavItem(
              icon: Icons.event_note_outlined,
              label: 'My Event',
              selected: _index == 1,
              onTap: () => setState(() => _index = 1),
            ),
            const SizedBox(width: 48),
            _NavItem(
              icon: Icons.card_giftcard_outlined,
              label: 'Rewards',
              selected: _index == 3,
              onTap: () => setState(() => _index = 3),
            ),
            _NavItem(
              icon: Icons.help_outline_rounded,
              label: 'Helps',
              selected: _index == 4,
              onTap: () => setState(() => _index = 4),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: selected ? AppColors.purple : AppColors.muted,
                size: 23,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  color: selected ? AppColors.dark : AppColors.muted,
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
