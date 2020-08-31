import 'dart:io';

import 'package:barcode_companion/Backend/history_manager.dart';
import 'package:barcode_companion/UI/Provider/PictureProvider.dart';
import 'package:barcode_companion/Backend/scan.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'package:flutter/services.dart';

/// History Item Window is the popup that appears when you select a registry
/// Needs to be passed a data element, being this the Scan that needs to be shown
/// Example on how to call this:
/// This version allows to have a transparent background
/// ```dart
/// onTap: () => Navigator.of(context).push(
///                PageRouteBuilder(
///                 pageBuilder: (context, _, __) => HistoryItemWindow(data: someScan),
///             opaque: false)
/// ```
///
/// Other simpler solution
/// ```dart
/// onTap: () => showDialog(
///    context: context,
///    builder: (BuildContext context) {
///      return HistoryItemWindow(data: someScan);
///    }
///
/// ```
///
///
class HistoryItemWindow extends StatelessWidget {
  HistoryItemWindow({Key key, this.data});

  final Scan data;

  @override
  Widget build(BuildContext context) {
    double scrWidth = MediaQuery.of(context).size.width;
    double scrHeight = MediaQuery.of(context).size.height;
    return AlertDialog(
      contentPadding: EdgeInsets.all(0),
      backgroundColor: Color.fromRGBO(0, 0, 0, 0),
      content: Consumer<PictureProvider>(
        builder: (context, _window, child) {
          return Center(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(2),
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
              height: 0.8 * scrHeight,
              width: 0.8 * scrWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 25, left: 25, right: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        /// Name of the file as the title
                        Expanded(
                          child: Text(
                            data.getName,
                            style: TextStyle(
                              fontFamily: "Roboto",
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                              decoration: TextDecoration.none,
                            ),
                          ),
                        ),

                        /// An exit button
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Icon(
                            Icons.close,
                            size: 45,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(25),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Setting the width of the column to be the same as the parent
                            SizedBox(
                              width: double.infinity,
                            ),

                            /// Stating the date of the scan
                            ///
                            Row(
                              children: [
                                RichText(
                                  text: TextSpan(
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      children: [
                                        TextSpan(text: "Date: "),
                                      ]),
                                ),
                                RichText(
                                  text: TextSpan(
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.black,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: data.getDate,
                                        ),
                                      ]),
                                ),
                              ],
                            ),
                            data.getDescription != ""
                                ? SizedBox(
                                    height: 10,
                                  )
                                : Container(),

                            data.getDescription != ""
                                ? RichText(
                                    text: TextSpan(
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black,
                                        ),
                                        children: [
                                          TextSpan(text: "Description: "),
                                        ]),
                                  )
                                : Container(),
                            data.getDescription != ""
                                ? SizedBox(
                                    height: 5,
                                  )
                                : Container(),
                            data.getDescription != ""
                                ? RichText(
                                    text: TextSpan(
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                        children: [
                                          TextSpan(text: data.getDescription),
                                        ]),
                                  )
                                : Container(),
                            SizedBox(
                              height: 10,
                            ),
                            RichText(
                              text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    TextSpan(text: "FDAT extracted code: "),
                                  ]),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            RichText(
                              text: TextSpan(
                                  style: TextStyle(
                                    fontFamily:  "Roboto-Mono",
                                    fontSize: 12,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: data.fdatcode,
                                    ),
                                  ]),
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            RichText(
                              text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    TextSpan(text: "Decoded code: "),
                                  ]),
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            GestureDetector(
                              onTap: () {
                                Clipboard.setData(new ClipboardData(text: data.getCode));
                                Toast.show("Code copied to clipboard", context, duration: 3, gravity:  Toast.CENTER);

                              },
                              child: RichText(
                                text: TextSpan(
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: data.getCode,
                                      ),
                                    ]),
                              ),
                            ),

                            SizedBox(
                              height: 10,
                            ),

                            RichText(
                              text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    TextSpan(text: "Issuer Code: "),
                                  ]),
                            ),
                            RichText(
                              text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: data.issuerCode,
                                    ),
                                  ]),
                            ),
                            SizedBox(
                              width: 20,
                            ),
                            RichText(
                              text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    TextSpan(text: "Equipment ID: "),
                                  ]),
                            ),
                            RichText(
                              text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: data.eqID,
                                    ),
                                  ]),
                            ),

                            RichText(
                              text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    TextSpan(text: "Item Priority: "),
                                  ]),
                            ),
                            RichText(
                              text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: data.itemPriority,
                                    ),
                                  ]),
                            ),
                            SizedBox(
                              width: 35,
                            ),
                            RichText(
                              text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    TextSpan(text: "Track ID: "),
                                  ]),
                            ),
                            RichText(
                              text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: data.trackID,
                                    ),
                                  ]),
                            ),

                            SizedBox(
                              height: 10,
                            ),
                            
                                RichText(
                                  text: TextSpan(
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      children: [
                                        TextSpan(text: "Serial Number: "),
                                      ]),
                                ),
                                RichText(
                                  text: TextSpan(
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.black,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: data.serialNumber,
                                        ),
                                      ]),
                                ),
                             
                            SizedBox(
                              height: 10,
                            ),

                            /// Files section text
                            RichText(
                              text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  children: [
                                    TextSpan(text: "Scan: "),
                                  ]),
                            ),

                            SizedBox(height: 10),

                            /// The image associated to the scan
                            Container(
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20))),
                              child: File(data.getPath).existsSync()
                                  ? Image.file(
                                      File(data.getPath),
                                    )
                                  : Container(),
                            )
                            //insert image
                          ],
                        ),
                      ),
                    ),
                  ),

                  /// Button to delete the scan
                  Consumer<HistoryManager>(
                    builder: (context, _history, child) {
                      return GestureDetector(
                        onTap: () {
                          // Removing the item from the manager
                          _history.removeItem(data);
                          // Closing the item window
                          Navigator.pop(context);
                        },
                        child: Container(
                          child: Padding(
                            padding: EdgeInsets.only(bottom: 25),
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                width: 0.3 * scrWidth,
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Center(
                                    child: Text(
                                      "Delete",
                                      style: TextStyle(
                                        fontFamily: "Roboto",
                                        color: Colors.white,
                                        fontWeight: FontWeight.w400,
                                        decoration: TextDecoration.none,
                                        fontSize: 20,
                                      ),
                                    ),
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
