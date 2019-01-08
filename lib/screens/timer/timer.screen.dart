import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:screen/screen.dart';

import '../../models/profile.model.dart';

import 'dart:async';

class TimerScreen extends StatefulWidget {
  final profileName;

  TimerScreen(this.profileName);

  @override
  _TimerState createState() => _TimerState(profileName);
}

class _TimerState extends State<TimerScreen> {
  Duration _oneSec = Duration(seconds: 1);
  String _profileName;
  Profile _profile = Profile();
  Timer _timer;
  Color _buttonColor;

  NumberFormat _timeFormat = NumberFormat("00");
  int _seconds = 0;
  int _minutes = 0;
  int _hours = 0;
  List _session = [];
  int time;
  int currentSessionIndex = 0;

  _TimerState(this._profileName);

  @override
  void initState() {
    super.initState();
    _loadProfile();
    Screen.keepOn(true);
  }

  _loadProfile() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _profile.name = _profileName;
      _profile.totalSessionLength = prefs.getInt('$_profileName.totalLength');
      _profile.pomodoroLength = prefs.getInt('$_profileName.pomodoroLength');
      _profile.shortBreakLength = prefs.getInt('$_profileName.shortBreakLength');
      _profile.longBreakLength = prefs.getInt('$_profileName.longBreakLength');
      _profile.numberOfLongBreaks = prefs.getInt('$_profileName.numberOfLongBreaks');    
    });

    _calculateSession();
  }

  void _calculateSession() {
    int leftoverTime = _profile.totalSessionLength;
    int marker = leftoverTime ~/ _profile.numberOfLongBreaks;
    int offset = _profile.pomodoroLength ~/ 2;
    int numberOfLongBreaks = 0;

    while (leftoverTime > _profile.pomodoroLength) {
      _session.add(_profile.pomodoroLength);
      leftoverTime -= _profile.pomodoroLength;
      if (numberOfLongBreaks < _profile.numberOfLongBreaks &&
        (leftoverTime < marker + offset && leftoverTime > marker - offset)) {
        _session.add(_profile.longBreakLength);
        leftoverTime -= _profile.longBreakLength;
      } else if (leftoverTime > _profile.shortBreakLength) {
        _session.add(_profile.shortBreakLength);
        leftoverTime -= _profile.shortBreakLength;
      }
    }
    if (leftoverTime > 0) {
      _session.add(leftoverTime);
    }

    _startNextSession();
  }

  void _toggleTimer() {
    if (_timer == null || !_timer.isActive) {
      setState(() {
        _buttonColor = Colors.red;
      });
      _timer = Timer.periodic(_oneSec, (timer) => _updateTimer());
    } else {
      _timer.cancel();
      setState(() {
        _buttonColor = Theme.of(context).primaryColor;
      });
    }
  }

  void _updateTimer() {
    setState(() {
      if (_hours + _minutes + _seconds != 0) {
        if (_seconds <= 0 && _minutes > 0) {
          _seconds = 59;
          --_minutes;
        } else if (_seconds <= 0 && _minutes <= 0) {
          _minutes = 59;
          --_hours;
        } else {
          --_seconds;
        }
      } else {
        if (currentSessionIndex < _session.length) {
          _startNextSession();
        } else {
          _toggleTimer();
          _clear();
        }
      }
    });
  }

  void _clear() {
    setState(() {
      _seconds = 0;
      _minutes = 0;
      _hours = 0;
    });
  }

  void _startNextSession() {
    setState(() {
      time = _session[currentSessionIndex];
      while (time > 60) {
        _hours++;
        time -= 60;
      }
      _minutes = time;
    });
    currentSessionIndex++;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_profileName),
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Toggle Timer',
        onPressed: () { _toggleTimer(); },
        child: Icon(Icons.timer),
        backgroundColor: _buttonColor ?? Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              '${_timeFormat.format(_hours)}:${_timeFormat.format(_minutes)}:${_timeFormat.format(_seconds)}',
              style: TextStyle(
                fontSize: 30.0,
                color: Colors.black,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 30.0),
              child: TextField(
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.red,
                ),
                decoration: InputDecoration(
                  labelText: 'Task',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
