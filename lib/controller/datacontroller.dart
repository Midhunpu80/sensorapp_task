import 'dart:async';

import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:sqflite/sqflite.dart';

class mydatacontroller extends GetxController {
  final Rx<LocationData?> locationData = Rx<LocationData?>(null);
  final RxList<double> accelerometerValues = <double>[].obs;
  final RxList<double> gyroscopeValues = <double>[].obs;
  final RxList<double> magnetometerValues = <double>[].obs;
  late Database _database;
  @override
  void onInit() {
    super.onInit();
    _initDatabase();
    _startDataCollection();
  }

  Future<void> _initDatabase() async {
    _database = await openDatabase(
      'my_database.db',
      version: 1,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE sensor_data(id INTEGER PRIMARY KEY, latitude REAL, longitude REAL, '
          'altitude REAL, velocity REAL, accelerometerX REAL, accelerometerY REAL, accelerometerZ REAL, '
          'gyroscopeX REAL, gyroscopeY REAL, gyroscopeZ REAL, magnetometerX REAL, magnetometerY REAL, magnetometerZ REAL)',
        );
      },
    );
  }

  Future<void> _insertData() async {
    await _database.insert(
      'sensor_data',
      {
        'latitude': locationData.value?.latitude,
        'longitude': locationData.value?.longitude,
        'altitude': locationData.value?.altitude,
        'velocity': locationData.value?.speed,
        'accelerometerX': accelerometerValues[0],
        'accelerometerY': accelerometerValues[1],
        'accelerometerZ': accelerometerValues[2],
        'gyroscopeX': gyroscopeValues[0],
        'gyroscopeY': gyroscopeValues[1],
        'gyroscopeZ': gyroscopeValues[2],
        'magnetometerX': magnetometerValues[0],
        'magnetometerY': magnetometerValues[1],
        'magnetometerZ': magnetometerValues[2],
      },
    );
  }

  void _startDataCollection() {
    Timer.periodic(Duration(seconds: 1), (timer) async {
      LocationData locationData = await _getLocationData();
      List<double> accelerometerValues = await _getAccelerometerValues();
      List<double> gyroscopeValues = await _getGyroscopeValues();
      List<double> magnetometerValues = await _getMagnetometerValues();

      this.locationData.value = locationData;
      this.accelerometerValues.assignAll(accelerometerValues);
      this.gyroscopeValues.assignAll(gyroscopeValues);
      this.magnetometerValues.assignAll(magnetometerValues);

      // Insert data into the database
      await _insertData();
    });
  }

  Future<LocationData> _getLocationData() async {
    var location = Location();
    return await location.getLocation();
  }

  Future<List<double>> _getAccelerometerValues() async {
    final accelerometerData = await accelerometerEventStream().first;
    return [accelerometerData.x, accelerometerData.y, accelerometerData.z];
  }

  Future<List<double>> _getGyroscopeValues() async {
    final gyroscopeData = await gyroscopeEventStream().first;
    return [gyroscopeData.x, gyroscopeData.y, gyroscopeData.z];
  }

  Future<List<double>> _getMagnetometerValues() async {
    final magnetometerData = await magnetometerEventStream().first;
    return [magnetometerData.x, magnetometerData.y, magnetometerData.z];
  }
}
