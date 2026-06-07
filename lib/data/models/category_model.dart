import 'package:equatable/equatable.dart';

class EventCategory extends Equatable {
  const EventCategory({
    required this.id,
    required this.name,
    required this.slug,
    required this.eventsCount,
    this.description,
    this.iconUrl,
  });

  factory EventCategory.fromJson(Map<String, dynamic> json) {
    return EventCategory(
      id: json['id'] as int,
      name: json['name'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String?,
      iconUrl: json['icon_url'] as String?,
      eventsCount: (json['events_count'] as num?)?.toInt() ?? 0,
    );
  }

  final int id;
  final String name;
  final String slug;
  final String? description;
  final String? iconUrl;
  final int eventsCount;

  @override
  List<Object?> get props => [
    id,
    name,
    slug,
    description,
    iconUrl,
    eventsCount,
  ];
}
