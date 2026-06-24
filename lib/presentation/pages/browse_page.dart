import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_colors.dart';
import '../blocs/events/events_bloc.dart';
import '../widgets/error_view.dart';
import '../widgets/event_cards.dart';

class BrowsePage extends StatefulWidget {
  const BrowsePage({super.key, this.initialCategoryId});

  final int? initialCategoryId;

  @override
  State<BrowsePage> createState() => _BrowsePageState();
}

class _BrowsePageState extends State<BrowsePage> {
  final _searchController = TextEditingController();
  int? _categoryId;

  @override
  void initState() {
    super.initState();
    _categoryId = widget.initialCategoryId;
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _load() {
    context.read<EventsBloc>().add(
      EventsLoadRequested(
        query: _searchController.text,
        categoryId: _categoryId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Browse by Category'),
        actions: [
          IconButton(
            onPressed: () {
              _searchController.clear();
              setState(() => _categoryId = null);
              _load();
            },
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: BlocBuilder<EventsBloc, EventsState>(
        builder: (context, state) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                child: TextField(
                  controller: _searchController,
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _load(),
                  decoration: InputDecoration(
                    hintText: 'Search by name',
                    prefixIcon: const Icon(Icons.search_rounded),
                  ),
                ),
              ),
              if (state is EventsLoaded)
                SizedBox(
                  height: 48,
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    children: [
                      _CategoryChip(
                        label: 'All',
                        selected: _categoryId == null,
                        onTap: () {
                          setState(() => _categoryId = null);
                          _load();
                        },
                      ),
                      ...state.categories.map(
                        (category) => _CategoryChip(
                          label: category.name,
                          selected: _categoryId == category.id,
                          onTap: () {
                            setState(() => _categoryId = category.id);
                            _load();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(child: _buildContent(state)),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(EventsState state) {
    if (state is EventsLoading || state is EventsInitial) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is EventsFailure) {
      return ErrorView(message: state.message, onRetry: _load);
    }

    final loaded = state as EventsLoaded;
    if (loaded.events.isEmpty) {
      return const Center(
        child: Text(
          'No events match your filters.',
          style: TextStyle(color: AppColors.muted),
        ),
      );
    }

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Browse Events',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                ),
                Text(
                  '${loaded.events.length} Events',
                  style: const TextStyle(color: AppColors.muted),
                ),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
          sliver: SliverGrid.builder(
            itemCount: loaded.events.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.68,
            ),
            itemBuilder: (context, index) =>
                BrowseEventCard(event: loaded.events[index]),
          ),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.purple,
        labelStyle: TextStyle(
          color: selected ? Colors.white : AppColors.dark,
          fontWeight: FontWeight.w700,
        ),
        side: const BorderSide(color: AppColors.border),
      ),
    );
  }
}
