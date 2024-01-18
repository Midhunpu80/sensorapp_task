import 'dart:async';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:sqflite/sqflite.dart';
import 'package:workmanager/workmanager.dart';

class MyDataController extends GetxController {
  // ... existing code ...

  @override
  void onInit() {
    super.onInit();
    // _initDatabase();
    // _startDataCollection();
    _configureBackgroundTasks();
  }

  // ... existing code ...

  void _configureBackgroundTasks() {
    Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: true, // Set to true for debugging
    );

    Workmanager().registerOneOffTask(
      "backgroundTask",
      "simpleBackgroundTask",
      initialDelay: Duration(minutes: 15),
    );
  }

  static void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) async {
      // This callback is called when the background task is triggered
      // Place the background task logic here
      print("Background task executed");

      try {
        MyDataController controller = MyDataController();
       // await controller._backgroundFetchCallback("backgroundTask");
      } catch (e) {
        print('Error during background task: $e');
      }

      return Future.value(true);
    });
  }
}
