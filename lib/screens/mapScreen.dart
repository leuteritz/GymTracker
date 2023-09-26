import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '/map/popup.dart';
import 'dart:convert';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import '/map/gymMarker.dart';
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
  bool firstLoad = true;
  bool isCameraMoving = false;
  bool canZoom = true;
  bool isZoom = true;

  Marker? userLocationMarker;

  double radius = (100 / 40075) * 360; // 100km
  double zoom = 15.0;

  LatLng userLocation = LatLng(0, 0);
  LatLng location = LatLng(0, 0);

  List<GymMarker> gymData = [];

  Future<void> fetchGymData(LatLng location) async {
    final double lat = location.latitude;
    final double lon = location.longitude;
    final double latMin = lat - radius;
    final double latMax = lat + radius;
    final double lonMin = lon - radius;
    final double lonMax = lon + radius;

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
    if (searchText.isEmpty) {
      fetchGymData(userLocation);
      return;
    }

    final double lat = userLocation.latitude;
    final double lon = userLocation.longitude;
    final double latMin = lat - radius;
    final double latMax = lat + radius;
    final double lonMin = lon - radius;
    final double lonMax = lon + radius;

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
              userLocation: userLocation);
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
                        "Our gym data is sourced from OpenStreetMap (OSM), a renowned open-source mapping platform. If you are missing information, you are welcome to provide the data yourself, so other people can benefit from it as well. Credit to OSM for providing the mapping and data services!",
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
              placeholder: 'Search for a gym',
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
                    userLocation = snapshot.data!;

                    userLocationMarker = Marker(
                      width: 60,
                      height: 60,
                      point: snapshot.data!,
                      rotateAlignment: Alignment.center,
                      builder: (ctx) => Container(
                        child: Icon(
                          CupertinoIcons
                              .dot_square, // You can customize the marker icon
                        ),
                      ),
                    );
                  }

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
                      zoom: zoom,
                      rotation: 0.0,
                      maxZoom: 18.0,
                      minZoom: 3.0,
                      onPositionChanged:
                          (MapPosition pos, bool hasGesture) async {
                        firstLoad = false;
                        location = pos.center!;

                        if (pos.zoom! >= 18.0) {
                          _mapController.move(pos.center!, 17.0);
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
                                    return Popup(gymMarker);
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
                  setState(() {
                    zoom = 14.0;
                  });
                },
              ),
            ),
            Positioned(
              bottom: 40,
              left: 20,
              child: Container(
                width: 100,
                child: CupertinoSlider(
                  value: zoom,
                  min: 9.0,
                  max: 17.0,
                  divisions: 8,
                  onChanged: (double value) {
                    setState(() {
                      zoom = value;
                    });
                    isZoom = false;
                  },
                ),
              ),
            ),
            Positioned(
              bottom: 80,
              left: 48,
              child: Visibility(
                visible: isZoom,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      'Zoom here',
                      style: TextStyle(
                        fontSize: 15,
                        color: CupertinoColors.black,
                      ),
                    ),
                    Icon(
                      CupertinoIcons.arrow_down,
                      size: 40,
                      color: CupertinoColors.black,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
