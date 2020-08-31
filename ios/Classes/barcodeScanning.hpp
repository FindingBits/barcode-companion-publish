#pragma once

#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#endif

extern "C"
struct OutputFormat * scan(uint8_t* imageIn, int length);