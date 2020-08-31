import 'dart:ffi'; // For FFI
import 'dart:io' show Platform; // For Platform.isX
import 'package:ffi/ffi.dart';

class OutputFormat extends Struct {
  @Int32()
  int errnum;

  Pointer<Utf8> output;
  Pointer<Utf8> barcode;

  factory OutputFormat.allocate(int errnum, Pointer<Utf8> output, Pointer<Utf8> barcode) =>
      allocate<OutputFormat>().ref
        ..errnum = errnum
        ..output = output
        ..barcode = barcode;
}

final DynamicLibrary barcodeDecoderLib = Platform.isAndroid
    ? DynamicLibrary.open("libbarcodeDecoder.so")
    : DynamicLibrary.process();

final Pointer<OutputFormat> Function(Pointer<Utf8>) barcodeDecoder =
    barcodeDecoderLib
        .lookup<NativeFunction<Pointer<OutputFormat> Function(Pointer<Utf8>)>>(
            "barcodeDecoderF")
        .asFunction();

final DynamicLibrary barcodeScanningLib = Platform.isAndroid
    ? DynamicLibrary.open("libbarcodeScanning.so")
    : DynamicLibrary.process();

final Pointer<OutputFormat> Function(Pointer<Uint8>, int) barcodeScan =
    barcodeScanningLib
        .lookup<
            NativeFunction<
                Pointer<OutputFormat> Function(Pointer<Uint8>, Int32)>>("scan")
        .asFunction();
