import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/sportly_remote_data_source.dart';
import 'presentation/blocs/events/events_bloc.dart';
import 'presentation/blocs/home/home_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('en_US');
  runApp(const SportlyApp());
}

class SportlyApp extends StatefulWidget {
  const SportlyApp({super.key});

  @override
  State<SportlyApp> createState() => _SportlyAppState();
}

class _SportlyAppState extends State<SportlyApp> {
  late final SportlyRemoteDataSource _remoteDataSource;
  late final HomeBloc _homeBloc;
  late final EventsBloc _eventsBloc;

  @override
  void initState() {
    super.initState();
    _remoteDataSource = SportlyRemoteDataSource();
    _homeBloc = HomeBloc(_remoteDataSource)..add(const HomeLoadRequested());
    _eventsBloc = EventsBloc(_remoteDataSource);
  }

  @override
  void dispose() {
    _homeBloc.close();
    _eventsBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _homeBloc),
        BlocProvider.value(value: _eventsBloc),
      ],
      child: MaterialApp.router(
        title: 'Sportly',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: AppRouter.create(_remoteDataSource),
      ),
    );
  }
}
