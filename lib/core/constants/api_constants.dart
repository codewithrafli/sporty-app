class ApiConstants {
  ApiConstants._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://sporty.my.id/api/v1',
  );

  static const String home = '/home';
  static const String categories = '/categories';
  static const String events = '/events';
  static const String bookings = '/bookings';
}
