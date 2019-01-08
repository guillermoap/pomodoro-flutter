import 'package:flutter/material.dart';

import './screens/profiles/index.screen.dart';
import './screens/profiles/new.screen.dart';

void main() => runApp(
  MaterialApp(
    title: 'Pomodoro App',
    home: ProfilesScreen(),
    routes: {
      '/newProfile': (context) => NewProfileScreen(),
    },
  )
);
