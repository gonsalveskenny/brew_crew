import 'package:brew_crew/models/userData.dart';
import 'package:brew_crew/services/auth.dart';
import 'package:brew_crew/services/database.dart';
import 'package:brew_crew/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:brew_crew/shared/constants.dart';
import 'package:provider/provider.dart';

class SettingsForm extends StatefulWidget {
  const SettingsForm({Key? key}) : super(key: key);

  @override
  State<SettingsForm> createState() => _SettingsFormState();
}

class _SettingsFormState extends State<SettingsForm> {
  final _formKey = GlobalKey<FormState>();
  final List<String> sugars = ['0', '1', '2', '3', '4'];

  String _currentName = 'kenny';
  String _currentSugars = '0';
  int _currentStrength = 100;
  int x = 0;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserData?>(context);

    return StreamBuilder<UserD>(
        stream: DatabaseService(uid: user!.uid).userData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            UserD? userD = snapshot.data;
            if (x == 0) {
              _currentName = userD!.name;
              _currentSugars = userD.sugars;
              _currentStrength = userD.strength;
              x = x + 1;
            }
            return Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  Text(
                    'Update your brew settings',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    initialValue: _currentName,
                    decoration: textInputDecoration,
                    validator: (val) =>
                        val!.isEmpty ? 'Please enter a name' : null,
                    onChanged: (val) => setState(() {
                      _currentName = val;
                    }),
                  ),
                  SizedBox(height: 20.0),

                  //dropdown
                  DropdownButtonFormField(
                    value: _currentSugars,
                    decoration: textInputDecoration,
                    items: sugars.map((sugar) {
                      return DropdownMenuItem(
                        value: sugar,
                        child: Text('$sugar sugars'),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        _currentSugars = val.toString();
                      });
                    },
                  ),

                  //slider
                  Slider(
                    value: _currentStrength.toDouble(),
                    activeColor: Colors.brown[_currentStrength],
                    inactiveColor: Colors.brown,
                    min: 100.0,
                    max: 900.0,
                    divisions: 8,
                    onChanged: (val) {
                      setState(() {
                        _currentStrength = val.round();
                      });
                    },
                  ),

                  SizedBox(
                    height: 20,
                  ),

                  RaisedButton(
                    color: Colors.pink[400],
                    child: Text(
                      'Update',
                      style: TextStyle(color: Colors.white),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await DatabaseService(uid: user.uid).updateUserData(
                            _currentSugars, _currentName, _currentStrength);
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
            );
          } else {
            return Loading();
          }
        });
  }
}
