import 'package:google_maps_flutter/google_maps_flutter.dart';

class TripDetails {
  String pickupAddress;
  String destinationAddress;
  LatLng pickup;
  LatLng destination;
  String paymentMethod;
  String rideId;
  String riderName;
  String riderPhone;

  TripDetails(
      {this.pickupAddress,
      this.destinationAddress,
      this.pickup,
      this.destination,
      this.rideId,
      this.riderName,
      this.riderPhone,
      this.paymentMethod});
}
