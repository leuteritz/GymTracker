import 'package:latlong2/latlong.dart';

class GymMarker {
  final LatLng location;
  final String name;
  final String? website;
  final String? city;
  final String? street;
  final String? postcode;
  final String? housenumber;

  GymMarker(
      {required this.location,
      required this.name,
      this.website,
      this.city,
      this.street,
      this.postcode,
      this.housenumber});
}
