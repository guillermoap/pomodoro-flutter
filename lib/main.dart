import 'package:flutter/material.dart';

import './screens/profiles.screen.dart';
import './screens/profile.screen.dart';

void main() => runApp(
  MaterialApp(
    title: 'Pomodoro App',
    home: ProfilesScreen(),
    routes: {
      '/newProfile': (context) => NewProfileScreen(),
    },
  )
);
