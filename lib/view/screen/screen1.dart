import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sensor_app/controller/datacontroller.dart';

class screen1 extends StatelessWidget {
  final  mydatacontroller controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SizedBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Obx(() => Text(
                    'Latitude: ${controller.locationData.value?.latitude ?? 'N/A'}')),
                Obx(() => Text(
                    'Longitude: ${controller.locationData.value?.longitude ?? 'N/A'}')),
                Obx(() => Text(
                    'Altitude: ${controller.locationData.value?.altitude ?? 'N/A'}')),
                Obx(() => Text(
                    'Velocity: ${controller.locationData.value?.speed ?? 'N/A'}')),
                Obx(() => Text('Accelerometer: ${controller.accelerometerValues}')),
                Obx(() => Text('Gyroscope: ${controller.gyroscopeValues}')),
                Obx(() => Text('Magnetometer: ${controller.magnetometerValues}')),
              ]),
        ),
      ),
    );
  }
}
