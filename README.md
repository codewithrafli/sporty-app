# Sportly Mobile

Flutter client for the Kratos event platform. The app follows the Absenin
project structure with `core`, `data`, and `presentation` layers, BLoC state
management, and `go_router` navigation.

## API

Start the Laravel app from `../Event-Olahraga_Laravel`:

```bash
php artisan serve --host=0.0.0.0
```

Android emulator builds use `http://10.0.2.2:8000/api/v1` by default. For iOS,
web, or a physical device, provide the machine's reachable address:

```bash
flutter run \
  --dart-define=API_BASE_URL=http://192.168.1.10:8000/api/v1
```

Use HTTPS for deployed builds. Paid bookings return a Midtrans redirect URL
when `MIDTRANS_SERVER_KEY` is configured in the Laravel environment.

## Checks

```bash
flutter analyze
flutter test
```
