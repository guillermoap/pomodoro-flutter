import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/profile.model.dart';

class NewProfileScreen extends StatefulWidget {
  @override
  _NewProfileState createState() => _NewProfileState();
}

class _NewProfileState extends State<NewProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  Profile _profile = Profile();
  SharedPreferences _prefs;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  String _validator(value) {
    if (value.isEmpty) {
      return "Can't be left blank";
    }
    return null;
  }

  Future<void> _loadPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  void _saveProfile() {
    if (_formKey.currentState.validate()) {
      _formKey.currentState.save();

      setState(() {
        final _profilesList = _prefs.getStringList('profiles') ?? [];
        _profilesList.add(_profile.name);
        _prefs.setStringList('profiles', _profilesList);

        _prefs.setInt('${_profile.name}.totalLength', _profile.totalSessionLength);
        _prefs.setInt('${_profile.name}.pomodoroLength', _profile.pomodoroLength);
        _prefs.setInt('${_profile.name}.shortBreakLength', _profile.shortBreakLength);
        _prefs.setInt('${_profile.name}.longBreakLength', _profile.longBreakLength);
        _prefs.setInt('${_profile.name}.numberOfLongBreaks', _profile.numberOfLongBreaks);
      });

      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('New Profile'),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.done),
        onPressed: () { _saveProfile(); },
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: TextFormField(
                      keyboardType: TextInputType.text,
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Profile name',
                        hintText: 'E.g: Work',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                      validator: (value) => _validator(value),
                      onSaved: (value) {
                        this._profile.name = value;
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Total session length',
                        hintText: 'E.g: 3 hours',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                      validator: (value) => _validator(value),
                      onSaved: (value) {
                        this._profile.totalSessionLength = int.parse(value) * 60;
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Pomodoro length',
                        hintText: 'E.g: 25 minutes',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                      validator: (value) => _validator(value),
                      onSaved: (value) {
                        this._profile.pomodoroLength = int.parse(value);
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Short break length',
                        hintText: 'E.g: 5 minutes',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                      validator: (value) => _validator(value),
                      onSaved: (value) {
                        this._profile.shortBreakLength = int.parse(value);
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Long break length',
                        hintText: 'E.g: 15 minutes',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                      validator: (value) => _validator(value),
                      onSaved: (value) {
                        this._profile.longBreakLength = int.parse(value);
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Number of long breaks',
                        hintText: 'E.g: 1 break',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                      ),
                      validator: (value) => _validator(value),
                      onSaved: (value) {
                        this._profile.numberOfLongBreaks = int.parse(value);
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
