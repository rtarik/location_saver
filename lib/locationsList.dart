import 'package:flutter/material.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationsList extends StatefulWidget {
  @override
  _LocationsListState createState() => _LocationsListState();
}

class _LocationsListState extends State<LocationsList> {
  List<String> locations = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Saved locations")),
        body: _buildLocations(context));
  }

  Widget _buildLocations(BuildContext context) {
    _getLocations();
    final tiles = locations.map((e) => ListTile(title: _getLocationRow(e)));
    final divided =
        ListTile.divideTiles(context: context, tiles: tiles).toList();
    return ListView(children: divided);
  }

  void _getLocations() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      locations = (prefs.getString("titles") ?? "")
          .split(RegExp(r","))
          .where((element) => element.isNotEmpty)
          .toList();
    });
  }

  Widget _getLocationRow(String location) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(location),
      PopupMenuButton<int>(
        itemBuilder: (context) => [
          PopupMenuItem(value: 1, child: Text("Open in Maps")),
          PopupMenuItem(value: 2, child: Text("Remove"))
        ],
        onSelected: (value) {
          if (value == 1) {
            _openInMaps(location);
          } else if (value == 2) {
            _removeLocation(location);
          }
        },
      )
    ]);
  }

  void _openInMaps(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> coordinates = prefs.getString(key).split(RegExp(r","));
    MapsLauncher.launchCoordinates(
        double.parse(coordinates[0]), double.parse(coordinates[1]));
  }

  void _removeLocation(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      locations.remove(key);
      prefs.setString("titles", locations.join(","));
    });
  }
}
