#include <opencv2/core/core.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include <iostream>
#include <vector>
#include <string>
#include <chrono> 
#include <cmath>


using namespace std::chrono;

using std::vector;



/*
	findCountours is a function to find the countours that might be the barcode

	@param grayscale - The grayscaled image
	@param result - The Rotated Rect containing the rectangles of possible barcodes

*/

void findCountours(cv::Mat& grayscale, vector<cv::RotatedRect>& result) {
	cv::Mat th;

	int AUTO1 = 29,
		AUTO2 = 5,
		BLUR_LEVEL = 7,
		TH_MODE = 9,
		MIN_RATIO = 9,
		MAX_RATIO = 16;

	float CENTER_POINT_THRESHHOLD = 0.15;


	int resy = grayscale.size().width;
	int resx = grayscale.size().height;


	cv::adaptiveThreshold(
		grayscale, th, 255,
		cv::ADAPTIVE_THRESH_MEAN_C,
		cv::THRESH_BINARY,
		AUTO1,
		AUTO2);

	/*
	In order to find the barcode, we will blur
	the image quite a lot to disperse the bars
	and join them
	*/

	cv::GaussianBlur(th, th, cv::Size(0, 0), BLUR_LEVEL);

	cv::threshold(th, th, 0, 255, TH_MODE);



	vector<vector<cv::Point>> countours;


	// Center Rect - (y, x, w, h)
	// Open cv understands coordinates in a weird way

	vector<int> centerRect{
		int(resy / 2 - CENTER_POINT_THRESHHOLD * resy),
		int(resx / 2 - CENTER_POINT_THRESHHOLD * resx),
		int(CENTER_POINT_THRESHHOLD * 2 * resy),
		int(CENTER_POINT_THRESHHOLD * 2 * resx)
	};


	cv::findContours(th, countours, cv::RETR_EXTERNAL, cv::CHAIN_APPROX_SIMPLE);

	

	cv::drawContours( grayscale, countours, -1, cv::Scalar(255, 0, 0));
	cv::namedWindow("");
	cv::imshow("", grayscale);
	cv::waitKey();



	for (auto& cnt : countours) {

		cv::RotatedRect outCnt = cv::minAreaRect(cnt);


		// Not even god knows why x and y are switched, but it works

		if (//outCnt.size.height * MIN_RATIO <= outCnt.size.width &&
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

void cut(cv::Mat& grayscale, vector<cv::Mat>& result) {
	vector<cv::RotatedRect> countours;

	findCountours(grayscale, countours);


	for (auto& cnt : countours) {

		cv::Mat out, M;

		int width = cnt.size.width;
		int height = cnt.size.height;

		float angle = cnt.angle;

		if (angle < -45.) {
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

float stdev(const vector<int>& values, float& mean) {
	mean = 0;
	for (auto& val : values) mean += val;

	mean /= values.size();


	float stdev = 0;

	for (auto& val : values) stdev += std::pow(val - mean, 2);

	return std::sqrt(stdev / values.size());
}



/*
	Function to set a vector of z-scores to later determine possible outliers

	@param values - The vector containing the values
	@param result - The vector containing the zscores (MUST be empty. returned through referencing)
	@param mean   - The mean of the dataset
	@param stdev  - The standard deviation of the database

*/

float zscore(int value, float mean, float stdev) {
	return (value - mean) / stdev;

}


/*
	Function to finnally annalyse the image and return a string containing the type of bars
	Example: TAFDTF( Tracker, ascendent, full, descendent, tracker, full)

	@param grayscale - The grayscaled image
	@return string - Returns the various possible codes separated by commas
*/

std::string analyse(cv::Mat& grayscale) {
	cv::Mat th, frame;


	int desiredWidth = 800;
	int desiredHeight = 80;

	double x = (double)desiredWidth / std::max(grayscale.size().height, grayscale.size().width);
	double y = (double)desiredHeight / std::min(grayscale.size().height , grayscale.size().width);
	cv::resize(grayscale, th, cv::Size(), x, y);
	cv::resize(grayscale, frame, cv::Size(), x, y);

	int AUTO1 = 21,
		AUTO2 = 2,
		BLUR_LEVEL = 1,
		TH_MODE = 9;

	

	
	cv::adaptiveThreshold(
		th, th, 255,
		cv::ADAPTIVE_THRESH_MEAN_C,
		cv::THRESH_BINARY,
		AUTO1,
		AUTO2);
		
	cv::GaussianBlur(th, th, cv::Size(0, 0), BLUR_LEVEL);
	//cv::medianBlur(th, th, BLUR_LEVEL);
	
	cv::Mat element = getStructuringElement(cv::MORPH_RECT,
		cv::Size(5, 5),
		cv::Point(1, 1));
	
	cv::morphologyEx(th, th, cv::MORPH_CLOSE, element);

	cv::threshold(th, th, 10, 255,  cv::THRESH_BINARY_INV | cv::THRESH_OTSU);
	
	


	vector<vector<cv::Point>> countours;
	vector<cv::Vec4i> _;


	cv::findContours(th, countours, cv::RETR_EXTERNAL, cv::CHAIN_APPROX_SIMPLE);

	cv::namedWindow("");
	cv::imshow("",th);
	cv::waitKey();


	vector<cv::Rect> finalCnts;


	for (auto& cnt : countours) {
		finalCnts.push_back(cv::boundingRect(cnt));
	}




	// Cleaning part!

	int MAX_HEIGHT = grayscale.size().height, MIN_HEIGHT, MID_HEIGHT;
	float MIN_VAL = 0.12; // Threshold to remove small height bits



	finalCnts.erase(
		std::remove_if(
			finalCnts.begin(),
			finalCnts.end(),
			[&](cv::Rect x) {
		return x.size().height < MAX_HEIGHT * MIN_VAL;
	}
		),
		finalCnts.end()
		);


	vector<int> widths;

	for (auto& val : finalCnts) widths.push_back(val.size().width);

	float stdev_, MED_WIDTH;

	stdev_ = stdev(widths, MED_WIDTH);




	finalCnts.erase(
		std::remove_if(
			finalCnts.begin(),
			finalCnts.end(),
			[&](cv::Rect x) {
		return zscore(x.size().width, MED_WIDTH, stdev_) > 3.2f;
	}
		),
		finalCnts.end()
		);




	int BEGIN_POS, MID_POS;

	std::string output("");





	if (finalCnts.size() <= 80 && finalCnts.size() > 50) {

		


		std::sort(
			finalCnts.begin(),
			finalCnts.end(),
			[](const cv::Rect& obj1, const cv::Rect& obj2) { return obj2.x > obj1.x; });




		float stdev_dist, MED_DIST;
		// Useful to find if there are any missing bars in the middle of the code

		std::vector<int> dists;
		for (int i = 0; i < finalCnts.size() - 1; i++) dists.push_back(finalCnts[i + 1].x - finalCnts[i].x);


		stdev_dist = stdev(dists, MED_DIST);

		for (auto const& dist : dists) std::cout << dist << " ";
		std::cout << std::endl;


		dists.erase(
			std::remove_if(
				dists.begin(),
				dists.end(),
				[&](int dist) {
			return zscore(dist, MED_DIST, stdev_dist) > 3.2f;
		}
			),
			dists.end()
			);

		for (auto a : finalCnts) cv::rectangle(frame, a, cv::Scalar(255, 0, 0));
		cv::namedWindow("");
		cv::imshow("", frame);
		cv::waitKey();



		MED_DIST = 0;
		for (auto const& dist : dists) MED_DIST += dist;
		MED_DIST /= dists.size();

		std::cout << "MED DIST " << MED_DIST << std::endl;


		float DIST_UNDER_TH = 0.5;
		float DIST_ABOVE_TH = 0.5;

		for (int i = 0; i < finalCnts.size() - 1; i++) {
			int dist = finalCnts[i + 1].x - finalCnts[i].x;
			if (dist < DIST_UNDER_TH * MED_DIST) {
				finalCnts.erase(finalCnts.begin() + i + 1); // Deleting if too small, might be duplicate!
				std::cout << "Deleted " << i;
			}


			if (dist > (1 + DIST_ABOVE_TH) * MED_DIST) {
				int ratio = (int)round(dist / MED_DIST); // How many times is it above?
				for (int j = 1; j < ratio; j++) {
					finalCnts.insert(finalCnts.begin() + i + j, cv::Rect(0, 0, MED_WIDTH, 0));
					std::cout << "Added " << i;
					//Skipping the new values
				   // Can be any x values because its already sorted, so the only value that matters is height (1 => Produces Unrecognized)
				}
				i = i + ratio - 1;
			}
		}
		std::cout << std::endl;




		vector<int> HEIGHT_MAP, HEIGHT_MAP_NONZERO, POSITION_MAP, POSITION_MAP_NONZERO;

		for (auto& cnt : finalCnts) {
			//cv::rectangle(grayscale, cnt, cv::Scalar(255, 0, 0));
			HEIGHT_MAP.push_back(cnt.height);
			if (cnt.height != 0) HEIGHT_MAP_NONZERO.push_back(cnt.height);
			if (cnt.height != 0) POSITION_MAP_NONZERO.push_back(cnt.y);

			POSITION_MAP.push_back(cnt.y);
		}

		cv::namedWindow("");
		cv::imshow("", grayscale);
		cv::waitKey();


		MAX_HEIGHT = *std::max_element(HEIGHT_MAP_NONZERO.begin(), HEIGHT_MAP_NONZERO.end());
		MIN_HEIGHT = *std::min_element(HEIGHT_MAP_NONZERO.begin(), HEIGHT_MAP_NONZERO.end());
		MID_HEIGHT = 0.5 * MAX_HEIGHT + 0.5 * MIN_HEIGHT;

		BEGIN_POS = *std::min_element(POSITION_MAP_NONZERO.begin(), POSITION_MAP_NONZERO.end());
		MID_POS = BEGIN_POS + 0.5 * MAX_HEIGHT - 0.5 * MIN_HEIGHT;


		std::cout << MAX_HEIGHT << " " << MIN_HEIGHT << " " << MID_HEIGHT << " " << BEGIN_POS << " " << MID_POS << " " << std::endl;


		float THRESHHOLD = 0.2;
		float CONFIDENCE = THRESHHOLD * MAX_HEIGHT;


		for (int i = 0; i < finalCnts.size(); i++) {
			int currHeight = finalCnts[i].height;
			int currPos = finalCnts[i].y;

			std::cout << currHeight << " " << currPos << std::endl;


			if (currHeight == 0) output += 'U';
			else if (currHeight >= MAX_HEIGHT - CONFIDENCE) output += 'F';
			else if (currHeight <= MIN_HEIGHT + CONFIDENCE) output += 'T';

			// Since open cv sets the position reversed, ascender (starts at the top) actually is position = 0
			else if (currHeight >= MID_HEIGHT - CONFIDENCE && currHeight <= MID_HEIGHT + CONFIDENCE) {
				if (currPos <= BEGIN_POS + CONFIDENCE) output += 'A';
				else if (currPos >= MID_POS - CONFIDENCE and currPos <= MID_POS + CONFIDENCE)
					output += 'D';
				else output += 'U';
			}
			else output += 'U'; // Unrecognized
		}
	}


	return output; // "" if null or actual value
}



#include <vector>
#include <fstream>

static std::vector<char> ReadAllBytes(std::string filename)
{
	std::ifstream ifs(filename, std::ios::binary | std::ios::ate);
	std::ifstream::pos_type pos = ifs.tellg();

	std::vector<char>  result(pos);

	ifs.seekg(0, std::ios::beg);
	ifs.read(&result[0], pos);

	return result;
}


int main()
{

	auto start = high_resolution_clock::now();

	cv::String fileName = "orange1.jpeg";



	std::vector<char> imageIn = ReadAllBytes(fileName);
	std::vector<uchar> data = std::vector<uchar>(imageIn.begin(), imageIn.end());
	


	cv::Mat original = cv::imdecode(data, cv::IMREAD_UNCHANGED), grayscale;
	
	int height = original.size().height , width = original.size().width;

	//cv::Mat image = original;
	
	std::cout << height << " " << width << std::endl;


	cv::Rect ROI = cv::Rect((int)(width / 6) - 40, (int)(height / 4) - 40,  (int)(4 * width / 6) + 20, (int)(2 * height / 4) + 20);
	if (height > width) {
		std::cout << "roatted\n";
		cv::rotate(original, original, cv::ROTATE_90_CLOCKWISE);
		ROI = cv::Rect((int)(height / 6), (int)(width / 4), (int)(4 * height / 6), (int)(2 * width / 4));
	}
	cv::Mat image;
	//cv::Mat image = original(ROI);


	int desiredWidth = 1800;
	double interpol = (double)desiredWidth / std::max(height, width);
	std::cout << "Interpol " << interpol << std::endl;
	cv::resize(original, image, cv::Size(), interpol, interpol);

	std::cout << "new image: " << image.size().width << " " << image.size().height;

	cvtColor(image, grayscale, cv::COLOR_BGR2GRAY);



	vector<cv::Mat> possibleImgs;
	cut(grayscale, possibleImgs);
	std::cout << "Work" << possibleImgs.size() << std::endl;
	for (auto& poss : possibleImgs) {
		std::cout << analyse(poss) << std::endl;
	}



	auto stop = high_resolution_clock::now();
	auto duration = duration_cast<milliseconds>(stop - start);
	std::cout << "Duration: " << duration.count() << std::endl;

}
