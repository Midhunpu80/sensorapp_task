import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sensor_app/controller/datacontroller.dart';
import 'package:sensor_app/view/utility/alltext.dart';
import 'package:sensor_app/view/utility/colors.dart';

class Screen1 extends StatelessWidget {
  final mydatacontroller controller = Get.find();

  @override
  Widget build(BuildContext context) {
    print(controller.locationData.value?.latitude);
    
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: Icon(
            Icons.sensor_window_rounded,
            color: wh,
          ),
          toolbarHeight: 70,
          backgroundColor: bl,
          title: alltext(
              txt: "Sensor Data",
              col: wh,
              siz: 18,
              wei: FontWeight.bold,
              max: 1),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _buildSensorData(
                  'Latitude', controller.locationData.value?.latitude),
              _buildSensorData(
                  'Longitude', controller.locationData.value?.longitude),
              _buildSensorData(
                  'Altitude', controller.locationData.value?.altitude),
              _buildSensorData(
                  'Velocity', controller.locationData.value?.speed),
              _buildSensorData('Accelerometer', controller.accelerometerValues),
              _buildSensorData('Gyroscope', controller.gyroscopeValues),
              _buildSensorData('Magnetometer', controller.magnetometerValues),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSensorData(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              value?.toString() ?? 'N/A',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
