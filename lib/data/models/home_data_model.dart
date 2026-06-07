import 'package:equatable/equatable.dart';

import 'category_model.dart';
import 'event_model.dart';

class HomeData extends Equatable {
  const HomeData({
    required this.popularEvents,
    required this.categories,
    required this.freshEvents,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      popularEvents: (json['popular_events'] as List<dynamic>)
          .map((item) => SportEvent.fromJson(item as Map<String, dynamic>))
          .toList(),
      categories: (json['categories'] as List<dynamic>)
          .map((item) => EventCategory.fromJson(item as Map<String, dynamic>))
          .toList(),
      freshEvents: (json['fresh_events'] as List<dynamic>)
          .map((item) => SportEvent.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  final List<SportEvent> popularEvents;
  final List<EventCategory> categories;
  final List<SportEvent> freshEvents;

  @override
  List<Object?> get props => [popularEvents, categories, freshEvents];
}
