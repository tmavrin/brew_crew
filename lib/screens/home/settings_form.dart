import 'package:brew_crew/models/user.dart';
import 'package:brew_crew/services/database.dart';
import 'package:brew_crew/shared/constants.dart';
import 'package:brew_crew/shared/loading.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsFrom extends StatefulWidget {
  @override
  _SettingsFromState createState() => _SettingsFromState();
}

class _SettingsFromState extends State<SettingsFrom> {
  final _formKey = GlobalKey<FormState>();
  final List<String> sugars = ['0', '1', '2', '3', '4'];

  String _currentName = '';
  String _currentSugars = '';
  int _currentStrength = 0;

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AppUser?>(context);

    return StreamBuilder<UserData>(
        stream: DatabaseSevice(uid: user!.uid).userData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            UserData? userData = snapshot.data;

            return Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    'Update your brew settings.',
                    style: TextStyle(fontSize: 18.0),
                  ),
                  SizedBox(height: 20.0),
                  TextFormField(
                    initialValue: userData!.name,
                    decoration: textInputDecoration.copyWith(hintText: 'Name'),
                    validator: (val) =>
                        val!.isEmpty ? 'Please enter a name' : null,
                    onChanged: (val) {
                      setState(() {
                        _currentName = val;
                      });
                    },
                  ),
                  SizedBox(height: 20.0),
                  DropdownButtonFormField(
                    decoration: textInputDecoration,
                    value: _currentSugars.isEmpty
                        ? userData.sugars
                        : _currentSugars,
                    items: sugars.map((sugar) {
                      return DropdownMenuItem(
                        value: sugar,
                        child: Text('$sugar sugars'),
                      );
                    }).toList(),
                    onChanged: (val) =>
                        setState(() => _currentSugars = val.toString()),
                  ),
                  Slider(
                    min: 100,
                    max: 900,
                    divisions: 8,
                    value: (_currentStrength == 0
                            ? userData.strength
                            : _currentStrength)
                        .toDouble(),
                    onChanged: (val) =>
                        setState(() => _currentStrength = val.round()),
                    activeColor: Colors.brown[_currentStrength == 0
                        ? userData.strength
                        : _currentStrength],
                    inactiveColor: Colors.brown[_currentStrength == 0
                        ? userData.strength
                        : _currentStrength],
                  ),
                  ElevatedButton(
                    child: Text('Update'),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await DatabaseSevice(uid: userData.uid).updateUserData(
                            _currentSugars.isEmpty
                                ? userData.sugars
                                : _currentSugars,
                            _currentName.isEmpty ? userData.name : _currentName,
                            _currentStrength == 0
                                ? userData.strength
                                : _currentStrength);
                        Navigator.pop(context);
                      }
                    },
                  )
                ],
              ),
            );
          } else {
            return Loading();
          }
        });
  }
}
