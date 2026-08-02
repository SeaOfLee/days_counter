import 'package:flutter/material.dart';

import 'repositories/event_repository.dart';
import 'repositories/local_event_repository.dart';
import 'screens/event_list_screen.dart';

class App extends StatelessWidget {
  App({super.key, EventRepository? repository})
    : _repository = repository ?? LocalEventRepository();

  final EventRepository _repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Days',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      home: EventListScreen(repository: _repository),
    );
  }
}
