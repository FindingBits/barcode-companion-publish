import 'package:barcode_companion/UI/Home/home_page.dart';
import 'package:barcode_companion/Backend/database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:barcode_companion/UI/Provider/ScrollValue.dart';
import 'package:barcode_companion/UI/Provider/PictureProvider.dart';
import 'package:barcode_companion/Backend/history_manager.dart';
import 'package:barcode_companion/Backend/scan.dart';
import 'UI/Home/home_page.dart';
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';

import 'package:barcode_companion/UI/splash_screen.dart';

/// List containing the cameras available
List<CameraDescription> cameras;

/// List containing the scans saved on the app
List<Scan> _scan;

/// The startup of the app
/// To initilize the app, simply call
///```dart
/// runApp(someSplashScreen(onInitializationComplete: () runApp(TheMainApp() )))
/// ```
Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Splash screen is where our initial dependencies will be initialized, like cameras and data
  runApp(new SplashScreenCaller(
      extraTime: 1500, onInitializationComplete: () => runApp(MyApp())));
}

updateScans() async {
  _scan = await scans();
}

setupCameras() async {
  cameras = await availableCameras();
}

/// MyApp is the root of the application
/// Call it when the dependencies like camera and database are loaded, by simply calling
///```dart
/// runApp(MyApp())
/// ```
class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ScrollValue()),
        ChangeNotifierProvider(create: (_) => PictureProvider()),
        ChangeNotifierProvider(create: (_) => HistoryManager(history: _scan))
      ],
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.red,
          primaryColor: Color(0xFFFD0101),
          accentColor: Color(0xFFFF8A00),
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomePage(cameras: cameras),
      ),
    );
  }
}
