/*
GRT DTW Example
This examples demonstrates how to initialize, train, and use the DTW algorithm for classification.

The Dynamic Time Warping (DTW) algorithm is a powerful classifier that works very well for recognizing temporal gestures.

In this example we create an instance of an DTW algorithm and then train the algorithm using some pre-recorded training data.
The trained DTW algorithm is then used to predict the class label of some test data.

This example shows you how to:
- Create an initialize the DTW algorithm
- Load some LabelledTimeSeriesClassificationData from a file and partition the training data into a training dataset and a test dataset
- Trim any periods of non-movement from the start and end of each timeseries recording
- Train the DTW algorithm using the training dataset
- Test the DTW algorithm using the test dataset
- Manually compute the accuracy of the classifier
*/

//You might need to set the specific path of the GRT header relative to your project
#include "GRT.h"
#include <conio.h>
#include <windows.h>

using namespace GRT;
using namespace std;

int main(int argc, const char * argv[])
{
	//Create a new DTW instance, using the default parameters
	DTW orientDTW;
	DTW emgDTW;

	//Load some training data to train the classifier - the DTW uses LabelledTimeSeriesClassificationData
	TimeSeriesClassificationData orientTrainingData;
	TimeSeriesClassificationData emgTrainingData;

	if (!orientTrainingData.load("OrientTrainingData.txt")) {
		cout << "Failed to load training data!\n";
		return EXIT_FAILURE;
	}

	if (!emgTrainingData.load("EMGTrainingData.txt")) {
		cout << "Failed to load training data!\n";
		return EXIT_FAILURE;
	}

	//Use 20% of the training dataset to create a test dataset
	TimeSeriesClassificationData orientTestData = orientTrainingData.partition(80);
	TimeSeriesClassificationData emgTestData = emgTrainingData.partition(80);

	//Trim the training data for any sections of non-movement at the start or end of the recordings
	orientDTW.enableNullRejection(true);
	orientDTW.setNullRejectionCoeff(5);
	orientDTW.enableTrimTrainingData(true, 0.1, 90);

	GestureRecognitionPipeline orientPipeline;
	orientPipeline.setClassifier(orientDTW);
	//orientPipeline.addPostProcessingModule(ClassLabelFilter(5, 10));
	//orientPipeline.addPostProcessingModule(ClassLabelChangeFilter());
	//orientPipeline.addPreProcessingModule(MovingAverageFilter(5, 3));
	//orientPipeline.addFeatureExtractionModule(FFT(512, 1, 3, 0, true, true));
	//orientPipeline.addPostProcessingModule(ClassLabelTimeoutFilter(1000));
	//orientPipeline.addFeatureExtractionModule(MovementIndex(100, 3));

	//Train the classifier
	if (!orientPipeline.train(orientTrainingData)) {
		cout << "Failed to train classifier!\n";
		return EXIT_FAILURE;
	}

	//Save the DTW model to a file
	if (!orientPipeline.save("OrientDTWModel.txt")) {
		cout << "Failed to save the classifier model!\n";
		return EXIT_FAILURE;
	}

	//Load the DTW model from a file
	if (!orientPipeline.load("OrientDTWModel.txt")) {
		cout << "Failed to load the classifier model!\n";
		return EXIT_FAILURE;
	}

	emgDTW.enableNullRejection(true);
	emgDTW.setNullRejectionCoeff(5);
	emgDTW.enableTrimTrainingData(true, 0.1, 90);

	//Train the classifier
	if (!emgDTW.train(emgTrainingData)) {
		cout << "Failed to train classifier!\n";
		return EXIT_FAILURE;
	}


	//Save the DTW model to a file
	if (!emgDTW.save("EMGDTWModel.txt")) {
		cout << "Failed to save the classifier model!\n";
		return EXIT_FAILURE;
	}

	//Load the DTW model from a file
	if (!emgDTW.load("EMGDTWModel.txt")) {
		cout << "Failed to load the classifier model!\n";
		return EXIT_FAILURE;
	}

	//Use the test dataset to test the DTW model
	double accuracy = 0;
	for (UINT i = 0; i < orientTestData.getNumSamples(); i++) {
		//Get the i'th test sample - this is a timeseries
		UINT classLabel = orientTestData[i].getClassLabel();
		MatrixDouble orientTimeseries = orientTestData[i].getData();
		MatrixDouble emgTimeseries = emgTestData[i].getData();

		//Perform a prediction using the classifier
		if (!orientPipeline.predict(orientTimeseries)) {
			cout << "Failed to perform prediction for test sampel: " << i << "\n";
			return EXIT_FAILURE;
		}

		//Get the predicted class label
		UINT orientPredictedClassLabel = orientPipeline.getPredictedClassLabel();
		double orientMaximumLikelihood = orientPipeline.getMaximumLikelihood();
		VectorDouble orientClassLikelihoods = orientPipeline.getClassLikelihoods();
		VectorDouble orientClassDistances = orientPipeline.getClassDistances();

		//Perform a prediction using the classifier
		if (!emgDTW.predict(emgTimeseries)) {
			cout << "Failed to perform prediction for test sampel: " << i << "\n";
			return EXIT_FAILURE;
		}

		//Get the predicted class label
		UINT emgPredictedClassLabel = emgDTW.getPredictedClassLabel();
		double emgMaximumLikelihood = emgDTW.getMaximumLikelihood();
		VectorDouble emgClassLikelihoods = emgDTW.getClassLikelihoods();
		VectorDouble emgClassDistances = emgDTW.getClassDistances();

		//Update the accuracy
		if (classLabel == orientPredictedClassLabel && orientPredictedClassLabel == emgPredictedClassLabel) accuracy++;

		cout << "Orientation TestSample: " << i << "\tClassLabel: " << classLabel << "\tPredictedClassLabel: " << orientPredictedClassLabel << "\tMaximumLikelihood: " << orientMaximumLikelihood << endl;
		cout << "EMG TestSample: " << i << "\tClassLabel: " << classLabel << "\tPredictedClassLabel: " << emgPredictedClassLabel << "\tMaximumLikelihood: " << emgMaximumLikelihood << endl;
	}

	cout << "Test Accuracy: " << accuracy / double(orientTestData.getNumSamples())*100.0 << "%" << endl;

	while (VK_SPACE != _getch()) {
		return EXIT_SUCCESS;
	}
}

