import 'dart:io';
import 'package:barcode_companion/UI/Camera/focus_rectangle.dart';
import 'package:barcode_companion/UI/History/history.dart';
import 'dart:math';
import 'package:barcode_companion/UI/Camera/CameraApp.dart';
import 'package:barcode_companion/barcodeDecoder.dart';
import 'package:barcode_companion/UI/Provider/ScrollValue.dart';
import 'package:barcode_companion/UI/Provider/PictureProvider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/scheduler.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:simple_animations/simple_animations.dart';
import 'package:supercharged/supercharged.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:barcode_companion/UI/Camera/display_form.dart';
import 'package:toast/toast.dart';

String DIR = "";

Future setDir() async {
  Directory directory;
  if (Platform.isAndroid) {
    directory = await getExternalStorageDirectory();
  } else {
    directory = await getApplicationDocumentsDirectory();
  }
  DIR = directory.path;
}

class AnimatedWave extends StatelessWidget {
  final double height;
  final double speed;
  final double offset;

  AnimatedWave({this.height, this.speed, this.offset = 0.0});

  ///Creates a wave effect on the backgound
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          height: height,
          width: constraints.biggest.width,
          child: LoopAnimation<double>(
              duration: (5000 / speed).round().milliseconds,
              tween: 0.0.tweenTo(2 * pi),
              builder: (context, child, value) {
                return CustomPaint(
                  foregroundPainter: CurvePainter(value + offset),
                );
              }),
        );
      },
    );
  }
}

class CurvePainter extends CustomPainter {
  final double value;
  CurvePainter(this.value);
  @override
  void paint(Canvas canvas, Size size) {
    final white = Paint()..color = Colors.white.withAlpha(60);
    final path = Path();

    ///Creates 3 waves variables y1,y2,y3 with some alterations to the normal sin function
    final y1 = sin(value);
    final y2 = sin(value + pi / 2);
    final y3 = sin(value + pi);

    /// Obtain the Start, Control and End points of the waves
    final startPointY = size.height * (0.5 + 0.4 * y1);
    final controlPointY = size.height * (0.5 + 0.4 * y2);
    final endPointY = size.height * (0.5 + 0.4 * y3);

    /// To create a more dinamic effect every wave formation will not be equal to another
    /// Since they have different starting points and the flow will fell more unique
    path.moveTo(size.width * 0, startPointY);
    path.quadraticBezierTo(
        size.width * 0.5, controlPointY, size.width, endPointY);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    canvas.drawPath(path, white);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

///Color1 and 2 will be the variables of the ever changing background
enum _BgProps { color1, color2 }

/// Creates a flowing RGB effect that backs the wave formation
class AnimatedBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tween = MultiTween<_BgProps>()
      ..add(
          _BgProps.color1, Color(0xffD38312).tweenTo(Colors.lightBlue.shade900))
      ..add(_BgProps.color2, Color(0xffA83279).tweenTo(Colors.blue));

    return MirrorAnimation<MultiTweenValues<_BgProps>>(
      tween: tween,
      duration: 3.seconds,
      builder: (context, child, value) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [value.get(_BgProps.color1), value.get(_BgProps.color2)],
            ),
          ),
        );
      },
    );
  }
}

/// Home Page is the foundation of the UI
/// You can call this widget when the camera and saved scans are loaded, passing the returned list of cameras as a parameter
class HomePage extends StatefulWidget {
  HomePage({Key key, this.cameras}) : super(key: key);

  final List<CameraDescription> cameras;
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    /// Stack containing the camera in the background and on top the menu
    return Stack(
      children: [
        Align(
          alignment: Alignment.topCenter,
          child: Stack(
            children: [
              CameraScreen(widget.cameras),
              FocusRectangle(
                color: Color.fromARGB(150, 0, 0, 0),
              ),
            ],
          ),
        ),
        IgnorePointer(
          ignoring: true,
          child: Consumer<ScrollValue>(
            builder: (context, _scrollValue, child) {
              /// Hiding the camera view according to the scroll percentage of the menu
              /// Changes the opacity of the "backgroud". This background is actually on top of the camera
              /// When this widget is fully visible, the camera will be hidden
              return Opacity(
                opacity: _scrollValue.value,
                child: Stack(
                  /// Some animations
                  children: <Widget>[
                    Positioned.fill(child: AnimatedBackground()),
                    onBottom(AnimatedWave(
                      height: 180,
                      speed: 1.0,
                    )),
                    onBottom(AnimatedWave(
                      height: 120,
                      speed: 0.9,
                      offset: pi,
                    )),
                    onBottom(AnimatedWave(
                      height: 220,
                      speed: 1.2,
                      offset: pi / 2,
                    )),
                  ],
                ),
              );
            },
          ),
        ),

        /// The menu itself
        HomeMenu(),
      ],
    );
  }

  Widget onBottom(Widget child) => Positioned.fill(
        child: Align(
          alignment: Alignment.topCenter,
          child: child,
        ),
      );
}

/// Home menu is the draggable menu, containing the photo button and the registry
/// Calculations based on this values are made to ensure the button stays in that desired position, floating above the menu
/// Important notice: Button size needs to be smaller that min child size, otherwise an exception will be raised
///
/// maxChildSize - Max percentage of screen occupied by the menu (fully opened)
/// minChildSize - Minimum percentage of screen occupied by the menu (fully closed)
/// buttonSize - The size of the button
class HomeMenu extends StatefulWidget {
  HomeMenu(
      {Key key,
      this.maxChildSize = 0.8,
      this.minChildSize = 0.125,
      this.buttonSize = 0.119})
      : super(key: key);
  final maxChildSize;
  final minChildSize;
  final buttonSize;
  @override
  _HomeMenuState createState() => _HomeMenuState();
}

class _HomeMenuState extends State<HomeMenu> {
  /// Function to transform the value returned from draggable scrollable sheet to percentage of progress
  /// currVal - The current value of the interpolation
  /// z - The minimum value possible from the interpolation
  /// t - The maximum value possible from the interpolation
  /// Example: Assume value = 0.74, min = 0.2, max = 0.8
  /// ```dart
  /// double progressPercentage = normalize(value, min, max);
  /// ```
  double normalize(double currVal, double t, double z) {
    double m = 1 / (z - t);
    double b = -t / (z - t);
    var out = m * currVal + b;
    if (out < 0) {
      out = 0;
    } else if (out > 1) {
      out = 1;
    }
    return out;
  }

  ScrollController scrollController = ScrollController(initialScrollOffset: 0);
  @override
  Widget build(BuildContext context) {
    var scrHeight = MediaQuery.of(context).size.height;
    var scrWidth = MediaQuery.of(context).size.width;
    return Consumer<PictureProvider>(
      builder: (context, pictureProvider, child) {
        return Consumer<ScrollValue>(
          builder: (context, _scrollValue, child) {
            return DraggableScrollableSheet(
              initialChildSize: widget.minChildSize,
              maxChildSize: widget.maxChildSize,
              minChildSize: widget.minChildSize,
              builder: (BuildContext context, scrollController) {
                // Change the order, add after checking?
                // Only changing value when its only relevant
                // If we would set a value every frame, some widgets would rebuild every frame
                // This way is more efficient

                SchedulerBinding.instance.addPostFrameCallback((_) {
                  double temp = normalize(
                      scrollController.position.viewportDimension / scrHeight,
                      widget.minChildSize,
                      widget.maxChildSize);
                  if ((temp - _scrollValue.value).abs() > 0.05)
                    _scrollValue.value =
                        scrollController.hasClients ? temp : 1.0;
                  if (temp > 0.1) {
                    pictureProvider.closephoto();
                  } else {
                    pictureProvider.takePhoto();
                  }
                });

                return Stack(
                  children: [
                    ClipRRect(
                      /// Menu Clipper ensures that the button is floating in the center of the top of the scrollable sheet
                      clipper: MenuClipper(
                          offset: widget.buttonSize / 2 * scrHeight),
                      child: Center(
                        child: AnimatedContainer(
                          /// the "?" ocores once the container goes down
                          /// and the ":" the other way around
                          width: _scrollValue.value < 0.25 ? 100 : scrWidth,
                          height: _scrollValue.value < 0.25 ? 100 : scrHeight,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: _scrollValue.value < 0.25
                                ? BorderRadius.circular(50)
                                : BorderRadius.only(
                                    topLeft: Radius.circular(50),
                                    topRight: Radius.circular(50),
                                  ),
                          ),
                          duration: _scrollValue.value < 0.25
                              ? Duration(milliseconds: 500)
                              : Duration(milliseconds: 300),
                          curve: Curves.easeInQuad,
                        ),
                      ),
                    ),
                    Container(
                      child: ScrollConfiguration(
                        behavior: NoGlowScroll(),
                        child: ListView(
                          padding: EdgeInsets.all(0),
                          controller: scrollController,
                          children: [
                            CTTButton(
                              buttonSize: widget.buttonSize,
                            ),

                            /// Some math to ensure the ui is working as intended
                            SizedBox(
                              height:
                                  (widget.minChildSize - widget.buttonSize) *
                                      scrHeight,
                            ),
                            Padding(
                              padding: EdgeInsets.only(
                                left: 0.1 * scrWidth,
                                right: 0.1 * scrWidth,
                                top: 0.015 * scrHeight,
                              ),
                              child: Center(
                                child: AnimatedContainer(
                                  width: _scrollValue.value < 0.25
                                      ? 0
                                      : 0.8 * scrWidth,
                                  height: _scrollValue.value < 0.25
                                      ? 0
                                      : 0.64 * scrHeight,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(0),
                                    ),
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        offset: Offset(0, 2),
                                        blurRadius: 10,
                                        color: Color.fromRGBO(0, 0, 0, 0.3),
                                      ),
                                    ],
                                  ),
                                  child: _scrollValue.value < 0.25
                                      ? Container()
                                      : Padding(
                                          padding: EdgeInsets.only(
                                            top: 15,
                                          ),
                                          child: _scrollValue.value < 0.2
                                              ? ListView()

                                              /// Column containing the title of the menu and the List View of Scans saved
                                              : Column(
                                                  children: [
                                                    Padding(
                                                      padding: const EdgeInsets
                                                              .fromLTRB(
                                                          15, 0, 15, 0),
                                                      child:
                                                          _scrollValue.value <
                                                                  0.35
                                                              ? Container()
                                                              : Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    HelpButton(
                                                                        size:
                                                                            28),
                                                                    Text(
                                                                      "My Records",
                                                                      style:
                                                                          TextStyle(
                                                                        fontFamily:
                                                                            'Roboto',
                                                                        fontSize:
                                                                            20,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                        color: Colors
                                                                            .black,
                                                                        decoration:
                                                                            TextDecoration.none,
                                                                      ),
                                                                    ),
                                                                    ImagePickerButton(
                                                                        size:
                                                                            28)
                                                                  ],
                                                                ),
                                                    ),

                                                    /// If the menu is visible, scans saved are shown
                                                    _scrollValue.value < 0.35
                                                        ? AnimatedContainer(
                                                            duration: Duration(
                                                                milliseconds:
                                                                    500),
                                                            curve: Curves
                                                                .easeInQuad,
                                                          )
                                                        : AnimatedContainer(
                                                            child:
                                                                HistoryItemsListView(),
                                                            duration: Duration(
                                                                milliseconds:
                                                                    500),
                                                            curve: Curves
                                                                .easeInQuad,
                                                          ),
                                                  ],
                                                ),
                                        ),
                                  duration: _scrollValue.value < 0.35
                                      ? Duration(milliseconds: 200)
                                      : Duration(milliseconds: 200),
                                  curve: Curves.ease,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

/// Image Picker Buttons lts you choose a photo from gallery and analyse it
class ImagePickerButton extends StatelessWidget {
  ImagePickerButton({Key key, this.size});

  final picker = ImagePicker();

  /// Function to get the image from the gallery and starts computing the result
  /// If successfull, the information will be shown
  /// If the image cant be read, a popup will appear stating no code was found
  Future getImage(BuildContext context) async {
    var pickedFile = await picker.getImage(source: ImageSource.gallery);
    String filePath;
    if (pickedFile != null) {
      filePath = pickedFile.path;

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.red,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 4,
                ),
              ),
              backgroundColor: Colors.white.withOpacity(0),
            );
          });

      //await jpegtopng(filePath);
      compute(decodeScan, filePath).then((value) {
        Navigator.pop(context);
        print(value);
        if (value == null) {
          Toast.show(
            "No barcode found in this image",
            context,
            duration: 3,
            gravity: Toast.CENTER,
            backgroundRadius: 5,
            backgroundColor: Theme.of(context).primaryColor,
            textColor: Colors.white,
          );
        } else {
          Navigator.of(context).push(
            PageRouteBuilder(
                pageBuilder: (context, _, __) =>
                    DisplayForm(code: value, path: filePath),
                opaque: false),
          );
        }
      });
    }
  }

  final size;
  @override
  Widget build(BuildContext context) {
    return Consumer<PictureProvider>(
      builder: (context, _picprovider, child) {
        return GestureDetector(
          onTap: () {
            print("aa");
            getImage(context);
          },
          child: Icon(
            Icons.add_photo_alternate,
            color: Colors.black,
            size: 28,
          ),
        );
      },
    );
  }
}

/// Help Button
/// This contains extra information on how to use the app, including the directory where the photos are saved
class HelpButton extends StatelessWidget {
  HelpButton({Key key, this.size});
  final size;
  @override
  Widget build(BuildContext context) {
    return Consumer<PictureProvider>(
      builder: (context, _picprovider, child) {
        return GestureDetector(
          onTap: () => showGeneralDialog(
              barrierColor: Colors.black.withOpacity(0.5),
              transitionBuilder: (context, a1, a2, widget) {
                final curvedValue =
                    Curves.easeInOutBack.transform(a1.value) - 1.0;
                return Transform(
                  transform:
                      Matrix4.translationValues(0.0, curvedValue * 200, 0.0),
                  child: Opacity(
                    opacity: a1.value,
                    child: AlertDialog(
                      content: SingleChildScrollView(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    "Welcome to the Help/About Section!",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Icon(
                                    Icons.close,
                                    size: 45,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 15,
                            ),
                            RichText(
                              text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 17.5,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    TextSpan(
                                        text:
                                            "Overall the app is made from two screens: "),
                                  ]),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            RichText(
                              text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 17.5,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    TextSpan(
                                        text:
                                            " *  The main screen contains the camera and all the magic of collecting the images happens there.Pulling it up reveals the next screen."),
                                  ]),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            RichText(
                              text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 17.5,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    TextSpan(
                                      text:
                                          " *  The management screen contains all the information that is read from the image and there is organized in dates for easy consulting and work optimization. Inside it you see all your scans (is empty until it has a scan), on the right you find a button that allows the possibility to add a image from the gallery to be decoded and of course at last you find the help button to open this window and assist you!",
                                    ),
                                  ]),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            RichText(
                              text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 17.5,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    TextSpan(
                                      text:
                                          "* The images are currently stored in:",
                                    ),
                                  ]),
                            ),
                            RichText(
                              text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: DIR,
                                    ),
                                  ]),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            RichText(
                              text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 17.5,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    TextSpan(text: "Hope we have helped!"),
                                  ]),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            RichText(
                              text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 17.5,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    TextSpan(
                                        text:
                                            "Barcode Companion is brought to you by #ZAANG! team."),
                                  ]),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
              transitionDuration: Duration(milliseconds: 200),
              barrierDismissible: true,
              barrierLabel: '',
              context: context,
              pageBuilder: (context, animation1, animation2) {}),
          child: Icon(
            Icons.help_outline,
            color: Colors.black,
            size: 28,
          ),
        );
      },
    );
  }
}

/// Clipper used to ensure the button floats centered on the top of the menu
/// Aproach to menu explained:
///   Use a stack to place widgets on top of each other
///   Use a transparent container to set the height of the stack and contain elements (to allow drag)
///   Use a white container (for ui only) that is visually clipped to have rounded borders and be half the button height smaller to make it appear floating
/// Offset is the distance from the top position of the parent widget
/// For the button to appear floating, offset should be buttonSize / 2 * scrHeight
/// Example:
/// ```dart
/// ClipRRect(
///   clipper: MenuClipper(offset: widget.buttonSize / 2 * scrHeight),
///   child: Container(
///   // Extra code
///   ),
/// )
/// ```
class MenuClipper extends CustomClipper<RRect> {
  MenuClipper({Key key, this.offset});

  final offset;

  @override
  RRect getClip(Size size) {
    RRect rect = RRect.fromLTRBAndCorners(
      0.0,
      offset,
      size.width,
      size.height,
      topLeft: Radius.circular(50),
      topRight: Radius.circular(50),
    );
    return rect;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return true;
  }
}

/// The button used in the menu, jumping between the ctt logo and a camera icon
/// Allows to take a picture when the button is the camera icon
/// buttonSize - The button size in screen percentage, from 0 to 1
/// To call this, simply
/// ```dart
/// CTTButton(buttonSize: 0.1)
/// ```
class CTTButton extends StatefulWidget {
  CTTButton({Key key, this.buttonSize}) : super(key: key);

  final buttonSize;

  _CTTButtonState createState() => _CTTButtonState();
}

class _CTTButtonState extends State<CTTButton>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation<double> _animation;
  AnimationStatus _animationStatus = AnimationStatus.dismissed;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    _animation = Tween<double>(end: 1, begin: 0).animate(_animationController)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        _animationStatus = status;
      });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ScrollValue>(
      builder: (context, _scrollValue, child) {
        return IgnorePointer(
          ignoring: false,
          child: Transform(
            alignment: FractionalOffset.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.002)
              ..rotateX(pi * _animation.value),
            child: Consumer<PictureProvider>(
              builder: (context, _popupwindow, child) {
                if (_scrollValue.value < 0.05) {
                  _animationController.forward();
                } else {
                  _animationController.reverse();
                }
                return GestureDetector(
                  onTap: () => {
                    if (_scrollValue.value < 0.05) {_popupwindow.takePhoto()}
                  },
                  child: _animation.value >= 0.5
                      ? Container(
                          width: widget.buttonSize *
                              MediaQuery.of(context).size.height,
                          height: widget.buttonSize *
                              MediaQuery.of(context).size.height,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              alignment: Alignment.topCenter,
                              image:
                                  Image.asset("assets/images/camera-icon.png")
                                      .image,
                            ),
                            shape: BoxShape.circle,
                          ),
                        )
                      : Container(
                          width: widget.buttonSize *
                              MediaQuery.of(context).size.height,
                          height: widget.buttonSize *
                              MediaQuery.of(context).size.height,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              alignment: Alignment.topCenter,
                              image: Image.asset("assets/images/logo-ctt.png")
                                  .image,
                            ),
                            shape: BoxShape.circle,
                          ),
                        ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

/// To be used with scrollable widgets like ListViews and SingleChildScrollView to remove android prefab glow from dragging lists
/// Example:
/// ```dart
/// ScrollConfiguration(
///   behavior: NoGlowScroll(),
///     child: ListView(
///       // Extra code
///     ),
///   ),
/// )
/// ```
class NoGlowScroll extends ScrollBehavior {
  @override
  Widget buildViewportChrome(
      BuildContext context, Widget child, AxisDirection axisDirection) {
    return child;
  }
}
