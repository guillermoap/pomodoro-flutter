import 'package:flutter/material.dart';
import 'package:inherited_widget_sample/app.dart';
import 'package:inherited_widget_sample/state_container.dart';

void main() {
  runApp(StateContainer(
    child: InheritedWidgetApp(),
  ));
}