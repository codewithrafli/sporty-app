import 'package:equatable/equatable.dart';

import 'event_model.dart';

class Booking extends Equatable {
  const Booking({
    required this.id,
    required this.code,
    required this.name,
    required this.phone,
    required this.email,
    required this.paymentStatus,
    required this.isCheckedIn,
    required this.subtotal,
    required this.tax,
    required this.insurance,
    required this.total,
    required this.event,
    this.checkedInAt,
    this.createdAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as int,
      code: json['code'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      paymentStatus: json['payment_status'] as String,
      isCheckedIn: json['is_checked_in'] as bool? ?? false,
      checkedInAt: json['checked_in_at'] == null
          ? null
          : DateTime.parse(json['checked_in_at'] as String),
      subtotal: (json['subtotal'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      insurance: (json['insurance'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      event: SportEvent.fromJson(json['event'] as Map<String, dynamic>),
    );
  }

  final int id;
  final String code;
  final String name;
  final String phone;
  final String email;
  final String paymentStatus;
  final bool isCheckedIn;
  final DateTime? checkedInAt;
  final double subtotal;
  final double tax;
  final double insurance;
  final double total;
  final DateTime? createdAt;
  final SportEvent event;

  bool get isPaid => paymentStatus == 'paid' || paymentStatus == 'success';

  @override
  List<Object?> get props => [
    id,
    code,
    name,
    phone,
    email,
    paymentStatus,
    isCheckedIn,
    checkedInAt,
    subtotal,
    tax,
    insurance,
    total,
    createdAt,
    event,
  ];
}

class BookingCreationResult extends Equatable {
  const BookingCreationResult({
    required this.booking,
    required this.paymentRequired,
    this.paymentUrl,
  });

  final Booking booking;
  final bool paymentRequired;
  final String? paymentUrl;

  @override
  List<Object?> get props => [booking, paymentRequired, paymentUrl];
}
