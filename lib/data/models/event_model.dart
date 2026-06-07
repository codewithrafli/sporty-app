import 'package:equatable/equatable.dart';

import 'category_model.dart';

class EventVenue extends Equatable {
  const EventVenue({
    required this.id,
    required this.name,
    required this.address,
    required this.postalCode,
  });

  factory EventVenue.fromJson(Map<String, dynamic> json) {
    return EventVenue(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String? ?? '',
      postalCode: json['postal_code'] as String? ?? '',
    );
  }

  final int id;
  final String name;
  final String address;
  final String postalCode;

  @override
  List<Object?> get props => [id, name, address, postalCode];
}

class EventPrize extends Equatable {
  const EventPrize({
    required this.id,
    required this.name,
    required this.givenBy,
    this.imageUrl,
  });

  factory EventPrize.fromJson(Map<String, dynamic> json) {
    return EventPrize(
      id: json['id'] as int,
      name: json['name'] as String,
      givenBy: json['given_by'] as String? ?? 'Event Organizer',
      imageUrl: json['image_url'] as String?,
    );
  }

  final int id;
  final String name;
  final String givenBy;
  final String? imageUrl;

  @override
  List<Object?> get props => [id, name, givenBy, imageUrl];
}

class SportEvent extends Equatable {
  const SportEvent({
    required this.id,
    required this.title,
    required this.slug,
    required this.description,
    required this.isFeatured,
    required this.date,
    required this.status,
    required this.maxParticipants,
    required this.participantsCount,
    required this.totalPrize,
    required this.price,
    required this.category,
    this.imageUrl,
    this.venue,
    this.winnerName,
    this.winnerNumber,
    this.prizes = const [],
  });

  factory SportEvent.fromJson(Map<String, dynamic> json) {
    final categoryJson = json['category'] as Map<String, dynamic>?;
    final venueJson = json['venue'] as Map<String, dynamic>?;
    final prizesJson = json['prizes'] as List<dynamic>? ?? const [];

    return SportEvent(
      id: json['id'] as int,
      title: json['title'] as String,
      slug: json['slug'] as String,
      description: json['description'] as String? ?? '',
      imageUrl: json['image_url'] as String?,
      isFeatured: json['is_featured'] as bool? ?? false,
      date: DateTime.parse(json['date'] as String),
      status: json['status'] as String,
      maxParticipants: (json['max_participants'] as num).toInt(),
      participantsCount: (json['participants_count'] as num?)?.toInt() ?? 0,
      totalPrize: (json['total_prize'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      winnerName: json['winner_name'] as String?,
      winnerNumber: json['winner_number'] as String?,
      category: categoryJson == null
          ? const EventCategory(
              id: 0,
              name: 'General',
              slug: 'general',
              eventsCount: 0,
            )
          : EventCategory.fromJson(categoryJson),
      venue: venueJson == null ? null : EventVenue.fromJson(venueJson),
      prizes: prizesJson
          .map((item) => EventPrize.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }

  final int id;
  final String title;
  final String slug;
  final String description;
  final String? imageUrl;
  final bool isFeatured;
  final DateTime date;
  final String status;
  final int maxParticipants;
  final int participantsCount;
  final double totalPrize;
  final double price;
  final String? winnerName;
  final String? winnerNumber;
  final EventCategory category;
  final EventVenue? venue;
  final List<EventPrize> prizes;

  bool get isOpen => status == 'open';

  @override
  List<Object?> get props => [
    id,
    title,
    slug,
    description,
    imageUrl,
    isFeatured,
    date,
    status,
    maxParticipants,
    participantsCount,
    totalPrize,
    price,
    winnerName,
    winnerNumber,
    category,
    venue,
    prizes,
  ];
}
