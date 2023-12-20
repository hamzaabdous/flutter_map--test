import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';

class myCurrentLocationLayer extends StatelessWidget {
  const myCurrentLocationLayer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
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
}