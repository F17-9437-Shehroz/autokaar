import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';


class MapScreen extends StatelessWidget {
  final CameraPosition initialCameraPosition;

  const MapScreen({required this.initialCameraPosition});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location'),
      ),
      body: GoogleMap(
        initialCameraPosition: initialCameraPosition,
        onTap: (LatLng location) {
          // Handle when the user taps on the map to select a location
          Navigator.pop(context, CameraPosition(target: location));
        },
      ),
    );
  }
}

