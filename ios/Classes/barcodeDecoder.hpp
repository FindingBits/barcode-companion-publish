#pragma once

// Custom exception
// 1 -> Division by zero
// 2 -> Too many errors to correct
// 3 -> Too many erasures to correct
// 4 -> Could not correct errata
// 5 -> Barcode size is wrong
// 6 -> Unknown Prefix
// 7 -> Barcode not found
struct OutputFormat
{
	int errnum;
	char* output;
};

extern "C"
struct OutputFormat * barcodeDecoderF(char* barcodePointer);