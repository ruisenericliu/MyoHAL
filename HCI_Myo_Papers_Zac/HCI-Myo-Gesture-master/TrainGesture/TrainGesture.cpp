#define _USE_MATH_DEFINES
#include <cmath>
#include <array>
#include <conio.h>
#include <string>
#include <fstream>
#include <windows.h>
#include <iostream>
#include <stdlib.h> 
#include <myo/myo.hpp>
#include "GRT.h"

using namespace GRT;
using namespace std;

// Classes that inherit from myo::DeviceListener can be used to receive events from Myo devices. DeviceListener
// provides several virtual functions for handling different kinds of events.
class DataCollector : public myo::DeviceListener {
public:
	DataCollector() : onArm(false), emgData(), roll_w(0), pitch_w(0), yaw_w(0) {
		roll = 0; pitch = 0; yaw = 0;
	}

	// onEmgData() is called whenever a paired Myo has provided new EMG data, and EMG streaming is enabled.
	void onEmgData(myo::Myo* myo, uint64_t timestamp, const int8_t* emg) {
		for (int i = 0; i < 8; i++) {
			emgData[i] = emg[i];
		}
	}

	// Called whenever the Myo has changed position and new gyroscope data is provided, which is represented as a 3-vector
	void onGyroscopeData(myo::Myo *myo, uint64_t timestamp, const myo::Vector3< float > &gyroscope) {
		gyro[0] = gyroscope[0];
		gyro[1] = gyroscope[1];
		gyro[2] = gyroscope[2];
	}

	// onAccelerometerData() is called whenever the Myo device provides its current acceleration, which is represented
	// as a 3-vector.
	void onAccelerometerData(myo::Myo* myo, uint64_t timestamp, const myo::Vector3<float>& acceleration) {
		accel[0] = acceleration[0];
		accel[1] = acceleration[1];
		accel[2] = acceleration[2];
	}

	// onOrientationData() is called whenever the Myo device provides its current orientation, which is represented
	// as a unit quaternion.
	void onOrientationData(myo::Myo* myo, uint64_t timestamp, const myo::Quaternion<float>& quat) {
		// Calculate Euler angles (roll, pitch, and yaw) from the unit quaternion.
		/*
		roll = atan2(2.0f * (quat.w() * quat.x() + quat.y() * quat.z()),
			1.0f - 2.0f * (quat.x() * quat.x() + quat.y() * quat.y()));
		pitch = asin(max(-1.0f, min(1.0f, 2.0f * (quat.w() * quat.y() - quat.z() * quat.x()))));
		yaw = atan2(2.0f * (quat.w() * quat.z() + quat.x() * quat.y()),
			1.0f - 2.0f * (quat.y() * quat.y() + quat.z() * quat.z()));

		// Convert the floating point angles in radians to a scale from 0 to 18.
		roll_w = static_cast<int>((roll + (float)M_PI) / (M_PI * 2.0f) * 18);
		pitch_w = static_cast<int>((pitch + (float)M_PI / 2.0f) / M_PI * 18);
		yaw_w = static_cast<int>((yaw + (float)M_PI) / (M_PI * 2.0f) * 18);
		*/

		rotateOrientation(orientationOffset, quat);
		
		//orient[0] = roll;
		//orient[1] = pitch;
		//orient[2] = yaw;
	}

	void findPosition(const myo::Quaternion<float>& quat) {
		float horizontalComponent = sin(calculateYaw(quat)) * cos(calculatePitch(quat));
		float verticalComponent = sin(calculatePitch(quat));
		float rawTheta = calculateRoll(orientationOffset);

		//x
		orient[0] = sin(rawTheta) * verticalComponent - cos(rawTheta) * horizontalComponent;
		//y
		orient[1] = cos(rawTheta) * verticalComponent + sin(rawTheta) * horizontalComponent;
		//theta
		orient[2] = sin(calculateRoll(quat));
	}

	// Calculates the Roll from quaternions based on the armbands offset
	float calculateRoll(const myo::Quaternion<float>& q) {
		return atan2(2.0*(q.y()*q.z() + q.w()*q.x()), q.w()*q.w() - q.x()*q.x() - q.y()*q.y() + q.z()*q.z());
	}

	// Calculates the Pitch from quaternions based on the armbands offset
	float calculatePitch(const myo::Quaternion<float>& q) {
		return asin(-2.0*(q.x()*q.z() - q.w()*q.y()));
	}

	// Calculates the Yaw from quaternions based on the armbands offset
	float calculateYaw(const myo::Quaternion<float>& q) {
		return atan2(2.0*(q.x()*q.y() + q.w()*q.z()), q.w()*q.w() + q.x()*q.x() - q.y()*q.y() - q.z()*q.z());
	}

	// When called this will reset the quaternion values to 0
	// adding an offset to the current quaternion values
	void zeroOrientation() {
		const myo::Quaternion<float>& q = currQuaternion;
		float len = sqrt(q.x() * q.x() + q.y() * q.y() + q.z() * q.z() + q.w() * q.w());
		orientationOffset = myo::Quaternion<float>(-q.x() / len, -q.y() / len, -q.z() / len, q.w() / len);
	}

	// Sets the current quaternion values based on the current offset set
	void rotateOrientation(const myo::Quaternion<float>& q, const myo::Quaternion<float>& r) {
		float w = q.w() * r.w() - q.x() * r.x() - q.y() * r.y() - q.z() * r.z();
		float x = q.w() * r.x() + q.x() * r.w() + q.y() * r.z() - q.z() * r.y();
		float y = q.w() * r.y() - q.x() * r.z() + q.y() * r.w() + q.z() * r.x();
		float z = q.w() * r.z() + q.x() * r.y() - q.y() * r.x() + q.z() * r.w();
		currQuaternion = myo::Quaternion<float>(x, y, z, w);
		findPosition(currQuaternion);
	}

	// onArmSync() is called whenever Myo has recognized a Sync Gesture after someone has put it on their
	// arm. This lets gestures[i].substring(0,gestures[i].find_first_of('_')Myo know which arm it's on and which way it's facing.
	void onArmSync(myo::Myo* myo, uint64_t timestamp, myo::Arm arm, myo::XDirection xDirection, float rotation,
		myo::WarmupState warmupState) {
		onArm = true;
		whichArm = arm;
	}

	// onArmUnsync() is called whenever Myo has detected that it was moved from a stable position on a person's arm after
	// it recognized the arm. Typically this happens when someone takes Myo off of their arm, but it can also happen
	// when Myo is moved around on the arm.
	void onArmUnsync(myo::Myo* myo, uint64_t timestamp) {
		onArm = false;
	}

	// Print out the EMG raw data
	void printEMG() {
		cout << '[' << to_string(emgData[0]) << ']' << '[' << to_string(emgData[1]) << ']'
			<< '[' << to_string(emgData[2]) << ']' << '[' << to_string(emgData[3]) << ']'
			<< '[' << to_string(emgData[4]) << ']' << '[' << to_string(emgData[5]) << ']'
			<< '[' << to_string(emgData[6]) << ']' << '[' << to_string(emgData[7]) << ']' << endl;
		cout << flush;
	}

	// Print out the orientation raw data
	void printOrient() {
		cout << "X: " << '[' << to_string(orient[0]) << "]  " << "Y: " << '[' << to_string(orient[1]) << "]  " 
			<< "Theta: " << '[' << to_string(orient[2]) << ']' << endl;
		cout << flush;
	}

	// Print out the accelerometer raw data
	void printAccel() {
		cout << "X: " << '[' << to_string(accel[0]) << "]  " << "Y: " << '[' << to_string(accel[1]) << "]  " << "Z: " << '[' << to_string(accel[2]) << "]" << endl;
	}

	// Print out the gyroscope raw data
	void printGyro() {
		cout << "X: " << '[' << to_string(gyro[0]) << "]  " << "Y: " << '[' << to_string(gyro[1]) << "]  " << "Z: " << '[' << to_string(gyro[2]) << "]" << endl;
	}

	// These values are set by onArmSync() and onArmUnsync() above.
	bool onArm;
	myo::Arm whichArm;

	// These values are set by onOrientationData() above
	array<float, 3> orient;
	int roll_w, pitch_w, yaw_w;
	float roll, pitch, yaw, orient_x, orient_y, orient_z, orient_w;
	myo::Quaternion<float> currQuaternion = myo::Quaternion<float>();
	myo::Quaternion<float> orientationOffset = myo::Quaternion<float>();

	// These values are set by onAccel() above
	array<float, 3> accel;

	// These values are set by onGyro() above
	array<float, 3> gyro;

	// The values of this array is set by onEmgData() above
	array<int8_t, 8> emgData;
};

// Checks to see if a file exists in the current directory
inline bool file_exists(string name) {
	ifstream f(name.c_str());
	if (f.good()) {
		f.close();
		return true;
	} else {
		f.close();
		return false;
	}
}

int main(int argc, char** argv) {
	cout << "Myo Custom Gesture Program" << endl;
	myo::Hub hub("com.hcilab.MyoCustomGesture");
	myo::Myo* myo = hub.waitForMyo(10000);

	// Checks for a connected Myo
	if (!myo) {
		throw std::runtime_error("Unable to find a Myo!");
	}

	// Enables EMG streaming on the found Myo
	myo->setStreamEmg(myo::Myo::streamEmgEnabled);

	TimeSeriesClassificationData accelTrainingData;
	TimeSeriesClassificationData orientTrainingData;
	TimeSeriesClassificationData emgTrainingData;
	DTW accelDTW;
	DTW orientDTW;
	DTW emgDTW;
	DataCollector dataCollector;
	hub.addListener(&dataCollector);

	while (1) {
		cout << endl;
		cout << "For Training Press (1)" << endl;
		cout << "For Testing Press (2)" << endl;
		cout << "Exit (3)" << endl;
		cout << endl;
		char userInput;
		while ((userInput = _getch()) != '1' && userInput != '2' && userInput != '3');

		// Training in new gesture data
		if (userInput == '1') {
			cout << "Custom Gesture Training" << endl;

			UINT gestureLabel = 1;
			// Checks to see if there are any saved training data
			if (file_exists("AccelTrainingData.txt") && file_exists("OrientTrainingData.txt") && file_exists("EMGTrainingData.txt")) {
				// If a training set already exists the user can update it with new gestures or 
				// delete it and create a new training set
				cout << "Add onto old training data? (y/n) ";

				char newFile;
				while ((newFile = _getch()) != 'n' && newFile != 'y');
				if (newFile == 'y') {
					cout << 'y' << endl;
					// Load in saved training set
					accelTrainingData.load("AccelTrainingData.txt");
					orientTrainingData.load("OrientTrainingData.txt");
					emgTrainingData.load("EMGTrainingData.txt");
					gestureLabel = int(accelTrainingData.getNumClasses()) + 1;
				} else if (newFile == 'n') {
					cout << 'n' << endl;
					if (remove("AccelTrainingData.txt") != 0 || remove("OrientTrainingData.txt") != 0 || remove("EMGTrainingData.txt") != 0) {
						cout << "Error deleting file" << endl;
						break;
					} else {
						// Remove saved training set and create a new one
						cout << "File successfully deleted." << endl;
						accelTrainingData = TimeSeriesClassificationData();
						accelTrainingData.setDatasetName("Accel_Training_Data");
						accelTrainingData.setInfoText("Gesture_Names:");
						accelTrainingData.setNumDimensions(3);

						orientTrainingData = TimeSeriesClassificationData();
						orientTrainingData.setDatasetName("Orient_Training_Data");
						orientTrainingData.setInfoText("Gesture_Names:");
						orientTrainingData.setNumDimensions(3);

						emgTrainingData = TimeSeriesClassificationData();
						emgTrainingData.setDatasetName("EMG_Training_Data");
						emgTrainingData.setInfoText("Gesture_Names:");
						emgTrainingData.setNumDimensions(8);
					}
					cout << endl;
				}
			} else {
				// No traing set file found, creates a new one
				accelTrainingData = TimeSeriesClassificationData();
				accelTrainingData.setDatasetName("Accel_Training_Data");
				accelTrainingData.setInfoText("Gesture_Names:");
				accelTrainingData.setNumDimensions(3);

				orientTrainingData = TimeSeriesClassificationData();
				orientTrainingData.setDatasetName("Orient_Training_Data");
				orientTrainingData.setInfoText("Gesture_Names:");
				orientTrainingData.setNumDimensions(3);

				emgTrainingData = TimeSeriesClassificationData();
				emgTrainingData.setDatasetName("EMG_Training_Data");
				emgTrainingData.setInfoText("Gesture_Names:");
				emgTrainingData.setNumDimensions(8);
			}

			// Process of creating a new gesture
			while (1) {
				cout << "Enter name of new gesture: ";
				string gestureName;
				cin >> gestureName;
				if (gestureName.size() == 0)
					return 0;

				cout << "Number of times performing: ";
				int numGestures = 0;
				cin >> numGestures;

				VectorFloat accelDataVector(accelTrainingData.getNumDimensions());
				MatrixFloat accelDataMatrix;
				VectorFloat orientDataVector(orientTrainingData.getNumDimensions());
				MatrixFloat orientDataMatrix;
				VectorFloat emgDataVector(emgTrainingData.getNumDimensions());
				MatrixFloat emgDataMatrix;

				while (numGestures--) {
					cout << "Press SPACEBAR to start recording and ESC to stop." << endl;
					while ((_getch()) != VK_SPACE);
					// Continue collecting data until the user presses ESC to stop
					while (!GetAsyncKeyState(VK_ESCAPE)) {
						hub.run(1000 / 10);
						// Check that the Myo is connected and synced
						if (!dataCollector.onArm) {
							cout << "!!!!!!!!!!!!!!Please sync the Myo!!!!!!!!!!!!!!!!!!!!!" << endl;
							return 0;
						}
						dataCollector.printAccel();
						// Adds all sensor data to the dataVector
						for (int sensor = 0; sensor < emgDataVector.size(); sensor++) {
							if (sensor < 3) {
								accelDataVector[sensor] = dataCollector.accel[sensor];
								orientDataVector[sensor] = dataCollector.orient[sensor];
								emgDataVector[sensor] = dataCollector.emgData[sensor];
							} 
							else if (sensor > 2) {
								emgDataVector[sensor] = dataCollector.emgData[sensor];
							}
						}
						// Adds all data to the dataMatrix
						accelDataMatrix.push_back(accelDataVector);
						orientDataMatrix.push_back(orientDataVector);
						emgDataMatrix.push_back(emgDataVector);
					}
						
					cout << "Use recording? (y/n) ";
					char saveData;
					while ((saveData = _getch()) != 'n' && saveData != 'y');

					if (saveData == 'y') {
						accelTrainingData.addSample(gestureLabel, accelDataMatrix);
						accelTrainingData.setClassNameForCorrespondingClassLabel(gestureName, gestureLabel);
						orientTrainingData.addSample(gestureLabel, orientDataMatrix);
						orientTrainingData.setClassNameForCorrespondingClassLabel(gestureName, gestureLabel);
						emgTrainingData.addSample(gestureLabel, emgDataMatrix);
						emgTrainingData.setClassNameForCorrespondingClassLabel(gestureName, gestureLabel);
						cout << endl;
					} else if (saveData == 'n') {
						numGestures++;
						cout << endl;
					}
				}

				// ERROR in GRT SDK where you can't assign a gesture name to the gesture number
				// so instead I save the names in the same order in the training set's info text location
				// used later to recognize what gesture is being performed
				accelTrainingData.setInfoText(accelTrainingData.getInfoText() + "\n" + gestureName);
				orientTrainingData.setInfoText(orientTrainingData.getInfoText() + "\n" + gestureName);
				emgTrainingData.setInfoText(emgTrainingData.getInfoText() + "\n" + gestureName);

				// Use the trainging set to train the Dynamic Time Warping classifier
				if (!accelDTW.train(accelTrainingData)) {
					cerr << "Failed to train classifier!\n";
					return 1;
				}

				// Sets different pre/post processing identifiers for the classifier
				accelDTW.enableNullRejection(true);
				accelDTW.setNullRejectionCoeff(5);
				accelDTW.enableTrimTrainingData(true, 0.1, 90);

				// Save the DTW model to a file
				if (!accelDTW.saveModelToFile("AccelDTWModel.txt")) {
					cerr << "Failed to save the classifier model!\n";
					return 1;
				}

				if (!orientDTW.train(orientTrainingData)) {
					cerr << "Failed to train classifier!\n";
					return 1;
				}
				
				// Sets different pre/post processing identifiers for the classifier
				orientDTW.enableNullRejection(true);
				orientDTW.setNullRejectionCoeff(5);
				orientDTW.enableTrimTrainingData(true, 0.1, 90);

				// Save the DTW model to a file
				if (!orientDTW.saveModelToFile("OrientDTWModel.txt")) {
					cerr << "Failed to save the classifier model!\n";
					return 1;
				}

				if (!emgDTW.train(emgTrainingData)) {
					cerr << "Failed to train classifier!\n";
					return 1;
				}

				// Sets different pre/post processing identifiers for the classifier
				emgDTW.enableNullRejection(true);
				emgDTW.setNullRejectionCoeff(5);
				emgDTW.enableTrimTrainingData(true, 0.1, 90);

				// Save the DTW model to a file
				if (!emgDTW.saveModelToFile("EMGDTWModel.txt")) {
					cerr << "Failed to save the classifier model!\n";
					return 1;
				}

				cout << "Would you like to make another gesture? (y/n) ";
				char continueProg;
				while ((continueProg = _getch()) != 'n' && continueProg != 'y');
				if (continueProg == 'n') {
					accelTrainingData.save("AccelTrainingData.txt");
					orientTrainingData.save("OrientTrainingData.txt");
					emgTrainingData.save("EMGTrainingData.txt");
					break;
				} else {
					gestureLabel++;
				}
				cout << endl;
			}
		} 
		// Real time gesture recognition 
		else if (userInput == '2') {
			cout << "Listening for gestures..." << endl;

			// Load in the saved training data
			if (!accelTrainingData.load("AccelTrainingData.txt")) {
				cout << "ERROR: Failed to load training data from file\n";
				return 1;
			}

			// Load in the saved Dynamic Time Warping model
			if (!accelDTW.load("AccelDTWModel.txt")) {
				cerr << "Failed to load the pipeline model!\n";
				return 1;
			}

			// Load in the saved training data
			if (!orientTrainingData.load("OrientTrainingData.txt")) {
				cout << "ERROR: Failed to load training data from file\n";
				return 1;
			}

			// Load in the saved Dynamic Time Warping model
			if (!orientDTW.load("orientDTWModel.txt")) {
				cerr << "Failed to load the pipeline model!\n";
				return 1;
			}

			// Load in the saved training data
			if (!emgTrainingData.load("EMGTrainingData.txt")) {
				cout << "ERROR: Failed to load training data from file\n";
				return 1;
			}

			// Load in the saved Dynamic Time Warping model
			if (!emgDTW.load("EMGDTWModel.txt")) {
				cerr << "Failed to load the pipeline model!\n";
				return 1;
			}

			// From the training set save all the gesture names into a vector
			vector<string> gesturenames;
			size_t pos = 0;
			string nameList = accelTrainingData.getInfoText();
			string token;
			while ((pos = nameList.find(" ")) != string::npos) {
				token = nameList.substr(0, pos);
				if (token != "Gesture_Names:")
					gesturenames.push_back(token);
				nameList.erase(0, pos + 1);
			}
			
			// Threshold variables
			float armBusyData = 0;
			float emaThreshold = 50;
			float emgThreshold = 0.2;

			while (1) {
				// Query every 10 milliseconds.
				hub.run(1000 / 10);
				// Check that the Myo is connected and synced
				if (!dataCollector.onArm) {
					cout << "!!!!!!!!!!!!!!Please sync the Myo!!!!!!!!!!!!!!!!!!!!!" << endl;
					return 0;
				}
				
				// Calculates constant EMG values to use for a threshold
				array<float, 8> maxPodValues = { 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0 };
				int bufferSize = 0;
				while (bufferSize < 100) {
					for (int index = 0; index < 8; index++) {
						if (maxPodValues[index] < abs(dataCollector.emgData[index])) {
							maxPodValues[index] = abs(dataCollector.emgData[index]);
						}
					}
					bufferSize++;
				}

				// Create an instantanious EMG average
				float emgTotals = 0;
				for (int index = 0; index < 8; index++) {
					emgTotals = emgTotals + maxPodValues[index];
				}
				emgTotals = emgTotals / (8 * 128);

				// Calculate an exponntial moving average of the gyroscope data for the threshold
				// This makes sure in rest position or very small movements are not classified
				float ema = armBusyData + (0.1 * (abs(dataCollector.gyro[0]) + abs(dataCollector.gyro[1]) + abs(dataCollector.gyro[2]) - armBusyData));

				// If movements/EMG are above the threshold start to classify the gesture
				VectorFloat accelTestData(accelTrainingData.getNumDimensions());
				MatrixFloat accelDynamicTestMatrix;
				VectorFloat orientTestData(orientTrainingData.getNumDimensions());
				MatrixFloat orientDynamicTestMatrix;
				VectorFloat emgTestData(emgTrainingData.getNumDimensions());
				MatrixFloat emgDynamicTestMatrix;

				if (ema > emaThreshold || emgTotals > emgThreshold) {
					int bufferSize = 0;
					// Collect data for the average time length of all trained in gestures
					while (bufferSize < accelDTW.averageTemplateLength) {
						for (int sensor = 0; sensor < emgTestData.size(); sensor++) {
							if (sensor < 3) {
								accelTestData[sensor] = dataCollector.accel[sensor];
								orientTestData[sensor] = dataCollector.orient[sensor];
							}
							else if (sensor > 2) {
								emgTestData[sensor] = dataCollector.emgData[sensor];
							}
						}
						accelDynamicTestMatrix.push_back(accelTestData);
						orientDynamicTestMatrix.push_back(orientTestData);
						emgDynamicTestMatrix.push_back(emgTestData);
						bufferSize++;
					}

					// Based on data gathered predit a gesture and get its likelihood
					bool accelPredictionSuccess = accelDTW.predict(accelDynamicTestMatrix);
					UINT accelPredictedClassLabel = accelDTW.getPredictedClassLabel();
					double accelBestLoglikelihood = accelDTW.getMaximumLikelihood();

					if (!accelDTW.predict(accelDynamicTestMatrix)) {
						cerr << "Failed to perform prediction!" << endl;
					}

					if (accelBestLoglikelihood > 0.6 && accelPredictedClassLabel) {
						//cout << "ACCEL: " << to_string(accelBestLoglikelihood) << "  " << gesturenames[accelPredictedClassLabel - 1] << endl;
					}

					// Based on data gathered predit a gesture and get its likelihood
					bool orientPredictionSuccess = orientDTW.predict(orientDynamicTestMatrix);
					UINT orientPredictedClassLabel = orientDTW.getPredictedClassLabel();
					double orientBestLoglikelihood = orientDTW.getMaximumLikelihood();

					if (!orientDTW.predict(orientDynamicTestMatrix)) {
						cerr << "Failed to perform prediction!" << endl;
					}

					if (orientBestLoglikelihood > 0.6 && orientPredictedClassLabel) {
						cout << "ORIENT: " << to_string(orientBestLoglikelihood) << "  " << gesturenames[orientPredictedClassLabel - 1] << endl;
					}

					// Based on data gathered predit a gesture and get its likelihood
					bool emgPredictionSuccess = emgDTW.predict(emgDynamicTestMatrix);
					UINT emgPredictedClassLabel = emgDTW.getPredictedClassLabel();
					double emgBestLoglikelihood = emgDTW.getMaximumLikelihood();

					if (!emgDTW.predict(emgDynamicTestMatrix)) {
						cerr << "Failed to perform prediction!" << endl;
					}

					if (emgBestLoglikelihood > 0.6 && emgPredictedClassLabel) {
						cout << "EMG: " << to_string(emgBestLoglikelihood) << "  " << gesturenames[emgPredictedClassLabel - 1] << endl;
					}

					if (emgBestLoglikelihood > 0.3 && orientBestLoglikelihood > 0.3 && emgPredictedClassLabel == orientPredictedClassLabel) {
						cout << "TOTAL: " << to_string(emgBestLoglikelihood) << "  " << gesturenames[emgPredictedClassLabel - 1] << endl;
					}
				}
				armBusyData = ema;
				
				// Quit with the Esc key.
				if (GetAsyncKeyState(VK_ESCAPE)) break;
			}
		} else if (userInput == '3') {
			/*
			while (1) {
				hub.run(1000 / 10);
				if (!dataCollector.onArm) {
					cout << "!!!!!!!!!!!!!!Please sync the Myo!!!!!!!!!!!!!!!!!!!!!" << endl;
					return 0;
				}
				dataCollector.printOrient();

				if (GetAsyncKeyState(VK_SPACE)) {
					dataCollector.zeroOrientation();
				}
				if (GetAsyncKeyState(VK_ESCAPE)) break;
			}
			while (VK_SPACE != _getch()) {
				return EXIT_SUCCESS;
			}
			*/
			return 0;
		}
	}
}
