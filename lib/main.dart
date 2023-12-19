import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Position? _currentPosition;
  LatLng endLatLng = LatLng(35.779, -5.803); // Ending point coordinates
  bool _hasPermissions = false;


  @override
  void initState() {
    super.initState();
    _fetchPermissionStatus();
    _getCurrentLocation();

  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      print(e);
      setState(() {
        print('Error getting location.');
      });
    }
  }
  Widget _buildPermissionSheet() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Location Permission Required'),
          ElevatedButton(
            child: Text('Request Permissions'),
            onPressed: () {
              Permission.locationWhenInUse.request().then((ignored) {
                _fetchPermissionStatus();
              });
            },
          ),
          SizedBox(height: 16),
          ElevatedButton(
            child: Text('Open App Settings'),
            onPressed: () {
              openAppSettings().then((opened) {
                //
              });
            },
          )
        ],
      ),
    );
  }

  void _fetchPermissionStatus() {
    Permission.locationWhenInUse.status.then((status) {
      if (mounted) {
        setState(() => _hasPermissions = status == PermissionStatus.granted);
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //
      appBar: AppBar(
        title: Text('My App'),
      ), // use Scaffold also in order to provide material app widgets
      body: Builder(builder:(context){
        if (_hasPermissions) {
          return Column(
            children: <Widget>[
              Expanded(child: _map()),
            ],
          );
        } else {
          return _buildPermissionSheet();
        }
      }),
    );
  }
  Widget _map(){
    return FlutterMap(
      options: MapOptions(
        initialCenter:
        LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        initialZoom: 9.2,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.app',
        ),
        CurrentLocationLayer(),
        PolylineLayer(
          polylines: [
            Polyline(
              points: [
                LatLng(
                    _currentPosition!.latitude, _currentPosition!.longitude),
                LatLng(35.779, -5.803)
              ],
              color: Colors.blue,
            ),
          ],
        ),
        RichAttributionWidget(
          attributions: [
            TextSourceAttribution(
              'OpenStreetMap contributors',
              onTap: () =>
                  launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
            ),
          ],
        ),
      ],
    );
  }
}


Widget build() {
  return CurrentLocationLayer(
    followOnLocationUpdate: FollowOnLocationUpdate.always,
    turnOnHeadingUpdate: TurnOnHeadingUpdate.never,
    style: LocationMarkerStyle(
      marker: const DefaultLocationMarker(
        child: Icon(
          Icons.navigation,
          color: Colors.white,
        ),
      ),
      markerSize: const Size(40, 40),
      markerDirection: MarkerDirection.heading,
    ),
  );
}
