#include <iostream>
#include <deque>
#include <string>
#include <sstream>
#include <fstream>
#include <sys/stat.h>
#include <omp.h>

#include <opencv2/highgui/highgui.hpp>
#include <opencv2/core/core.hpp>

std::string getFrameNumber( int curFrame ){
	std::ostringstream curNumber;

	if (curFrame >= 1000){
		curNumber << curFrame;
	}else if(curFrame >= 100){
		curNumber << "0"<< curFrame;
	}else if (curFrame >= 10) {
		curNumber << "00"<< curFrame;
	}else {
		curNumber << "000"<< curFrame;
	}
	return curNumber.str();
}

int median(std::vector<int> &v)
{
	size_t n = v.size() / 2;
	nth_element(v.begin(), v.begin()+n, v.end());
	return v[n];
}

int median(std::deque<int> &v)
{
	size_t n = v.size() / 2;
	nth_element(v.begin(), v.begin()+n, v.end());
	return v[n];
}
timespec diff(timespec start, timespec end)
{
	timespec temp;
	if ((end.tv_nsec-start.tv_nsec)<0) {
		temp.tv_sec = end.tv_sec-start.tv_sec-1;
		temp.tv_nsec = 1000000000+end.tv_nsec-start.tv_nsec;
	} else {
		temp.tv_sec = end.tv_sec-start.tv_sec;
		temp.tv_nsec = end.tv_nsec-start.tv_nsec;
	}
	return temp;
}
int main(int argc, char **argv) {

	int radius = 6;
	int binRatio = 16;
	double threshold = 0.55;
	double thresholdIllumination = 1.0, windowIllumination = 690;
	int learningFrames = 800, offsetLearning = 100, numFrames = 1150;

	struct stat st = {0};
	int k,z,curY,curX, countIllElem = 0;
	double medianOffsetIll;
	double bhattacharyyaCoeff, bhattacharyyaDistance;
	std::deque<int> mediansIllVector;
	std::vector<int> curMedian;//deque is more efficient in our case (we have to manage the window shifting over the time)
	std::string pathImages("/home/andrea/Scrivania/tracking3D_Model_matlab/bkgSub/cameraJitter/badminton/input/in00");
	std::ostringstream imageSavePathParent,imageSavePathVid,imageSavePath, pathImagesCur;
	cv::Mat curFrame, bkgModelHistogram, curForeground;

	pathImagesCur.str("");
	pathImagesCur.clear();
	pathImagesCur << pathImages << getFrameNumber(1) << ".jpg";
	curFrame = cv::imread(pathImagesCur.str(),cv::IMREAD_GRAYSCALE);

	int heightFrame = curFrame.size().height;
	int widthFrame = curFrame.size().width;


	//Make Directory if it does not exist
	imageSavePathParent << "./ChangeDecResC_" << radius << "_" << threshold << "_" << thresholdIllumination <<"/";
	if (stat(imageSavePathParent.str().c_str(), &st) == -1) {
		mkdir(imageSavePathParent.str().c_str(), 0777);
	}
	imageSavePathVid << "./ChangeDecResC_" << radius << "_" << threshold << "_" << thresholdIllumination <<"/badminton/";
	if (stat(imageSavePathVid.str().c_str(), &st) == -1) {
		mkdir(imageSavePathVid.str().c_str(), 0777);
	}
	imageSavePath << "./ChangeDecResC_" << radius << "_" << threshold << "_" << thresholdIllumination <<"/badminton/results/";
	if (stat(imageSavePath.str().c_str(), &st) == -1) {
		mkdir(imageSavePath.str().c_str(), 0777);
	}



	const int histogramImagesSize[] = { heightFrame, widthFrame,256/binRatio};
	bkgModelHistogram = cv::Mat(3, histogramImagesSize,CV_64F,cv::Scalar(0.0));
	bkgModelHistogram.setTo(cv::Scalar(0.0));
	for (int curFrameNumber = 1; curFrameNumber < learningFrames; ++curFrameNumber)
	{
		std::cout<<"Learning stage Frame "<<curFrameNumber<<std::endl;
		pathImagesCur.str("");
		pathImagesCur.clear();
		curMedian.clear();
		pathImagesCur << pathImages << getFrameNumber(curFrameNumber) << ".jpg";
		curFrame = cv::imread(pathImagesCur.str(),cv::IMREAD_GRAYSCALE);
		//initialize the background model each level is a bin;
		for (curY = 0; curY < heightFrame; ++curY)
		{
			for (curX = 0; curX < widthFrame; ++curX)
			{
				//std::cout<<"curFrame.at<unsigned char>(curY, curX) = "<< (unsigned int)curFrame.at<unsigned char>(curY, curX)<<std::endl;
				double curVal= curFrame.at<unsigned char>(curY, curX);
				int curIdx = floor(curVal/256*binRatio);
				if (curFrameNumber > learningFrames - windowIllumination){
					curMedian.push_back((int)curVal);
				}
				/*if((curY==100)&&(curX==100)){
					std::cout<<"bkgModelHistogram  ="<<bkgModelHistogram.at<double>(curY, curX, curIdx)<<std::endl;
					std::cout<<"curIdx  ="<<curIdx<<std::endl;
				}*/
				bkgModelHistogram.at<double>(curY, curX, curIdx) = bkgModelHistogram.at<double>(curY, curX, curIdx) + 1.0;
				/*if((curY==100)&&(curX==100)){
					std::cout<<"bkgModelHistogram  ="<<bkgModelHistogram.at<double>(curY, curX, curIdx)<<std::endl;
					std::cout<<"curIdx  ="<<curIdx<<std::endl;
				}*/
			}
		}
		if (curFrameNumber > learningFrames - windowIllumination){
			countIllElem++;
			mediansIllVector.push_back(median(curMedian));
		}

	}

	std::cout<<"Learning stage ENDED"<<std::endl;

	//const int curNeighborHistogramSize[] = {2*radius+1, 2*radius+1, 256/binRatio};
	//initialize the background model each level is a bin;

	double startTimer = omp_get_wtime();
	for (int curFrameNumber = learningFrames - offsetLearning; curFrameNumber <= numFrames; ++curFrameNumber)
	{
		std::cout<<"BKsub  stage Frame "<<curFrameNumber<<std::endl;
		pathImagesCur.str("");
		pathImagesCur.clear();
		pathImagesCur << pathImages  << getFrameNumber(curFrameNumber) << ".jpg";
		curFrame = cv::imread(pathImagesCur.str(),cv::IMREAD_GRAYSCALE);
		curForeground = cv::Mat::zeros(curFrame.size(),CV_8U);
		curMedian.clear();

		//illumination management
		for (curY = 0; curY < heightFrame; ++curY)
		{
			for (curX = 0; curX < widthFrame; ++curX)
			{
				double curVal= curFrame.at<unsigned char>(curY, curX);
				curMedian.push_back((int)curVal);
			}
		}

		if (curFrameNumber >= learningFrames - offsetLearning){
			int curMedianVal = median(curMedian);
			int medianToCompare =  median(mediansIllVector);
			medianOffsetIll = medianToCompare - curMedianVal;
			mediansIllVector.push_back(curMedianVal);
			countIllElem++;
			if (countIllElem > windowIllumination){
				mediansIllVector.pop_front();
			}
		}

		cv::Mat bhattacharyyaDistanceMat = cv::Mat(heightFrame, widthFrame,CV_64F,cv::Scalar(0.0));
		curFrame = curFrame + round(medianOffsetIll*thresholdIllumination);

		double curVal= curFrame.at<unsigned char>(curY, curX);
		int curIdxExternal = floor(curVal/256*binRatio);
		#pragma omp parallel for private(curX, curY, bhattacharyyaCoeff, bhattacharyyaDistance,k,z)
		for (curY = radius; curY < heightFrame-radius; curY++)
		{
			for (curX = radius; curX < widthFrame-radius; ++curX)
			{
				cv::Mat curNeighborHistogram = cv::Mat((int)256/binRatio, 1,CV_64F,cv::Scalar(0.0));
				cv::Mat bkgNeighborHistogram = cv::Mat((int)256/binRatio, 1,CV_64F,cv::Scalar(0.0));
				for (k = -radius; k <= radius; ++k)
				{
					for (z = -radius; z <= radius; ++z)
					{
						//creates the histogram of current pixel's neighbor histogram on the current frame
						int curIdx = floor(((double)curFrame.at<unsigned char>(curY + z, curX + k))/256*binRatio);
						//printf("curIdx: %d\n",curIdx);
						curNeighborHistogram.at<double>(curIdx,0) += 1.0;
						//std::cout<<"curFrame.at<unsigned char>("<<curY + z<<","<<curX + k<<")/256*binRatio = "<<curIdx<<std::endl;
						//std::cout<<"curFrame.at<unsigned char>(curY + z, curX + k) = "<<(unsigned int)curFrame.at<unsigned char>(curY + z, curX + k)<<std::endl;

						/*if ((curX==270)&&(curY==120)&&(z==0)&&(k==0)){
							std::cout<<curIdx<<std::endl;
						}*/
						//std::cout<<"BADADA1 curX: "<<curX<<" curY: "<<curY<<" z: "<<z<<" k: "<<std::endl;
						for (int curBin = 0; curBin < (int)256/binRatio; ++curBin) {
							//creates the histogram of current pixel's neighbor histogram on the background model
							bkgNeighborHistogram.at<double>(curBin,0) += bkgModelHistogram.at<double>(curY + z, curX + k,curBin)/1000000;
							//std::cout<<"bkgModelHistogram  ="<<bkgModelHistogram.at<double>(curY + z, curX + k,curBin)<<std::endl;
						}
					}
				}

				//std::cout<<"BADADA1"<<std::endl;
				//normalize the histograms
				double totbkgNeighborHistVal = 0.0;
				double totcurNeighborHistVal = 0.0;
				for (int curBin = 0; curBin < (int)256/binRatio; ++curBin) {
					totbkgNeighborHistVal += bkgNeighborHistogram.at<double>(curBin,0);
					totcurNeighborHistVal += curNeighborHistogram.at<double>(curBin,0);
					/*if ((curX==270)&&(curY==120)){
						std::cout<<"bkgNeighborHistogram: ";
						std::cout<<bkgNeighborHistogram.at<double>(curBin,0)<<"; curNeighborHistogram: ";
						std::cout<<curNeighborHistogram.at<double>(curBin,0)<<std::endl;
					}*/
				}


				//std::cout<<"BADADA2"<<std::endl;
				bhattacharyyaCoeff = 0.0;
				for (int curBin = 0; curBin < 256/binRatio; ++curBin) {
					bhattacharyyaCoeff += sqrt(((bkgNeighborHistogram.at<double>(curBin,0)+0.000001)/totbkgNeighborHistVal)
							*((curNeighborHistogram.at<double>(curBin,0)+0.000001)/totcurNeighborHistVal));
					/*std::cout<<"bkgNeighborHistogram "<<(bkgNeighborHistogram.at<double>(curBin,0));
					std::cout<<" bkgNeighborHistogram/totbkgNeighborHistVal "<<(bkgNeighborHistogram.at<double>(curBin,0)/totbkgNeighborHistVal)<<std::endl;
					std::cout<<"curNeighborHistogram "<<(curNeighborHistogram.at<double>(curBin,0));
					std::cout<<" curNeighborHistogram/totcurNeighborHistVal "<<(curNeighborHistogram.at<double>(curBin,0)/totcurNeighborHistVal)<<std::endl;
					std::cout<<"bhattacharyyaCoeff "<<bhattacharyyaCoeff<<std::endl;*/
				}
				bhattacharyyaDistance = 1- (bhattacharyyaCoeff);
				bhattacharyyaDistanceMat.at<double>(curY,curX) = bhattacharyyaDistance;
				/*if ((curX==270)&&(curY==120)){
					std::cout<<"bhattacharyyaCoeff"<<bhattacharyyaCoeff<<" ";
									std::cout<<"bhattacharyyaDistance"<<bhattacharyyaDistance<<std::endl;
									}*/
				/*std::cout<<"bhattacharyyaCoeff"<<bhattacharyyaCoeff<<std::endl;
				std::cout<<"bhattacharyyaDistance"<<bhattacharyyaDistance<<std::endl;*/

				//std::cout<<"BADADA3"<<std::endl;
				if (bhattacharyyaDistance > threshold){
					curForeground.at<unsigned char>(curY,curX) = 255;
					//update background model: update of current foreground pixels
					//bkgModelHistogram.at<double>(curY, curX, curIdxExternal) += 0.51;
				}else{
					//bkgModelHistogram.at<double>(curY, curX, curIdxExternal) += 1.0;
					//std::cout<<"bkgModelHistogram  ="<<bkgModelHistogram.at<double>(curY, curX, curIdxExternal)<<std::endl;
				}
				curNeighborHistogram.release();
				bkgNeighborHistogram.release();
			}
		}


		for (curY = 0; curY < heightFrame; ++curY)
		{
			for (curX = 0; curX < widthFrame; ++curX){
				if (bhattacharyyaDistanceMat.at<double>(curY,curX) > threshold){
					//update background model: update of current foreground pixels
					bkgModelHistogram.at<double>(curY, curX, curIdxExternal) += 0.51;
				}else{
					bkgModelHistogram.at<double>(curY, curX, curIdxExternal) += 1.0;
					//std::cout<<"bkgModelHistogram  ="<<bkgModelHistogram.at<double>(curY, curX, curIdxExternal)<<std::endl;
				}
			}
		}
		/*cv::imshow("curForeground",curForeground);
		cv::imshow("curFrame",curFrame);
		cv::waitKey(1);*/

		bhattacharyyaDistanceMat.release();
		pathImagesCur.str("");
		pathImagesCur.clear();
		pathImagesCur << imageSavePath.str() << "frame0"<< getFrameNumber(curFrameNumber) << ".jpg";
		cv::imwrite(pathImagesCur.str(),curForeground);
		/*cv::imshow("curF", curForeground);
		cv::waitKey(0);*/

	}
	double endTimer = omp_get_wtime();
	double dub_time = endTimer-startTimer;
	std::cout<<"Total time  ="<<dub_time<<" s ";
	std::cout<<" fps  ="<<((double)numFrames -(learningFrames - offsetLearning))/dub_time<<" ";
	std::cout<<" spf  ="<<dub_time/((double)numFrames -(learningFrames - offsetLearning))<<" ";
	std::cout<<" Num frame  ="<<numFrames -(learningFrames - offsetLearning)<<std::endl;

	return 0;
}
