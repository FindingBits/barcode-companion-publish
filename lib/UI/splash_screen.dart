import 'package:barcode_companion/Backend/database.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:barcode_companion/main.dart';
import 'package:barcode_companion/UI/Home/home_page.dart';
import 'package:flutter/services.dart';

/// Splash Screen Caller is the loading screen for your app
/// In this Widget, eseential dependencies like loading the cameras, first database run, and other stuff that might be implemented in the future
/// If more dependencies are needed, place their code inside _initializeAsyncDependencies()
/// Can be called using
/// ```dart
///  SplashScreen(onInitializationComplete: someFunction())
///  // Or like this, if there is the need of a longer splash screen
///  SplashScreen(extraTime: 1000, onInitializationComplete: someFunction())
/// ```
/// extraTime - Extra time after loading the dependencies (in milliseconds) if there is a need of showing the splash screen for longer time
/// onInitializationComplete - Function that runs after all the dependencies are loaded

class SplashScreenCaller extends StatefulWidget {
  final onInitializationComplete;
  final extraTime;

  const SplashScreenCaller(
      {Key key, this.extraTime = 0, @required this.onInitializationComplete})
      : super(key: key);

  @override
  _SplashScreenCallerState createState() => _SplashScreenCallerState();
}

class _SplashScreenCallerState extends State<SplashScreenCaller> {
  /// Function to initialize dependencies
  /// The functions to be called need to be async
  /// _initializeAsyncDependencies() needs to be called inside initState()
  /// If more dependencies need to be later added, insert the code insine the function like this

  /// ```dart
  ///  await setdatabase(); // Already added by us
  ///  await updateScans(); // Already added by us
  ///  await loadSomeStuff();
  ///  await findNearbyDevices();
  /// ```
  Future<void> _initializeAsyncDependencies() async {
    cameras = await availableCameras();

    await setdatabase();
    await updateScans();
    await setDir();

    // This takes extra time for the function to finallyze, if necessary
    Future.delayed(Duration(milliseconds: this.widget.extraTime)).then((_) {
      widget.onInitializationComplete();
    });
  }

  void initState() {
    super.initState();
    _initializeAsyncDependencies();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      home: Scaffold(
        body: SplashScreen(),
      ),
    );
  }
}

/// Visual Part of the Splash Screen
/// Our team name (Zaang) and app name (Barcode Companion) can be changed by replacing
/// ```dart
/// Text( "Barcode Companion",...) by Text("Some name", ...)
/// // And
/// Text("by ZAANG", ...) by Text("CTT example name", ...)
/// ```
class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return Container(
      height: height,
      decoration: BoxDecoration(color: Colors.red),
      child: Center(
        child: Container(
          height: 0.7 * height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Center(
                child: Container(
                  child: Column(
                    children: [
                      // Picture found in ctt-taikai challenge
                      Container(
                        width: 0.7 * width,
                        child: Image.asset('assets/images/log.png'),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      "Barcode Companion",
                      style: TextStyle(
                          fontFamily: "Roboto",
                          fontSize: 44.0,
                          color: Colors.white),
                    ),
                    Text(
                      "by ZAANG",
                      style: TextStyle(
                        fontFamily: "Roboto",
                        fontSize: 25.0,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 0.1 * height,
              ),
              CircularProgressIndicator(
                backgroundColor: Colors.red,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
