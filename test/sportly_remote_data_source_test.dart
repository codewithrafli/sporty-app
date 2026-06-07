import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sportly_app/data/datasources/sportly_remote_data_source.dart';

void main() {
  group('SportlyRemoteDataSource', () {
    test('parses home discovery data', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'data': {
              'popular_events': [_eventJson],
              'categories': [_categoryJson],
              'fresh_events': [_eventJson],
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final dataSource = SportlyRemoteDataSource(client: client);
      final home = await dataSource.getHome();

      expect(home.popularEvents.single.slug, 'city-run');
      expect(home.categories.single.name, 'Running');
      expect(home.freshEvents.single.price, 150000);
    });

    test('uses Laravel validation messages for failures', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'message': 'The given data was invalid.',
            'errors': {
              'event_slug': ['Registration for this event is closed.'],
            },
          }),
          422,
          headers: {'content-type': 'application/json'},
        );
      });

      final dataSource = SportlyRemoteDataSource(client: client);

      expect(
        () => dataSource.createBooking(
          eventSlug: 'city-run',
          name: 'Mobile User',
          phone: '08123456789',
          email: 'mobile@example.com',
        ),
        throwsA(
          isA<ApiException>().having(
            (error) => error.message,
            'message',
            'Registration for this event is closed.',
          ),
        ),
      );
    });
  });
}

const _categoryJson = {
  'id': 1,
  'name': 'Running',
  'slug': 'running',
  'description': 'Road races',
  'icon_url': null,
  'events_count': 1,
};

const _eventJson = {
  'id': 1,
  'title': 'City Run',
  'slug': 'city-run',
  'description': 'A city running event',
  'image_url': null,
  'is_featured': true,
  'date': '2026-08-17T07:00:00+07:00',
  'status': 'open',
  'max_participants': 100,
  'participants_count': 10,
  'total_prize': 1000000,
  'price': 150000,
  'winner_name': null,
  'winner_number': null,
  'category': _categoryJson,
  'venue': {
    'id': 1,
    'name': 'Gelora Test',
    'address': 'Jakarta',
    'postal_code': '10000',
  },
};
