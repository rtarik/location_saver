import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SaveLocationForm extends StatefulWidget {
  final LatLng location;

  SaveLocationForm({Key key, @required this.location}) : super(key: key);

  @override
  _SaveLocationFormState createState() =>
      _SaveLocationFormState(location: location);
}

class _SaveLocationFormState extends State<SaveLocationForm> {
  final LatLng location;

  _SaveLocationFormState({@required this.location}) : super();

  final _formController = TextEditingController();
  String _errorText;

  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Save my location')),
      body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: _formController,
                decoration:
                    InputDecoration(hintText: 'Title', errorText: _errorText),
              ),
              Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child:
                      ElevatedButton(onPressed: _onSave, child: Text('Save')))
            ],
          )),
    );
  }

  void _onSave() {
    setState(() {
      if (_formController.text.replaceAll(new RegExp(r","), '').isEmpty) {
        _errorText = 'Title cannot be empty';
        return;
      } else {
        _errorText = null;
        _saveLocation();
      }
    });
  }

  void _saveLocation() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final titles =
        (prefs.getString("titles") ?? "").split(RegExp(r",")).toSet();
    final titleToAdd = _formController.text.replaceAll(new RegExp(r","), '');
    titles.add(titleToAdd);
    prefs.setString("titles", titles.join(","));
    prefs.setString(titleToAdd,
        location.latitude.toString() + "," + location.longitude.toString());
    Navigator.of(context).pop();
  }
}
