import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/api_constants.dart';
import '../models/booking_model.dart';
import '../models/category_model.dart';
import '../models/event_model.dart';
import '../models/home_data_model.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class SportlyRemoteDataSource {
  SportlyRemoteDataSource({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<HomeData> getHome() async {
    final json = await _get(ApiConstants.home);
    return HomeData.fromJson(json['data'] as Map<String, dynamic>);
  }

  Future<List<EventCategory>> getCategories() async {
    final json = await _get(ApiConstants.categories);
    return (json['data'] as List<dynamic>)
        .map((item) => EventCategory.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<SportEvent>> getEvents({String? query, int? categoryId}) async {
    final parameters = <String, String>{
      'per_page': '50',
      if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
      if (categoryId != null) 'category_id': categoryId.toString(),
    };
    final json = await _get(ApiConstants.events, parameters);
    return (json['data'] as List<dynamic>)
        .map((item) => SportEvent.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<SportEvent> getEvent(String slug) async {
    final json = await _get('${ApiConstants.events}/$slug');
    return SportEvent.fromJson(json['data'] as Map<String, dynamic>);
  }

  Future<BookingCreationResult> createBooking({
    required String eventSlug,
    required String name,
    required String phone,
    required String email,
  }) async {
    final json = await _post(ApiConstants.bookings, {
      'event_slug': eventSlug,
      'name': name,
      'phone': phone,
      'email': email,
    });
    final payment = json['payment'] as Map<String, dynamic>;

    return BookingCreationResult(
      booking: Booking.fromJson(json['data'] as Map<String, dynamic>),
      paymentRequired: payment['required'] as bool? ?? false,
      paymentUrl: payment['redirect_url'] as String?,
    );
  }

  Future<Booking> simulatePayment(String code) async {
    final json = await _post(
      '${ApiConstants.bookings}/${Uri.encodeComponent(code.trim())}/simulate-pay',
      {},
    );
    return Booking.fromJson(json['data'] as Map<String, dynamic>);
  }

  Future<Booking> getBooking({
    required String code,
    required String email,
  }) async {
    final json = await _get(
      '${ApiConstants.bookings}/${Uri.encodeComponent(code.trim())}',
      {'email': email.trim()},
    );
    return Booking.fromJson(json['data'] as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> _get(
    String path, [
    Map<String, String>? queryParameters,
  ]) async {
    final uri = Uri.parse(
      '${ApiConstants.baseUrl}$path',
    ).replace(queryParameters: queryParameters);
    final response = await _client.get(
      uri,
      headers: const {'Accept': 'application/json'},
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _client.post(
      Uri.parse('${ApiConstants.baseUrl}$path'),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    return _decode(response);
  }

  Map<String, dynamic> _decode(http.Response response) {
    Map<String, dynamic> json;
    try {
      json = jsonDecode(response.body) as Map<String, dynamic>;
    } on FormatException {
      throw ApiException(
        'The server returned an invalid response.',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json;
    }

    final errors = json['errors'] as Map<String, dynamic>?;
    final firstError = errors?.values
        .whereType<List<dynamic>>()
        .expand((items) => items)
        .whereType<String>()
        .firstOrNull;

    throw ApiException(
      firstError ??
          json['message'] as String? ??
          'Request failed (${response.statusCode}).',
      statusCode: response.statusCode,
    );
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
