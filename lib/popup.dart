import 'package:flutter/cupertino.dart';

import 'package:flutter_map/flutter_map.dart';
import 'gymmarker.dart';

class ExamplePopup extends StatefulWidget {
  final GymMarker gymMarker;

  const ExamplePopup(this.gymMarker, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ExamplePopupState();
}

class _ExamplePopupState extends State<ExamplePopup> {
  @override
  Widget build(BuildContext context) {
    print(widget.gymMarker.name);
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

  Widget _cardDescription(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 100, maxWidth: 200),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Gym Name: ${widget.gymMarker.name}',
            style: const TextStyle(
                fontSize: 12.0,
                color: CupertinoColors.black,
                fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
