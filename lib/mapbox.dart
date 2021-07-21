import 'package:flutter_mapbox_navigation/library.dart';
import 'package:geolocator/geolocator.dart';

//usage await DriverNavigationService(destination: Position(longitude: 0.0, latitude: 0.0)).navigateViaMapBox();

class DriverNavigationService {
  late MapBoxNavigation _directions;
  late MapBoxOptions _mapBoxOptions;
  Position destination;

  DriverNavigationService({required this.destination}) {
    _directions = MapBoxNavigation(onRouteEvent: routeEventHandler);
  }

  navigateViaMapBox() async {
    Position currentPosition = await Geolocator.getCurrentPosition();
    print('currentPosition: $currentPosition');
    _mapBoxOptions = _mapBoxOptions = MapBoxOptions(
        voiceInstructionsEnabled: true,
        bannerInstructionsEnabled: true,
        longPressDestinationEnabled: false,
        mode: MapBoxNavigationMode.driving,
        simulateRoute: false,
        tilt: 0.0,
        bearing: 0.0,
        language: "en",
        units: VoiceUnits.metric,
        zoom: 13,
        animateBuildRoute: true,
        initialLatitude: currentPosition.latitude,
        initialLongitude: currentPosition.longitude,
        enableRefresh: true);
    List<WayPoint> wayPoints = [];
    wayPoints.add(WayPoint(
        name: "Start",
        latitude: currentPosition.latitude,
        longitude: currentPosition.longitude));
    wayPoints.add(WayPoint(
        name: "Destination",
        latitude: destination.latitude,
        longitude: destination.longitude));
    return await _directions.startNavigation(
        wayPoints: wayPoints, options: _mapBoxOptions);
  }

  routeEventHandler(RouteEvent e) async {
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
