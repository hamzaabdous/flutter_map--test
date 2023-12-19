import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
//import 'package:flutter_map/plugin_api.dart';

import 'myInput.dart';

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
  final start = TextEditingController();
  final end = TextEditingController();
  List<LatLng> routpoints = [LatLng(52.05884, -1.345583)];
  bool isVisible = false;

  @override
  void initState() {
    super.initState();
    _fetchPermissionStatus();
    //_getCurrentLocation();
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
      body: Builder(builder: (context) {
        if (_hasPermissions) {
          _getCurrentLocation();

          return Column(
            children: <Widget>[
              myInput(controler: start, hint: 'Enter Starting PostCode'),
              SizedBox(
                height: 15,
              ),
              myInput(controler: end, hint: 'Enter Ending PostCode'),
              SizedBox(
                height: 15,
              ),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[500]),
                  onPressed: () async{
                    List<Location> start_l = await locationFromAddress(start.text);
                    List<Location> end_l = await locationFromAddress(end.text);

                    var v1 = start_l[0].latitude;
                    var v2 = start_l[0].longitude;
                    var v3 = end_l[0].latitude;
                    var v4 = end_l[0].longitude;


                    var url = Uri.parse('http://router.project-osrm.org/route/v1/driving/$v2,$v1;$v4,$v3?steps=true&annotations=true&geometries=geojson&overview=full');
                    var response = await http.get(url);
                    print(response.body);
                    setState(() {
                      routpoints = [];
                      var ruter = jsonDecode(response.body)['routes'][0]['geometry']['coordinates'];
                      for(int i=0; i< ruter.length; i++){
                        var reep = ruter[i].toString();
                        reep = reep.replaceAll("[","");
                        reep = reep.replaceAll("]","");
                        var lat1 = reep.split(',');
                        var long1 = reep.split(",");
                        routpoints.add(LatLng( double.parse(lat1[1]), double.parse(long1[0])));
                      }
                      isVisible = !isVisible;
                      print(routpoints);
                    });
                  },
                  child: Text('Press')),
              SizedBox(height: 10,),
              Expanded(child: _map()),
            ],
          );
        } else {
          return _buildPermissionSheet();
        }
      }),
    );
  }

  Widget _map() {
    return SizedBox(
        height: 500,
        width: 400,
        child: Visibility(
          visible: true,
          child: FlutterMap(
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
          ),
        ));
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
