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
  _MapboxNavigationTutorialState createState() =>
      _MapboxNavigationTutorialState();
}

class _MapboxNavigationTutorialState extends State<MapboxNavigationTutorial> {
  late MapBoxNavigation _directions;
  late MapBoxNavigationViewController _controller;

  var _isMultipleStop;
  @override
  void initState() {
    super.initState();
    _directions = MapBoxNavigation(onRouteEvent: _onRouteEvent);
  }

  _onRouteEvent(e) async {
    // FutureOr<double> _distanceRemaining = await _directions.distanceRemaining;
    //FutureOr<double> _durationRemaining = await _directions.durationRemaining;

    // print('distanceRemaining: $_distanceRemaining');
    //print('durationRemaining: $_durationRemaining');

    switch (e.eventType) {
      case MapBoxEvent.progress_change:
        var progressEvent = e.data as RouteProgressEvent;
        var _arrived = progressEvent.arrived;
        if (progressEvent.currentStepInstruction != null)
          var _instruction = progressEvent.currentStepInstruction;
        break;
      case MapBoxEvent.route_building:
      case MapBoxEvent.route_built:
        var _routeBuilt = true;
        break;
      case MapBoxEvent.route_build_failed:
        var _routeBuilt = false;
        break;
      case MapBoxEvent.navigation_running:
        var _isNavigating = true;
        break;
      case MapBoxEvent.on_arrival:
        var _arrived = true;
        if (!_isMultipleStop!) {
          await Future.delayed(Duration(seconds: 3));
          await _controller.finishNavigation();
        } else {}
        break;
      case MapBoxEvent.navigation_finished:
      case MapBoxEvent.navigation_cancelled:
        var _routeBuilt = false;
        var _isNavigating = false;
        break;
      default:
        break;
    }
    //refresh UI
    setState(() {});
  }

  var _options = MapBoxOptions(
      initialLatitude: 10.282204,
      initialLongitude: 123.881575,
      zoom: 14.0,
      tilt: 0.0,
      bearing: 0.0,
      enableRefresh: true,
      alternatives: true,
      voiceInstructionsEnabled: true,
      bannerInstructionsEnabled: true,
      allowsUTurnAtWayPoints: true,
      mode: MapBoxNavigationMode.driving,
      units: VoiceUnits.imperial,
      simulateRoute: true,
      language: "en");

  mapboxNavigation() async {
    Position currentPosition = await Geolocator.getCurrentPosition();

    print('my current position: $currentPosition');
    print('currentPosition: $currentPosition');
    final cityhall = WayPoint(
        name: "City Hall",
        latitude: currentPosition.latitude,
        longitude: currentPosition.longitude);
    final downtown = WayPoint(
        name: "Sm Seaside", latitude: 10.282204, longitude: 123.881575);

    var wayPoints = <WayPoint>[];
    wayPoints.add(cityhall);
    wayPoints.add(downtown);
    _controller.buildRoute(wayPoints: wayPoints);
    print('wayPoints: $wayPoints');

    await _directions.startNavigation(wayPoints: wayPoints, options: _options);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Container(
          color: Colors.grey,
          child: MapBoxNavigationView(
              options: _options,
              onRouteEvent: _onRouteEvent,
              onCreated: (MapBoxNavigationViewController controller) async {
                _controller = controller;
              })),
      ElevatedButton(
        onPressed: () async {
          print('I AM PRESSED');
          mapboxNavigation();
          // _controller.startNavigation();
          // await DriverNavigationService(
          //         destination: Position(
          //             timestamp: DateTime.now(),
          //             longitude: 10.282204,
          //             latitude: 123.881575,
          //             accuracy: 10,
          //             altitude: 9,
          //             heading: 10,
          //             speed: 10,
          //             speedAccuracy: 10,
          //             floor: 1,
          //             isMocked: true))
          //     .navigateViaMapBox();
        },
        child: Text('hi'),
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed))
                return Theme.of(context).colorScheme.primary;
              // Use the component's default.
              return Theme.of(context).colorScheme.secondary.withOpacity(0.5);
            },
          ),
        ),
      ),
    ]);
  }
}
