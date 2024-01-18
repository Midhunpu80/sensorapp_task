import 'dart:async';
import 'dart:isolate';
import 'package:flutter_isolate/flutter_isolate.dart';
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
    _configureBackgroundIsolate();
  }

  Future<void> _initDatabase() async {
    try {
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
    } catch (e) {
      print(e.toString());
    }
  }

  Future<void> _insertData() async {
    await _database.insert(
      'sensor_data',
      {
        'latitude': locationData.value?.latitude,
        'longitude': locationData.value?.longitude,
        'altitude': locationData.value?.altitude,
        'velocity': locationData.value?.speed,
        'accelerometerX':
            accelerometerValues.isNotEmpty ? accelerometerValues[0] : null,
        'accelerometerY':
            accelerometerValues.length > 1 ? accelerometerValues[1] : null,
        'accelerometerZ':
            accelerometerValues.length > 2 ? accelerometerValues[2] : null,
        'gyroscopeX': gyroscopeValues.isNotEmpty ? gyroscopeValues[0] : null,
        'gyroscopeY': gyroscopeValues.length > 1 ? gyroscopeValues[1] : null,
        'gyroscopeZ': gyroscopeValues.length > 2 ? gyroscopeValues[2] : null,
        'magnetometerX':
            magnetometerValues.isNotEmpty ? magnetometerValues[0] : null,
        'magnetometerY':
            magnetometerValues.length > 1 ? magnetometerValues[1] : null,
        'magnetometerZ':
            magnetometerValues.length > 2 ? magnetometerValues[2] : null,
      },
    );
  }

  void _startDataCollection() {
    Timer.periodic(Duration(seconds: 1), (timer) async {
      try {
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

        // Send a message to the background isolate
        _sendToBackgroundIsolate("Hello from main isolate");
      } catch (e) {
        print('Error during data collection: $e');
      }
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

  void _configureBackgroundIsolate() async {
    final receivePort = ReceivePort();
    final isolate = await FlutterIsolate.spawn(
      _backgroundIsolate,
      {"sendPort": receivePort.sendPort},
    );

    receivePort.listen((message) {
      // Handle messages from the background isolate if needed
      print("Received message in main isolate: $message");
    });

    // Store the sendPort for future communication
    _backgroundIsolateSendPort = receivePort.sendPort;
  }

  static SendPort? _backgroundIsolateSendPort;

  static Future<void> _backgroundIsolate(Map<String, dynamic> context) async {
    final receivePort = ReceivePort();
    final sendPort = context["sendPort"] as SendPort;

    sendPort.send(receivePort.sendPort);

    receivePort.listen((message) {
      // Handle background isolate logic here
      // You can call _backgroundFetchCallback or perform background tasks
      print("Received message in background isolate: $message");
    });
  }

  void _sendToBackgroundIsolate(String message) {
    // Check if the background isolate sendPort is available
    if (_backgroundIsolateSendPort != null) {
      _backgroundIsolateSendPort!.send(message);
    }
  }
}
