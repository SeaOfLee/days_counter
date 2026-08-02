import 'package:flutter/material.dart';

import 'repositories/local_event_repository.dart';
import 'screens/event_list_screen.dart';

class App extends StatelessWidget {
  App({super.key});

  final _repository = LocalEventRepository();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Days',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple)),
      home: EventListScreen(repository: _repository),
    );
  }
}
