import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:sensor_app/view/screen/screen1.dart';

import 'controller/datacontroller.dart';

void main() {
  runApp(const MyApp());
 Get.put<mydatacontroller>(mydatacontroller());

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        // ignore: prefer_const_constructors
        home: Scaffold(
          body: Screen1(),
        ));
  }
}
