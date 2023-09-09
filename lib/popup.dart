import 'package:flutter/cupertino.dart';
import 'gymmarker.dart';
import 'package:url_launcher/url_launcher.dart';

class ExamplePopup extends StatefulWidget {
  final GymMarker gymMarker;

  const ExamplePopup(this.gymMarker, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ExamplePopupState();
}

class _ExamplePopupState extends State<ExamplePopup> {
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
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Icon(
              CupertinoIcons.location_solid,
            ),
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
              widget.gymMarker.name,
              style: const TextStyle(
                  fontSize: 12.0,
                  color: CupertinoColors.black,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline),
            ),
          ),
          Text(
            '${widget.gymMarker.postcode ?? 'no postcode'} ${widget.gymMarker.city ?? 'no city'}',
            style: const TextStyle(
              fontSize: 10.0,
              color: CupertinoColors.black,
            ),
          ),
          Text(
            '${widget.gymMarker.street ?? 'no street'} ${widget.gymMarker.housenumber ?? 'no number'} ',
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
              widget.gymMarker.website ?? 'No website',
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
