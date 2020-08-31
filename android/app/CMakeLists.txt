cmake_minimum_required(VERSION 3.4.1)  # for example





set(OPENCV_BASE_DIR "../../ios/Flutter/OpenCV-android-sdk")


set(OPENCV_INCLUDE_DIR "${OPENCV_BASE_DIR}/sdk/native/jni/include/")
set(OPENCV_JNI_DIR "${OPENCV_BASE_DIR}/sdk/native/jni/")
set(OPENCV_STATIC_LIB_DIR "${OPENCV_BASE_DIR}/sdk/native/staticlibs/${ANDROID_ABI}")
set(OPENCV_3RDPARTY_STATIC_LIB_DIR "${OPENCV_BASE_DIR}/sdk/native/3rdparty/libs/${ANDROID_ABI}")

include_directories(${OPENCV_INCLUDE_DIR})
include_directories(${OPENCV_JNI_DIR})

find_library(log-lib log)
find_package(OpenCV 4.4.0 REQUIRED java)


include(AndroidNdkModules)
android_ndk_import_module_cpufeatures()

set(CMAKE_THREAD_PREFER_PTHREAD TRUE)
set(THREADS_PREFER_PTHREAD_FLAG TRUE)
find_package(Threads REQUIRED)

#add_library(tbb STATIC IMPORTED)
#set_target_properties(tbb PROPERTIES IMPORTED_LOCATION ${OPENCV_3RDPARTY_STATIC_LIB_DIR}/libtbb.a)


#add_library(tegra_hal STATIC IMPORTED)
#set_target_properties(tegra_hal PROPERTIES IMPORTED_LOCATION ${OPENCV_3RDPARTY_STATIC_LIB_DIR}/libtegra_hal.a)



#add_library(ittnotify STATIC IMPORTED)
#set_target_properties(ittnotify PROPERTIES IMPORTED_LOCATION ${OPENCV_3RDPARTY_STATIC_LIB_DIR}/libittnotify.a)







add_library( barcodeDecoder

             # Sets the library as a shared library.
             SHARED

             # Provides a relative path to your source file(s).
             ../../ios/Classes/barcodeDecoder.cpp
             ../../ios/Classes/barcodeDecoder.def )

set_target_properties(barcodeDecoder PROPERTIES
    PUBLIC_HEADER ../../ios/Classes/barcodeDecoder.hpp
    SOVERSION 1
    XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "Hex_Identity_ID_Goes_Here"
)


add_library( barcodeScanning

             # Sets the library as a shared library.
             SHARED

             # Provides a relative path to your source file(s).
             ../../ios/Classes/barcodeScanning.cpp
             ../../ios/Classes/barcodeScanning.def )

set_target_properties(barcodeScanning PROPERTIES
    PUBLIC_HEADER ../../ios/Classes/barcodeScanning.hpp
    SOVERSION 1
    
    XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY "Hex_Identity_ID_Goes_Here"
)

target_link_libraries(barcodeScanning ${OpenCV_LIBRARIES} barcodeDecoder)