import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../timer/timer.screen.dart';

class ProfilesScreen extends StatefulWidget {
  @override
  _ProfilesScreenState createState() => _ProfilesScreenState();
}

class _ProfilesScreenState extends State<ProfilesScreen> {
  List<String> profiles = <String>[];
  SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  _loadProfiles() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      profiles = prefs.getStringList('profiles') ?? [];
    });
  }

  void _clearPrefs() {
    setState(() {
      profiles.clear();
      prefs.clear();
    });
  }

  _createProfile() async {
    final result = await Navigator.pushNamed(context, '/newProfile');
    if (result) {
      _loadProfiles();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profiles'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _clearPrefs(),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: profiles.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(profiles[index]),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TimerScreen(profiles[index]))
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Profile',
        onPressed: () { _createProfile(); },
        child: Icon(Icons.add),
      ),
    );
  }
}
