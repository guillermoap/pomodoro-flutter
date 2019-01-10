import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:screen/screen.dart';
import 'package:audioplayers/audio_cache.dart';

import '../models/profile.model.dart';

import 'dart:async';

class TimerScreen extends StatefulWidget {
  final profileName;

  TimerScreen(this.profileName);

  @override
  _TimerState createState() => _TimerState(profileName);
}

class _TimerState extends State<TimerScreen> {
  _TimerState(this._profileName);
  final String _profileName;

  final Duration _oneSec = Duration(seconds: 1);
  final NumberFormat _timeFormat = NumberFormat("00");
  final AudioCache soundPlayer = AudioCache(prefix: 'sounds/');
  
  Profile _profile = Profile();
  Timer _timer;
  int _seconds = 0;
  int _minutes = 0;
  int _hours = 0;
  List _session = [];
  int currentSessionIndex = 0;
  String sessionDescriptionText = '';
  String sessionFinishedText;
  
  bool showTaskBox = true;
  Color _buttonColor;

  @override
  void initState() {
    super.initState();
    _loadProfile();
    Screen.keepOn(true);
    soundPlayer.load('beep.mp3');
  }

  Future<void> _loadProfile() async {
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
    int marker = leftoverTime ~/ (_profile.numberOfLongBreaks + 1);
    int offset = _profile.longBreakLength ~/ 2;
    int numberOfLongBreaks = 0;

    while (leftoverTime > _profile.pomodoroLength) {
      _session.add(_profile.pomodoroLength);
      leftoverTime -= _profile.pomodoroLength;
      if (numberOfLongBreaks < _profile.numberOfLongBreaks &&
        leftoverTime < marker + offset) {
        _session.add(_profile.longBreakLength);
        numberOfLongBreaks++;
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

  void _startNextSession() {
    setState(() {
      if (_session[currentSessionIndex] == _profile.pomodoroLength) {
        sessionDescriptionText = 'Pomodoro';
        showTaskBox = true;
      } else if (_session[currentSessionIndex] == _profile.shortBreakLength) {
        sessionDescriptionText = 'Short Break';
        showTaskBox = false;
      } else if (_session[currentSessionIndex] == _profile.longBreakLength) {
        sessionDescriptionText = 'Long Break';
        showTaskBox = false;
      }
      int time = _session[currentSessionIndex];
      while (time > 60) {
        _hours++;
        time -= 60;
      }
      _minutes = time;
    });
    currentSessionIndex++;
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
          soundPlayer.play('beep.mp3');
          _startNextSession();
        } else {
          sessionFinishedText = 'Session finished!';
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
              sessionFinishedText ?? _session.toString(),
              style: TextStyle(
                fontSize: 10.0,
                color: Colors.black,
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10.0),
              padding: EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                border: Border.all(width: 2.0, color: Theme.of(context).primaryColor),
                borderRadius: BorderRadius.circular(32.0),
              ),
              child: Column(
                children: <Widget>[
                  Text(
                    '${_timeFormat.format(_hours)}:${_timeFormat.format(_minutes)}:${_timeFormat.format(_seconds)}',
                    style: TextStyle(
                      fontSize: 30.0,
                      color: Colors.black,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 5.0),
                    child: Text(
                      sessionDescriptionText,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15.0,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Opacity(
              opacity: showTaskBox ? 1.0 : 0.0,
              child: Padding(
                padding: EdgeInsets.only(top: 10.0),
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
            ),
          ],
        ),
      ),
    );
  }
}
