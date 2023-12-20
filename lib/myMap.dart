import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class myMap extends StatelessWidget {
  const myMap({
    super.key,
    required Position? currentPosition,
    required this.routpoints,
  }) : _currentPosition = currentPosition;

  final Position? _currentPosition;
  final List<LatLng> routpoints;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: LatLng(
            _currentPosition!.latitude, _currentPosition!.longitude),
        initialZoom: 9.2,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        CurrentLocationLayer(),
        PolylineLayer(
          polylineCulling: false,
          polylines: [
            Polyline(points: routpoints, color: Colors.blue, strokeWidth: 9)
          ],
        ),
        RichAttributionWidget(
          attributions: [

          ],
        ),
      ],
    );
  }
}