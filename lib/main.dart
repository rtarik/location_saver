import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_saver/locationsList.dart';

import 'saveLocation.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: MapScreen());
  }
}

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController mapController;

  LatLng _center = LatLng(0, 0);
  final Set<Marker> _markers = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Location Saver'), actions: [
        IconButton(icon: Icon(Icons.list), onPressed: _pushSaved),
      ]),
      body: GoogleMap(
        markers: _markers,
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(target: _center),
        myLocationButtonEnabled: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveLocation,
        child: Icon(Icons.save),
      ),
    );
  }

  void _pushSaved() {
    Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (BuildContext context) => LocationsList()));
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _assignLocation();
  }

  void _assignLocation() async {
    final position = await _determinePosition();
    setState(() {
      _center = LatLng(position.latitude, position.longitude);
      _markers.add(
          Marker(markerId: MarkerId(_center.toString()), position: _center));
      mapController.moveCamera(CameraUpdate.newLatLngZoom(_center, 15.0));
    });
  }

  void _saveLocation() {
    if (_center.longitude == 0 && _center.latitude == 0) {
      return;
    }
    Navigator.of(context).push(MaterialPageRoute<void>(
        builder: (BuildContext context) =>
            SaveLocationForm(location: _center)));
  }
}

Future<Position> _determinePosition() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return Future.error('Location services are disabled.');
  }

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.deniedForever) {
    return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
  }

  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission != LocationPermission.whileInUse &&
        permission != LocationPermission.always) {
      return Future.error(
          'Location permissions are denied (actual value: $permission).');
    }
  }

  return await Geolocator.getCurrentPosition();
}
