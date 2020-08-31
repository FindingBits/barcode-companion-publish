
#include <iostream>
#include <vector>
#include <string>
#include <chrono>
#include <cmath>
#include <sstream>
#include "barcodeScanning.hpp"
#include "barcodeDecoder.hpp"

using namespace std::chrono;

using std::vector;

/*
	findCountours is a function to find the countours that might be the barcode
	@param grayscale - The grayscaled image
	@param result - The Rotated Rect containing the rectangles of possible barcodes
*/

void findCountours(cv::Mat &grayscale, vector<cv::RotatedRect> &result)
{
	cv::Mat th;

	int AUTO1 = 29,
		AUTO2 = 5,
		BLUR_LEVEL = 10,
		TH_MODE = 9,
		MIN_RATIO = 9,
		MAX_RATIO = 16;

	float CENTER_POINT_THRESHHOLD = 0.15;


	int resy = grayscale.size().width;
	int resx = grayscale.size().height;

	cv::Mat g0 = grayscale.clone();
	cv::Mat g1 = grayscale.clone();

	cv::GaussianBlur(g0, g0, cv::Size(89, 89), 3);
	cv::GaussianBlur(g1, g1, cv::Size(3, 3), 1);

	cv::subtract(g0, g1, th);
	cv::normalize(th, th, 0, 255, cv::NORM_MINMAX);

	cv::Mat white = cv::Mat(th.size(), CV_8UC1);
	white.setTo(cv::Scalar(255));
	cv::subtract(white, th, th);

	/*
	In order to find the barcode, we will blur
	the image quite a lot to disperse the bars
	and join them
	*/

	cv::GaussianBlur(th, th, cv::Size(25, 25), BLUR_LEVEL);

	cv::threshold(th, th, 0, 255, TH_MODE);

	vector<vector<cv::Point>> countours;

	// Center Rect - (y, x, w, h)
	// Open cv understands coordinates in a weird way

	vector<int> centerRect{
		int(resy / 2 - CENTER_POINT_THRESHHOLD * resy),
		int(resx / 2 - CENTER_POINT_THRESHHOLD * resx),
		int(CENTER_POINT_THRESHHOLD * 2 * resy),
		int(CENTER_POINT_THRESHHOLD * 2 * resx)};

	cv::findContours(th, countours, cv::RETR_EXTERNAL, cv::CHAIN_APPROX_SIMPLE);

	for (auto &cnt : countours)
	{

		cv::RotatedRect outCnt = cv::minAreaRect(cnt);

		// Not even god knows why x and y are switched, but it works

		if ( //outCnt.size.height * MIN_RATIO <= outCnt.size.width &&
			//outCnt.size.height * MAX_RATIO >= outCnt.size.width &&

			outCnt.center.x > centerRect[0] && outCnt.center.x < centerRect[0] + centerRect[2] &&
			outCnt.center.y > centerRect[1] && outCnt.center.y < centerRect[1] + centerRect[3])
		{
			result.push_back(outCnt);
		}
	}
}

/*
	Function to retrieve possible codes in their own image
	@param grayscale - The grayscaled image
	@param result - Vector of new cropped images
*/

void cut(cv::Mat &grayscale, vector<cv::Mat> &result)
{
	vector<cv::RotatedRect> countours;

	findCountours(grayscale, countours);

	for (auto &cnt : countours)
	{

		cv::Mat out, M;

		int width = cnt.size.width;
		int height = cnt.size.height;

		float angle = cnt.angle;

		if (angle < -45.)
		{
			angle += 90.0;
			int temp;
			temp = width;
			width = height;
			height = temp;
		}

		M = cv::getRotationMatrix2D(cnt.center, angle, 1.0);

		// Rotating
		cv::warpAffine(grayscale, out, M, grayscale.size(), cv::INTER_CUBIC);

		// Cropping
		cv::getRectSubPix(out, cv::Size(width, height), cnt.center, out);

		result.push_back(out);
	}
}

/*
	Function to calculate the standard deviation and mean(through reference)
	@param values - Vector of values
	@param mean   - Returning mean through reference
*/

float stdev(const vector<int> &values, float &mean)
{
	mean = 0;
	for (auto &val : values)
		mean += val;

	mean /= values.size();

	float stdev = 0;

	for (auto &val : values)
		stdev += std::pow(val - mean, 2);

	return std::sqrt(stdev / values.size());
}

/*
	Function to set a vector of z-scores to later determine possible outliers
	@param values - The vector containing the values
	@param result - The vector containing the zscores (MUST be empty. returned through referencing)
	@param mean   - The mean of the dataset
	@param stdev  - The standard deviation of the database
*/

float zscore(int value, float mean, float stdev)
{
	return (value - mean) / stdev;
}

/*
	Function to finnally annalyse the image and return a string containing the type of bars
	Example: TAFDTF( Tracker, ascendent, full, descendent, tracker, full)
	@param grayscale - The grayscaled image
	@return string - Returns the various possible codes separated by commas
*/

std::string analyse(cv::Mat &grayscale)
{

	cv::Mat th, frame;

	int desiredWidth = 800;
	int desiredHeight = 80;

	double x = (double)desiredWidth / std::max(grayscale.size().height, grayscale.size().width);
	double y = (double)desiredHeight / std::min(grayscale.size().height, grayscale.size().width);
	cv::resize(grayscale, th, cv::Size(), x, y);
	cv::resize(grayscale, frame, cv::Size(), x, y);

	int AUTO1 = 21,
		AUTO2 = 2,
		BLUR_LEVEL = 1,
		TH_MODE = 9;

	cv::Mat g0 = th.clone();
	cv::Mat g1 = th.clone();

	cv::GaussianBlur(g0, g0, cv::Size(89, 89), 3);
	cv::GaussianBlur(g1, g1, cv::Size(3, 3), 1);

	cv::subtract(g0, g1, th);
	cv::normalize(th, th, 0, 255, cv::NORM_MINMAX);

	cv::Mat white = cv::Mat(th.size(), CV_8UC1);
	white.setTo(cv::Scalar(255));
	cv::subtract(white, th, th);


	cv::threshold(th, th, 0, 255,  cv::THRESH_BINARY_INV | cv::THRESH_OTSU);

	cv::Mat element = getStructuringElement(cv::MORPH_RECT,
		cv::Size(3, 8));

	cv::morphologyEx(th, th, cv::MORPH_CLOSE, element);


	vector<vector<cv::Point>> countours;
	vector<cv::Vec4i> _;

	cv::findContours(th, countours, cv::RETR_EXTERNAL, cv::CHAIN_APPROX_SIMPLE);

	vector<cv::Rect> finalCnts;

	for (auto &cnt : countours)
	{
		finalCnts.push_back(cv::boundingRect(cnt));
	}

	// Cleaning part!

	int MAX_HEIGHT = grayscale.size().height, MIN_HEIGHT, MID_HEIGHT;
	float MIN_VAL = 0.1; // Threshold to remove small height bits

	finalCnts.erase(
		std::remove_if(
			finalCnts.begin(),
			finalCnts.end(),
			[&](cv::Rect x) {
				return x.size().height < MAX_HEIGHT * MIN_VAL;
			}),
		finalCnts.end());

	vector<int> widths;

	for (auto &val : finalCnts)
		widths.push_back(val.size().width);

	float stdev_, MED_WIDTH;

	stdev_ = stdev(widths, MED_WIDTH);

	finalCnts.erase(
		std::remove_if(
			finalCnts.begin(),
			finalCnts.end(),
			[&](cv::Rect x) {
				return zscore(x.size().width, MED_WIDTH, stdev_) > 3.2f;
			}),
		finalCnts.end());

	int BEGIN_POS, MID_POS;

	std::string output("");

	if (finalCnts.size() <= 80 && finalCnts.size() > 50)
	{

		std::sort(
			finalCnts.begin(),
			finalCnts.end(),
			[](const cv::Rect &obj1, const cv::Rect &obj2) { return obj2.x > obj1.x; });

		float stdev_dist, MED_DIST;
		// Useful to find if there are any missing bars in the middle of the code

		std::vector<int> dists;
		for (int i = 0; i < finalCnts.size() - 1; i++)
			dists.push_back(finalCnts[i + 1].x - finalCnts[i].x);

		stdev_dist = stdev(dists, MED_DIST);

		dists.erase(
			std::remove_if(
				dists.begin(),
				dists.end(),
				[&](int dist) {
					return zscore(dist, MED_DIST, stdev_dist) > 3.2f;
				}),
			dists.end());

		MED_DIST = 0;
		for (auto const &dist : dists)
			MED_DIST += dist;
		MED_DIST /= dists.size();

		float DIST_UNDER_TH = 0.5;
		float DIST_ABOVE_TH = 0.5;

		for (int i = 0; i < finalCnts.size() - 1; i++)
		{
			int dist = finalCnts[i + 1].x - finalCnts[i].x;
			if (dist < DIST_UNDER_TH * MED_DIST)
			{
				finalCnts.erase(finalCnts.begin() + i + 1); // Deleting if too small, might be duplicate!
				std::cout << "Deleted " << i;
			}

			if (dist > (1 + DIST_ABOVE_TH) * MED_DIST)
			{
				int ratio = (int)round(dist / MED_DIST); // How many times is it above?
				for (int j = 1; j < ratio; j++)
				{
					finalCnts.insert(finalCnts.begin() + i + j, cv::Rect(0, 0, MED_WIDTH, 0));
					//Skipping the new values
					// Can be any x values because its already sorted, so the only value that matters is height (1 => Produces Unrecognized)
				}
				i = i + ratio - 1;
			}
		}

		vector<int> HEIGHT_MAP, HEIGHT_MAP_NONZERO, POSITION_MAP;

		for (auto &cnt : finalCnts)
		{
			//cv::rectangle(grayscale, cnt, cv::Scalar(255, 0, 0));
			HEIGHT_MAP.push_back(cnt.height);
			if (cnt.height != 0)
				HEIGHT_MAP_NONZERO.push_back(cnt.height);

			POSITION_MAP.push_back(cnt.y);
		}

		MAX_HEIGHT = *std::max_element(HEIGHT_MAP_NONZERO.begin(), HEIGHT_MAP_NONZERO.end());
		MIN_HEIGHT = *std::min_element(HEIGHT_MAP_NONZERO.begin(), HEIGHT_MAP_NONZERO.end());
		MID_HEIGHT = 0.5 * MAX_HEIGHT + 0.5 * MIN_HEIGHT;

		BEGIN_POS = *std::min_element(POSITION_MAP.begin(), POSITION_MAP.end());
		MID_POS = BEGIN_POS + 0.5 * MAX_HEIGHT - 0.5 * MIN_HEIGHT;

		float THRESHHOLD = 0.2;
		float CONFIDENCE = THRESHHOLD * MAX_HEIGHT;

		for (int i = 0; i < finalCnts.size(); i++)
		{
			int currHeight = finalCnts[i].height;
			int currPos = finalCnts[i].y;
			if (currHeight == 0)
				output += 'U';
			else if (currHeight >= MAX_HEIGHT - CONFIDENCE)
				output += 'F';
			else if (currHeight <= MIN_HEIGHT + CONFIDENCE)
				output += 'T';

			// Since open cv sets the position reversed, ascender (starts at the top) actually is position = 0
			else if (currHeight >= MID_HEIGHT - CONFIDENCE && currHeight <= MID_HEIGHT + CONFIDENCE)
			{
				if (currPos <= BEGIN_POS + CONFIDENCE)
					output += 'A';
				else if (currPos >= MID_POS - CONFIDENCE and currPos <= MID_POS + CONFIDENCE)
					output += 'D';
				else
					output += 'U';
			}
			else
				output += 'U'; // Unrecognized
		}
	}

	return output; // "" if null or actual value
}

extern "C" __attribute__((visibility("default"))) __attribute__((used)) struct OutputFormat *scan(uint8_t *imageIn, int length)
{
	std::vector<uchar> data = std::vector<uchar>(imageIn, imageIn + length);
	cv::Mat image, original, grayscale;

	try
	{
		original = cv::imdecode(data, cv::IMREAD_UNCHANGED), grayscale;

		int height = original.size().height, width = original.size().width;

		//cv::Mat image = original;

		std::cout << height << " " << width << std::endl;

		cv::Rect ROI = cv::Rect((int)(width / 8), (int)(height / 5), (int)(6 * width / 8), (int)(3 * height / 5));
		if (height > width)
		{
			std::cout << "roatted\n";
			cv::rotate(original, original, cv::ROTATE_90_CLOCKWISE);
			ROI = cv::Rect((int)(height / 8), (int)(width / 5), (int)(6 * height / 7), (int)(3 * width / 5));
		}
		//cv::Mat image;
		cv::Mat image = original(ROI);

		int desiredWidth = 1200;
		double interpol = (double)desiredWidth / std::max(height, width);
		//std::cout << "Interpol " << interpol << std::endl;
		cv::resize(original, image, cv::Size(), interpol, interpol);

		std::cout << "new image: " << image.size().width << " " << image.size().height;

		cvtColor(image, grayscale, cv::COLOR_BGR2GRAY);
	}
	catch (cv::Exception ex)
	{
		OutputFormat *output = new OutputFormat[1];
		output->errnum = 8;
		std::string errorMessage = "Image was not sent correctly."; //"No barcode found.";
		output->output = new char[errorMessage.size() + 1];
		strcpy(output->output, errorMessage.c_str());

		return output;
	}

	vector<cv::Mat> possibleImgs;
	try
	{
		cut(grayscale, possibleImgs);
	}
	catch (cv::Exception ex)
	{
		OutputFormat *output = new OutputFormat[1];
		output->errnum = 8;
		std::string errorMessage(ex.what());
		output->output = new char[errorMessage.size() + 1];
		strcpy(output->output, errorMessage.c_str());

		return output;
	}

	OutputFormat *output = new OutputFormat[1];
	output->errnum = 7;
	std::string errorMessage = "No barcode found.";
	output->output = new char[errorMessage.size() + 1];
	strcpy(output->output, errorMessage.c_str());

	for (auto &poss : possibleImgs)
	{
		std::string barcode;

		try
		{
			barcode = analyse(poss);
		}
		catch (cv::Exception ex)
		{
			continue;
		}

		if (barcode.length() > 0)
		{
			char *barcodePointer = new char[76];

			if (barcode.length() < 75)
			{
				size_t missingChars = 75 - barcode.length();
				std::string copyString(barcode);

				copyString.insert(copyString.begin(), missingChars, 'U');
				strcpy(barcodePointer, copyString.c_str());
				delete[] output;

				output = barcodeDecoderF(barcodePointer);

				if (output->errnum == 0)
				{
					break;
				}

				copyString = std::string(barcode);

				copyString.insert(copyString.end(), missingChars, 'U');
				strcpy(barcodePointer, copyString.c_str());
				delete[] output;

				output = barcodeDecoderF(barcodePointer);
			}
			else if (barcode.length() == 75)
			{
				strcpy(barcodePointer, barcode.c_str());
				delete[] output;
				output = barcodeDecoderF(barcodePointer);
			}

			if (output->errnum == 0)
			{
				break;
			}
		}
	}

	return output;
}
