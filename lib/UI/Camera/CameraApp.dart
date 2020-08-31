import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'package:barcode_companion/Backend/history_manager.dart';
import 'package:barcode_companion/UI/Camera/display_form.dart';
import 'package:camera/camera.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:barcode_companion/UI/Provider/PictureProvider.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:barcode_companion/Backend/scan.dart';
import 'package:barcode_companion/barcodeDecoder.dart';

import '../Provider/ScrollValue.dart';

jpegtopng(String path) async{
  img.Image image = img.decodeImage(File(path).readAsBytesSync());
  var newPath = join(
        (await getTemporaryDirectory()).path,
        '${DateTime.now()}.png',
      );
  File(newPath)..writeAsBytesSync(img.encodePng(image));
  
  return newPath;
}

decodeScan(String path) async {
  
  var imgBytes;
  try {
    imgBytes = await File(path).readAsBytes();
  } catch (e) {
    return;
  }

  Uint8List data = Uint8List.fromList(imgBytes);

  final Pointer<Uint8> frameData =
      allocate<Uint8>(count: data.length); // Allocate a pointer large enough.
  final pointerList = frameData.asTypedList(data.length);
  pointerList.setAll(0, data);
  var decodedPointer = barcodeScan(frameData, data.length);
  var decoded = decodedPointer.ref;
  //var message = decoded.errnum;
  if (decoded.errnum == 0){
    var message = Utf8.fromUtf8(decoded.output) + " " + Utf8.fromUtf8(decoded.barcode);
    return message;
  }else{
    return null;
  }
  
}

/// Widget that shows the camera preview
/// To be called when camera dependencies are loaded
/// cameras - The list of cameras available
class CameraScreen extends StatefulWidget {
  final List<CameraDescription> cameras;
  CameraScreen(this.cameras);

  @override
  CameraScreenState createState() {
    return new CameraScreenState();
  }
}

class CameraScreenState extends State<CameraScreen> {
  CameraController controller;
  Future<void> _initializeCameraControllerFuture;

  Future sendScan(PictureProvider pictureProvider) async {
    try {
      pictureProvider.working = true;

      await _initializeCameraControllerFuture;
      var path = join(
        (await getTemporaryDirectory()).path,
        '${DateTime.now()}.png',
      );

      await controller.takePicture(path);

      compute(decodeScan, path).then((value) {
        if (value == null) {
          Directory(path).deleteSync(recursive: true);
          pictureProvider.working = false;
          pictureProvider.takePhoto();
        } else {
          pictureProvider.closephoto();
          Navigator.of(context).push(
            PageRouteBuilder(
                pageBuilder: (context, _, __) =>
                    DisplayForm(code: value, path: path),
                opaque: false),
          );
        }
      });
    } catch (e) {

      Future.delayed(Duration(milliseconds: 1000)).then((_) {
        pictureProvider.working = false;
        pictureProvider.takePhoto();
      });
    }
  }

  ///Sets the camera Contoller and the resolution
  @override
  void initState() {
    super.initState();
    controller =
        new CameraController(widget.cameras[0], ResolutionPreset.ultraHigh);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  ///Creates the ambient for the camera and verifies if
  ///everything is correct
  @override
  Widget build(BuildContext context) {
    return Consumer<ScrollValue>(
      builder: (context, _scroll, child) {
        return Consumer<PictureProvider>(
          builder: (context, _window, child) {
            if (!_window.working && _window.takephoto && _scroll.value < 0.1) {
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                _window.working = true;
                sendScan(_window);
              });
            }
            return Stack(
              children: <Widget>[
                FutureBuilder(
                  future: _initializeCameraControllerFuture,
                  builder: (context, snapshot) {
                    if (controller.value.isInitialized) {
                      return CameraPreview(controller);
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
