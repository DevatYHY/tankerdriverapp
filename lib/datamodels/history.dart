import 'package:firebase_database/firebase_database.dart';

class History {
  String pickup;
  String destination;
  String fares;
  String status;
  String createdAt;
  String paymentMethod;
  String rating;
  String feedback;
  String riderName;

  History(
      {this.pickup,
      this.destination,
      this.fares,
      this.status,
      this.createdAt,
      this.paymentMethod,
      this.rating,
      this.feedback,
      this.riderName});

  History.fromSnapshot(DataSnapshot snapshot) {
    pickup = snapshot.value['pickup_address'];
    destination = snapshot.value['destination_address'];
    fares = snapshot.value['fares'].toString();
    createdAt = snapshot.value['created_at'];
    status = snapshot.value['status'];
    paymentMethod = snapshot.value['payment_method'];
    rating = (snapshot.value['rateAndReview']['rating'].toString() != null)
        ? snapshot.value['rateAndReview']['rating'].toString()
        : 'Not rated';
    feedback = (snapshot.value['rateAndReview']['feedback'] != null)
        ? snapshot.value['rateAndReview']['feedback']
        : '';
    riderName = snapshot.value['rider_name'];
  }
}
