import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'popup.dart';
import 'dart:convert';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'gymmarker.dart';
import 'dart:async';

class MapScreen extends StatefulWidget {
  MapScreen({Key? key}) : super(key: key);

  @override
  MapScreenState createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  MapController _mapController = MapController();
  PopupController popupController = PopupController();

  bool isLoading = true;
  bool isDataFetched = false;

  Marker? userLocationMarker;

  bool firstLoad = true;
  bool isFetched = false;
  bool islocation = true;
  bool isCameraMoving = false;

  bool canZoom = true;
  double radius = (5 / 40075) * 360; // 5km
  double radiusname = (100 / 40075) * 360; // 10km
  LatLng userLocation = LatLng(0, 0);
  LatLng location = LatLng(0, 0);

  GymMarker? gymMarker;

  List<GymMarker> gymData = [];

  Future<void> fetchGymData(LatLng location) async {
    final double lat = location.latitude;
    final double lon = location.longitude;
    final double latMin = lat - radiusname;
    final double latMax = lat + radiusname;
    final double lonMin = lon - radiusname;
    final double lonMax = lon + radiusname;

    final query = '''
      [out:json];
      node["leisure"="fitness_centre"]
        ($latMin,$lonMin,$latMax,$lonMax);
      out center;
    ''';

    final url =
        Uri.parse('https://overpass-api.de/api/interpreter?data=$query');

    final response = await http.get(url);
    print(1);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['elements'];
      print(data);
      setState(() {
        gymData = data.cast<Map<String, dynamic>>().map((gym) {
          var gymName = gym['tags']['name'] ?? 'Unknown Gym';
          return GymMarker(
              location: LatLng(gym['lat'], gym['lon']),
              name: gymName,
              website: gym['tags']['website'],
              city: gym['tags']['addr:city'],
              street: gym['tags']['addr:street'],
              postcode: gym['tags']['addr:postcode'],
              housenumber: gym['tags']['addr:housenumber'],
              userLocation: userLocation);
        }).toList();
      });
    } else {
      print('API Request Failed with Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      throw Exception('Failed to fetch gym data');
    }
  }

  Future<void> fetchGymDataName(String searchText) async {
    final double lat = userLocation.latitude;
    final double lon = userLocation.longitude;
    final double latMin = lat - radiusname;
    final double latMax = lat + radiusname;
    final double lonMin = lon - radiusname;
    final double lonMax = lon + radiusname;

    final query = '''
      [out:json];
      node["leisure"="fitness_centre"]
        ($latMin,$lonMin,$latMax,$lonMax);
      out center;
    ''';

    final url =
        Uri.parse('https://overpass-api.de/api/interpreter?data=$query');

    final response = await http.get(url);
    print(1);

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body)['elements'];

      final filteredGyms = data.cast<Map<String, dynamic>>().where((gym) {
        var gymName = gym['tags']['name'] ?? 'Unknown Gym';
        return gymName.toLowerCase().contains(searchText.toLowerCase());
      }).toList();
      print("data: $filteredGyms");

      setState(() {
        gymData = filteredGyms.map((gym) {
          var gymName = gym['tags']['name'] ?? 'Unknown Gym';
          return GymMarker(
            location: LatLng(gym['lat'], gym['lon']),
            name: gymName,
            website: gym['tags']['website'],
            city: gym['tags']['addr:city'],
            street: gym['tags']['addr:street'],
            postcode: gym['tags']['addr:postcode'],
            housenumber: gym['tags']['addr:housenumber'],
          );
        }).toList();
      });
    } else {
      print('API Request Failed with Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      throw Exception('Failed to fetch gym data');
    }
  }

  // Get the user's current location
  Future<LatLng?> getUserLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      // Handle the case where the user denies location permission
      return null;
    }

    final position = await Geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  void _showCupertinoModalInfo(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;
    final double modalHeight = screenHeight * 0.3;
    final double modalWidth = screenWidth * 0.8;

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            width: modalWidth,
            height: modalHeight,
            child: CupertinoPopupSurface(
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildInfoText(
                        "The search radius has been set to a distance of 5 kilometers.",
                      ),
                      Container(
                        height: 4,
                        margin: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: CupertinoColors.white,
                        ),
                      ),
                      _buildInfoText(
                        "If a gym displays 'No data available', it means there is no information available for that location in the database.",
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCupertinoModalSearch(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    final double modalWidth = screenWidth * 0.7;

    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            width: modalWidth,
            child: CupertinoSearchTextField(
              placeholderStyle: TextStyle(
                color: CupertinoColors.white
                    .withOpacity(0.5), // Set the color to transparent
              ),
              decoration: BoxDecoration(
                  color: CupertinoColors.systemGrey3.withOpacity(0.3),
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(10)),
              onChanged: fetchGymDataName,
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoText(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          // You can use FontWeight.bold for a bolder look
          letterSpacing: 0.5, // Adjust the letter spacing
          height: 1.2, // Adjust the line height
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Nearby Gyms Map'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(
            CupertinoIcons.info_circle,
            size: 30,
          ),
          onPressed: () {
            _showCupertinoModalInfo(context);
          },
        ),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: Icon(
            CupertinoIcons.search,
            size: 30,
          ),
          onPressed: () {
            _showCupertinoModalSearch(context);
          },
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            if (isLoading) // Display the CupertinoActivityIndicator while loading
              Center(child: CupertinoActivityIndicator()),
            if (!isLoading) // Show the map when loading is complete
              FutureBuilder<LatLng?>(
                future: getUserLocation(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    // Display a loading indicator while waiting for location data
                    return Center(child: CupertinoActivityIndicator());
                  } else if (snapshot.hasError) {
                    // Handle error
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData) {
                    // Handle the case where location data is not available
                    return Center(child: Text('Location data not available'));
                  } else if (snapshot.hasData) {
                    // Create a marker for the user's current location
                    userLocationMarker = Marker(
                      width: 40.0,
                      height: 40.0,
                      point: snapshot.data!,
                      rotateAlignment: Alignment.center,
                      builder: (ctx) => Container(
                        child: Icon(
                          CupertinoIcons
                              .dot_square, // You can customize the marker icon
                          color: CupertinoColors.activeBlue,
                        ),
                      ),
                    );
                  }

                  userLocation = snapshot.data!;
                  print("isDataFetched: $isDataFetched");
                  if (!isDataFetched) {
                    fetchGymData(userLocation);

                    isDataFetched = true;
                  }

                  final gymMarkers = gymData.map((gym) {
                    final gymLocation = gym.location;
                    return Marker(
                      width: 40.0,
                      height: 40.0,
                      point: gymLocation,
                      builder: (ctx) => Container(
                        child: Icon(
                          CupertinoIcons.location_solid,
                          color: CupertinoColors.systemRed,
                        ),
                      ),
                    );
                  }).toList();

                  gymMarkers.add(userLocationMarker!);

                  return FlutterMap(
                    options: MapOptions(
                      center: firstLoad ? userLocation : location,
                      zoom: 14.0,
                      rotation: 0.0,
                      maxZoom: 18.0,
                      minZoom: 3.0,
                      onPositionChanged:
                          (MapPosition pos, bool hasGesture) async {
                        location = pos.center!;

                        print("zoom: ${pos.zoom}");
                        if (pos.zoom! >= 18.0) {
                          _mapController.move(pos.center!, 17.0);
                        }
                        if (pos.zoom! <= 11.0 && userLocation != pos.center!) {
                          firstLoad = false;
                          if (!isCameraMoving) {
                            isCameraMoving = true;
                            Timer(Duration(seconds: 2), () {
                              if (isCameraMoving) {
                                _mapController.move(pos.center!, pos.zoom!);
                                fetchGymData(location);
                                _mapController.move(pos.center!, pos.zoom!);
                                isCameraMoving = false;
                              }
                            });
                          }
                        }
                      },
                    ),
                    children: [
                      GestureDetector(
                        onTap: () {
                          popupController
                              .hideAllPopups(); // Close all popups when tapping on the map
                        },
                        child: TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.app',
                        ),
                      ),
                      MarkerLayer(
                        markers: gymMarkers,
                      ),
                      PopupMarkerLayer(
                          options: PopupMarkerLayerOptions(
                              popupController: popupController,
                              markers: gymMarkers,
                              popupDisplayOptions: PopupDisplayOptions(
                                builder: (BuildContext context, Marker marker) {
                                  final index = gymMarkers.indexOf(marker);
                                  if (index >= 0 && index < gymData.length) {
                                    final gymMarker = gymData[index];
                                    return ExamplePopup(gymMarker);
                                  }
                                  return SizedBox();
                                },
                              ))),

                      //
                    ],
                    mapController: canZoom ? _mapController : null,

                    // Add other map configuration and layers here
                  );
                },
              ),
            Positioned(
              bottom: 20,
              right: 20,
              child: CupertinoButton(
                child: Icon(
                  CupertinoIcons.location_circle_fill,
                  size: 60,
                ),
                onPressed: () {
                  // Animate to the user's current location when the button is pressed
                  _mapController.move(userLocation, 14);
                  _mapController.rotate(0.0);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
