import 'dart:io';

import 'package:barcode_companion/Backend/scan.dart';
import 'package:barcode_companion/UI/Provider/PictureProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform; // For Platform.isX

import '../../Backend/history_manager.dart';
import 'CameraApp.dart';

/// This widget provides information about the image like FDAT code and decoded information
/// Also asks for important information to store the data like a name and an optional description
class DisplayForm extends StatefulWidget {
  final code;
  final path;
  DisplayForm({Key key, this.code, this.path}) : super(key: key);
  _DisplayFormState createState() => _DisplayFormState();
}

class _DisplayFormState extends State<DisplayForm> {
  ///Main contollers of the form
  DateTime selectedDate = DateTime.now();
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  /// Function to save the scan
  _save(HistoryManager _historyManager, PictureProvider pictureProvider) async {
    String date = ("${selectedDate.toLocal()}".split(' ')[0]);
    Directory directory;

    if (Platform.isAndroid) {
      directory = await getExternalStorageDirectory();
    } else {
      directory = await getApplicationDocumentsDirectory();
    }
    String path = directory.path;
    DateTime now = DateTime.now();
    String name = nameController.text;
    String issuerCode = widget.code.substring(4, 7);
    String eqID = widget.code.substring(7, 10);
    String itemPriority = widget.code[10];
    String serialNumber = widget.code.substring(11, 23);
    String trackID = widget.code[23];

    /// Saving the image to a permanent location
    File newImage = await File(widget.path).copy('$path/$name$now.png');
    Directory(widget.path).deleteSync(recursive: true);
    var scan = Scan(
      name: nameController.text,
      date: date,
      code: widget.code,
      description: descriptionController.text,
      path: newImage.path,
      fdatcode: " ----- ",
      issuerCode: issuerCode,
      eqID: eqID,
      itemPriority: itemPriority,
      serialNumber: serialNumber,
      trackID: trackID,
    );
    _historyManager.addItem(scan);
    pictureProvider.working = false;
    pictureProvider.takePhoto();
  }

  @override
  Widget build(BuildContext context) {
    String date = ("${selectedDate.toLocal()}".split(' ')[0]);
    return AlertDialog(
      title: Text('Additional Data'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  /// The forms to retrieve and show information
                  TextFormField(
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(18),
                    ],
                    autofocus: true,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.description),
                      hintText: 'Name',
                    ),
                    controller: nameController,
                    validator: (value) {
                      if (value.isEmpty) {
                        return 'Please enter some text';
                      }
                      return null;
                    },
                  ),
                  new TextField(
                    readOnly: true,
                    decoration: new InputDecoration(
                      icon: Icon(Icons.today),
                      hintText: date,
                    ),
                  ),

                  new TextFormField(
                    readOnly: true,
                    decoration: new InputDecoration(
                      icon: Icon(Icons.view_week),
                      hintText: widget.code,
                    ),
                  ),
                  new TextFormField(
                    autofocus: true,
                    decoration: const InputDecoration(
                      icon: Icon(Icons.description),
                      hintText: 'Small Description',
                    ),
                    controller: descriptionController,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        Consumer<PictureProvider>(builder: (context, pictureProvider, child) {
          return Consumer<HistoryManager>(
            builder: (context, _history, child) {
              return FlatButton(
                child: Text('Save'),
                onPressed: () {
                  if (_formKey.currentState.validate()) {
                    _save(_history, pictureProvider);
                    Navigator.of(context).pop();
                  }
                },
              );
            },
          );
        }),
        Consumer<PictureProvider>(
          builder: (context, pictureProvider, child) {
            return FlatButton(
              child: Text('Exit'),
              onPressed: () {
                pictureProvider.working = false;
                pictureProvider.takePhoto();
                Navigator.of(context).pop();
              },
            );
          },
        ),
      ],
    );
  }
}
