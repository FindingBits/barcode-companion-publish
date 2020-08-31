import 'package:barcode_companion/UI/Provider/PictureProvider.dart';
import 'package:barcode_companion/UI/History/history_item_window.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:barcode_companion/Backend/scan.dart';
import 'package:barcode_companion/Backend/history_manager.dart';

/// Widget that shows the list of scans saved
/// To use it, simply use
/// ```dart
/// HistoryItemsListView()
/// ```
/// Consumer<HistoryManager> ensures that the information shown in the widget is always up-to-date
/// Every time there is a change in the history (add, deletion, etc), this widget is rebuilt
class HistoryItemsListView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryManager>(
      builder: (context, _histManager, child) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 10, right: 10, top: 20),
            child: ListView.builder(
              itemCount: _histManager.length,
              itemBuilder: (context, i) {
                Scan data = _histManager.getItem(i);
                return Column(
                  children: [
                    SizedBox(height: 10),

                    /// Adding a text with the date if the dates between two items are different
                    (i == 0 ||
                            _histManager.getItem(i - 1).getDate != data.getDate)
                        ? DateText(data: data.getDate)
                        : Container(width: 0, height: 0),

                    /// Adding some spacing
                    (i == 0 ||
                            _histManager.getItem(i - 1).getDate != data.getDate)
                        ? SizedBox(height: 20)
                        : Container(width: 0, height: 0),

                    /// Finnally adding the item itself
                    MenuHistoryItem(
                      data: data,
                    ),
                    SizedBox(height: 5),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class InformationButton extends StatelessWidget {
  InformationButton({Key key, this.size, this.data});
  final size;
  final data;
  @override
  Widget build(BuildContext context) {
    return Consumer<PictureProvider>(
      builder: (context, _picprovider, child) {
        double scrWidth = MediaQuery.of(context).size.width;
        double scrHeight = MediaQuery.of(context).size.height;
        return GestureDetector(
          onTap: () => showGeneralDialog(
              barrierColor: Color(0x01000000),
              transitionBuilder: (context, a1, a2, widget) {
                return Transform.scale(
                  scale: a1.value,
                  child: Opacity(
                      opacity: a1.value,
                      child: HistoryItemWindow(
                        data: data,
                      )),
                );
              },
              transitionDuration: Duration(milliseconds: 200),
              barrierDismissible: true,
              barrierLabel: '',
              context: context,
              pageBuilder: (context, animation1, animation2) {}),
          child: Icon(
            Icons.more_horiz,
            color: Colors.black,
            size: 28,
          ),
        );
      },
    );
  }
}

/// Simple widget to show the date of the category
/// data - Date

class DateText extends StatelessWidget {
  DateText({Key key, this.data});
  final String data;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 1,
          width: 20,
          color: Colors.black,
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(0),
            ),
            color: Colors.white,
          ),
          child: Text(
            "  " + data + "  ",
            style: TextStyle(
              fontFamily: "Roboto",
              fontSize: 25,
              decoration: TextDecoration.none,
              color: Colors.black,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        Container(
          height: 1,
          width: 20,
          color: Colors.black,
        ),
      ],
    );
  }
}

/// Widget that shows a small info about the scan saved
/// By clicking on it, HistoryItemWindow is called, showing the whole information about the scan
/// Example
/// ```dart
/// MenuHistoryItem(data: currScan)
/// ```
class MenuHistoryItem extends StatelessWidget {
  MenuHistoryItem({Key key, this.data});
  final Scan data;
  @override
  Widget build(BuildContext context) {
    var scrHeight = MediaQuery.of(context).size.height;
    var scrWidth = MediaQuery.of(context).size.width;
    return Consumer<PictureProvider>(
      builder: (context, _window, child) {
        return GestureDetector(
          child: Padding(
            padding: const EdgeInsets.all(5),
            child: Container(
              width: scrWidth,
              height: scrHeight / 11,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                  Radius.circular(0),
                ),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, 1),
                    blurRadius: 5,
                    color: Color.fromRGBO(0, 0, 0, 0.3),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: Container(
                      child: Text(
                        data.getName,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: "Roboto",
                          fontSize: 22,
                          color: Colors.black,
                          fontWeight: FontWeight.w500,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 15, 0),
                    child: InformationButton(
                      size: 28,
                      data: data,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
