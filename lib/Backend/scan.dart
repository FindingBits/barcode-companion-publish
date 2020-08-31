/// The class scan contains the information of a scan
/// It's used to save things to the database and to create elements in the UI
/// You can acess the information by calling
/// Important distinction betwen code and FDAT code
/// The class must be initialized with all of the parameters, to be called after a sucessfull scan
/// FDAT code - Code in Full, descender, ascender, tracker mode
/// Code - S18C decoded FDAT code
/// ```dart
///  getDesiredProperty
/// ```
/// For example
/// ```dart
///  exampleScan.getID
///  // Or
///  exampleScan.getFDATcode
///  // Or
///  exampleScan.getName
class Scan {
  final int id;
  final String name;
  final String date;
  final String code;
  final String description;
  final String path;
  String issuerCode = "";
  String eqID;
  String itemPriority;
  String serialNumber;
  String trackID;

  Scan(
      {this.id, this.name, this.date, this.code, this.description, this.path, this.issuerCode, this.eqID, this.itemPriority, this.serialNumber, this.trackID}) {

  }

  /// Converts the scan to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'date': date,
      'code': code,
      'description': description,
      'path': path,
      'issuerCode': issuerCode,
      'eqID': eqID,
      'itemPriority': itemPriority,
      'serialNumber': serialNumber,
      'trackID': trackID,
    };
  }

  get getID => id;
  get getName => name;
  get getDate => date;
  get getCode => code;
  get getDescription => description;
  get getPath => path;
  get getIssuerCode => issuerCode;
  get getItemPriority => itemPriority;
  get getserialNumber => serialNumber;
  get gettrackID => trackID;

  /// Converts the scan to a string to be added to the database (sqlite)
  //String toString() {
    //return 'Scan{id: $id, name: $name, date: $date, code:$code,description:$description,path:$path}, issuerCode:${issuerCode},';
  //}
}
