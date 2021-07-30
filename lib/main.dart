import 'dart:async';
import 'dart:io';

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
      : _directions = MapBoxNavigation(onRouteEvent: (RouteEvent e) async {
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
        });

  navigateViaMapBox() async {
    Position currentPosition = await getCurrentPosition();
    MapBoxOptions _mapBoxOptions = MapBoxOptions(
        voiceInstructionsEnabled: true,
        bannerInstructionsEnabled: true,
        longPressDestinationEnabled: false,
        mode: MapBoxNavigationMode.driving,
        tilt: 0.0,
        bearing: 0.0,
        language: "en",
        units: VoiceUnits.metric,
        zoom: 23,
        animateBuildRoute: true,
        initialLatitude: currentPosition.latitude,
        initialLongitude: currentPosition.longitude,
        enableRefresh: true);
    List<WayPoint> wayPoints = [];
    wayPoints.add(WayPoint(name: "Start", latitude: currentPosition.latitude, longitude: currentPosition.longitude));
    wayPoints.add(WayPoint(name: "Destination", latitude: destination.latitude, longitude: destination.longitude));
    return await _directions.startNavigation(wayPoints: wayPoints, options: _mapBoxOptions);
  }

  static Future<Position> getCurrentPosition() async {
    try {
      if (Platform.isAndroid) {
        Position cPos =
            await Geolocator.getCurrentPosition(timeLimit: Duration(seconds: 5), forceAndroidLocationManager: true);

        return cPos;
      } else {
        Position cPos = await Geolocator.getCurrentPosition(timeLimit: Duration(seconds: 5));
        return cPos;
      }
    } catch (e) {
      if (e is TimeoutException) {
        print(
          "Timeout in getting position, using fallback method\n$e",
        );
        try {
          Position cPos =
              await Geolocator.getCurrentPosition(forceAndroidLocationManager: true, timeLimit: Duration(seconds: 5));
          print("Retrieved position\n${cPos.toString()}");
          return cPos;
        } on Exception catch (e) {
          if (e is TimeoutException) {
            print(
              "Timeout in getting position, using fallback method\n$e",
            );
            try {
              Position? cPos = await Geolocator.getLastKnownPosition();
              if (cPos == null) {
                throw Exception("Falling back to last known position[DEFAULT]");
              } else {
                print("Retrieved position\n${cPos.toString()}");
                return cPos;
              }
            } catch (e) {
              print('Code: [GeoLocation]\n$e');
              Position? cPos = await Geolocator.getLastKnownPosition(forceAndroidLocationManager: true);
              if (cPos == null) {
                print("Failed fallback methods, returning [0,0]\n$e");
                return Position.fromMap({"longitude": 0, "latitude": 0, "speed": 1});
              } else {
                print("Retrieved last known position\n${cPos.toString()}");
                return cPos;
              }
            }
          } else {
            print("Failed fallback methods, returning [0,0]\n$e");
            return Position.fromMap({"longitude": 0, "latitude": 0, "speed": 1});
          }
        }
      } else {
        print("Failed fallback methods, returning [0,0]\n$e");
        return Position.fromMap({"longitude": 0, "latitude": 0, "speed": 1});
      }
    }
  }
}
