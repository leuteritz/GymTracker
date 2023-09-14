import 'package:flutter/cupertino.dart';
import 'gymmarker.dart';
import 'dart:math';
import 'package:url_launcher/url_launcher.dart';
import 'package:latlong2/latlong.dart';

class ExamplePopup extends StatefulWidget {
  final GymMarker gymMarker;

  const ExamplePopup(this.gymMarker, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ExamplePopupState();
}

class _ExamplePopupState extends State<ExamplePopup> {
  String street = '';
  String name = '';
  String postcode = '';
  String city = '';
  String housenumber = '';

  @override
  void initState() {
    super.initState();

    street = widget.gymMarker.street ?? '';
    name = widget.gymMarker.name;
    postcode = widget.gymMarker.postcode ?? '';
    city = widget.gymMarker.city ?? '';
    housenumber = widget.gymMarker.housenumber ?? '';
    checkNameStreet();
  }

  double calculateDistance(LatLng from, LatLng to) {
    const double radiusOfEarth = 6371.0;

    final double lat1Rad = from.latitude * pi / 180.0;
    final double lat2Rad = to.latitude * pi / 180.0;
    final double lon1Rad = from.longitude * pi / 180.0;
    final double lon2Rad = to.longitude * pi / 180.0;

    final double deltaLat = lat2Rad - lat1Rad;
    final double deltaLon = lon2Rad - lon1Rad;

    final double a = sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(deltaLon / 2) * sin(deltaLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return radiusOfEarth * c;
  }

  void checkNameStreet() {
    street = widget.gymMarker.street ?? '';
    street = street.replaceAll("Ã¶", "ö");
    street = street.replaceAll("Ã¼", "ü");
    street = street.replaceAll("Ã", "ß");
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(10), // Margin for spacing
      padding: EdgeInsets.all(10), // Padding for content spacing
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0), // Rounded corners
        color: CupertinoColors.white, // Background color
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.systemGrey6,
            blurRadius: 4.0,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Icon(
                  CupertinoIcons.location_solid,
                ),
              ),
              SizedBox(height: 5),
              Text(
                '${calculateDistance(widget.gymMarker.userLocation!, widget.gymMarker.location).toStringAsFixed(2)} km',
                style: const TextStyle(
                  fontSize: 10.0,
                  color: CupertinoColors.black,
                ),
              ),
            ],
          ),
          _cardDescription(context),
        ],
      ),
    );
  }

  void _showNavigationDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('Navigate to Gym'),
          content: Text('Choose your navigation app:'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('Apple Maps'),
              onPressed: () {
                _launchAppleMaps();
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: Text('Google Maps'),
              onPressed: () {
                _launchGoogleMaps();
                Navigator.of(context).pop();
              },
            ),
            CupertinoDialogAction(
              child: Text('Cancel'), // Add Cancel button
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Close the dialog without any action
              },
            ),
          ],
        );
      },
    );
  }

  void _launchAppleMaps() {
    // Use Apple Maps URL scheme
    final String appleMapsUrl =
        'https://maps.apple.com/?q=${widget.gymMarker.name ?? ''},'
        '${widget.gymMarker.city ?? ''}';
    launchUrl(Uri.parse(appleMapsUrl));
  }

  void _launchGoogleMaps() {
    // Use Google Maps URL
    final String googleMapsUrl =
        'https://maps.google.com/maps?q=${widget.gymMarker.name ?? ''},'
        '${widget.gymMarker.city ?? ''}';
    launchUrl(Uri.parse(googleMapsUrl));
  }

  Widget _cardDescription(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 100, maxWidth: 200),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: () {
              _showNavigationDialog(context);
            },
            child: Text(
              name,
              style: const TextStyle(
                  fontSize: 12.0,
                  color: CupertinoColors.black,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline),
            ),
          ),
          Text(
            '$postcode $city',
            style: const TextStyle(
              fontSize: 10.0,
              color: CupertinoColors.black,
            ),
          ),
          Text(
            '$street $housenumber',
            style: const TextStyle(
              fontSize: 10.0,
              color: CupertinoColors.black,
            ),
          ),
          GestureDetector(
            onTap: () async {
              final Uri url = Uri.parse(widget.gymMarker.website!);

              await launchUrl(url);
            },
            child: Text(
              widget.gymMarker.website ?? '',
              style: const TextStyle(
                fontSize: 10.0,
                color: CupertinoColors.activeBlue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
