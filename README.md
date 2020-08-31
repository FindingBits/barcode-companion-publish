# barcode-companion
The App to read Barcodes from the S18C standard

## Setting up project
* Download and install [Flutter for your OS](https://flutter.dev/docs/get-started/install)
* Clone the repository

### Android
* Works in macOS, windows and linux
* Download [Open CV for Android](https://opencv.org/releases/)
* Unzip the folder to the project folder ios/Flutter making sure the folder name remains ```OpenCV-android-sdk```
* ![Example here](https://i.imgur.com/Z2hQe1a.png)
* Connect your emulator or phone and start debugging. Some artifacts will be downloaded from the web to compile the code, so make sure there is an internet connection available.

### iOS
* To compile to iOS, macOS is needed
* Download [Open CV for iOS](https://opencv.org/releases/)
* Move the folder to the project folder ios/Flutter making sure the folder name remains ```opencv2.framework```
* Connect your emulator or phone and start debugging. Some artifacts will be downloaded from the web to compile the code, so make sure there is an internet connection available.
* Using Xcode to build is advisable.
* If an error occurs saying that the app was not trusted, on the iOS phone or emulator go to Settings > General > Profiles or Profiles & Device Management and tap the item related to Barcode Companion. Then tap Trust.
### Note
* You can work both for android or ios (in mac) if both steps are followed

## Project Documentation

### - Source Decode and Documentation
* [Source Code with Docs](https://github.com/FrancesinhaMan/barcode-companion-publish/tree/master/source-decode-withDocs) (differs a bit from mobile implementation of cpp but its designed to be run from the computer for better understanding our logic).

### - UPU Standards
* [All sections](https://www.upu.int/en/Postal-Solutions/Programmes-Services/Standards#scroll-nav__6)



## Project Technologies


### UI - Flutter
[Flutter](https://flutter.dev/) is an open source dart framework, backed by Google, that allows to build cross platform applications for iOS, Android and web (currently in beta).

The advantages of this framework is that it's fast, beautiful and the application doesn't use native widgets, which means the design of your application will be the same among all platforms.
 
Besides all this, it's easy to setupand has great documentation and support. One small flaw is that for the developer to be able to compile to iOS, macOS is needed (due to restrictions by Apple).


### Reed-Solomon
To achieve the best scanning results, the app contains the Reed-Solomon algorithms to solve errors on a possibly damaged code and consequently maintaining its original form even if its not available. We studied deeply all the math behind it. We had a lot of help from [wikipedia](https://en.wikipedia.org/wiki/Reed%E2%80%93Solomon_error_correction) on this subject.
* All the functions on the cpp code regarding this subject have their own documentation for better understanding our logic.

### Image Recognition
For image recognition we decided to use OpenCV, an open source and very powerfull library. For this particular usage we decided to go with c++ because it was easier to link with flutter with dart:ffi. A PC version  is within [this folder](https://github.com/FrancesinhaMan/barcode-companion-publish/tree/master/source-decode-withDocs)

The objective of this phase is to translate the image into a FDAT code (full, descender, ascender, tracker), to be later used with reed solomon to decode it into an s18c code.

During these phase, there are crucial steps.
#### Important steps:
* Converting the original image to grayscale
* Correct illumination differences
* Modify the image to a black and white, to be easier for the algorithms to detect edges.
* Finding possible barcodes:
	* Blur the image significantly so the lines of the barcode merge together.
	* Detect contours around the center of the image
	* Cropping the image around those contours detected
* Analysing the possible contours:
	* Using some Gaussian blur to erase garbage
	* Finding contours
	* Removing outliers, from zscores of the widht, or heights too small
	* Removing duplicate bars
	* Adding "unrecognized" bars into missing spaces
* Finnally the FDAT with some possible unrecognized values is sent to the reed solomon algorithm which will fix errors and decode it into s18c.


## The #ZAANG! team
  * [(@FrancesinhaMan) João Guedes](https://github.com/FrancesinhaMan)
  * [(@InsertNamePls) José Carvalho](https://github.com/InsertNamePls)
  * [(@DoStini) André Moreira](https://github.com/DoStini)
  * [(@Homailot) Nuno Alves](https://github.com/Homailot)
  * [(@AlvaroTorcato) Álvaro Torcato](https://github.com/AlvaroTorcato)
 
 
