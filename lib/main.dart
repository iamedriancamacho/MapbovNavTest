import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mapbox_navigation/library.dart';
import 'package:geolocator/geolocator.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Material App',
      home: Scaffold(
          appBar: AppBar(
            title: Text('Material App Bar'),
          ),
          body: MapboxNavigationTutorial()),
    );
  }
}

class MapboxNavigationTutorial extends StatefulWidget {
  @override
  _MapboxNavigationTutorialState createState() => _MapboxNavigationTutorialState();
}

class _MapboxNavigationTutorialState extends State<MapboxNavigationTutorial> {
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      // Container(
      //     color: Colors.grey,
      //     child: MapBoxNavigationView(
      //         options: _options,
      //         onRouteEvent: _onRouteEvent,
      //         onCreated: (MapBoxNavigationViewController controller) async {
      //           _controller = controller;
      //         })),
      ElevatedButton(
        onPressed: () async {
          print('I AM PRESSED');
          await DriverNavigationService(
              destination: Position.fromMap({
            "latitude": 10.29349592073334,
            "longitude": 123.901997407398,
          })).navigateViaMapBox();
        },
        child: Text('hi'),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed)) return Theme.of(context).colorScheme.primary;
              // Use the component's default.
              return Theme.of(context).colorScheme.secondary.withOpacity(0.5);
            },
          ),
        ),
      ),
    ]);
  }
}

class DriverNavigationService {
  MapBoxNavigation _directions;
  Position destination;
  DriverNavigationService({required this.destination})
      : _directions = MapBoxNavigation(onRouteEvent: routeEventHandler);

  navigateViaMapBox() async {
    Position currentPosition = await Geolocator.getCurrentPosition(forceAndroidLocationManager: true);
    MapBoxOptions _mapBoxOptions = MapBoxOptions(
        voiceInstructionsEnabled: true,
        bannerInstructionsEnabled: true,
        longPressDestinationEnabled: false,
        mode: MapBoxNavigationMode.driving,
        simulateRoute: false,
        tilt: 0.0,
        bearing: 0.0,
        language: "en",
        units: VoiceUnits.metric,
        zoom: 23,
        animateBuildRoute: false,
        initialLatitude: currentPosition.latitude,
        initialLongitude: currentPosition.longitude,
        enableRefresh: true);
    List<WayPoint> wayPoints = [];
    wayPoints.add(WayPoint(name: "Start", latitude: currentPosition.latitude, longitude: currentPosition.longitude));
    wayPoints.add(WayPoint(name: "Destination", latitude: destination.latitude, longitude: destination.longitude));
    return await _directions.startNavigation(wayPoints: wayPoints, options: _mapBoxOptions);
  }

  static routeEventHandler(RouteEvent e) async {
    print(e.eventType);
    print("^^^^^^^^^^^^^^^^^^^^^^^^^^^");
    switch (e.eventType) {
      case MapBoxEvent.navigation_running:
        print("Navigation has started");
        break;
      case MapBoxEvent.milestone_event:
        break;
      case MapBoxEvent.navigation_finished:
      case MapBoxEvent.navigation_cancelled:
        print("Navigation has ended");
        break;
      default:
        break;
    }
  }
}
