import 'package:firebase_database/firebase_database.dart';

class Driver {
  String id;
  String fullname;
  String email;
  String phone;
  String carModel;
  String carColor;
  String vehicleNumber;

  Driver(
      {this.id,
      this.fullname,
      this.email,
      this.phone,
      this.carModel,
      this.carColor,
      this.vehicleNumber});

  Driver.fromSnapshot(DataSnapshot snapshot) {
    id = snapshot.key;
    fullname = snapshot.value['fullname'];
    email = snapshot.value['email'];
    phone = snapshot.value['phone'];
    carModel = snapshot.value['vehicle_details']['car_model'];
    carColor = snapshot.value['vehicle_details']['car_color'];
    vehicleNumber = snapshot.value['vehicle_details']['vehicle_number'];
  }
}
