// Copyright (C) 2013-2014 Thalmic Labs Inc.
// Distributed under the Myo SDK license agreement. See LICENSE.txt for details.
#define _USE_MATH_DEFINES
#include <cmath>
#include <iostream>
#include <iomanip>
#include <stdexcept>
#include <string>
#include <algorithm>
#include<fstream>
#include <array>


// Stuff for Kalman filters
#include <vector>
#include <Eigen/Dense>
#include "kalman.h"

// The only file that needs to be included to use the Myo C++ SDK is myo.hpp.
#include <myo/myo.hpp>

const double GRAVITY = 9.80665;
int counter = 0;

std::ofstream accelOutFile;
std::ofstream emgOutFile;
std::ofstream quatOutFile;
std::ofstream rollOutFile;
std::string accelFile  = "accel.csv";
std::string EMGFile = "emg.csv";
std::string quatFile = "quat.csv";
std::string rollFile = "roll.csv";

// Classes that inherit from myo::DeviceListener can be used to receive events from Myo devices. DeviceListener
// provides several virtual functions for handling different kinds of events. If you do not override an event, the
// default behavior is to do nothing.
class DataCollector : public myo::DeviceListener {
public:
    DataCollector()
    : onArm(false), isUnlocked(false), roll_w(0), pitch_w(0), yaw_w(0), currentPose()
    {
      calibrated = false;
    }

    // onUnpair() is called whenever the Myo is disconnected from Myo Connect by the user.
    void onUnpair(myo::Myo* myo, uint64_t timestamp)
    {
        // We've lost a Myo.
        // Let's clean up some leftover state.
        roll_w = 0;
        pitch_w = 0;
        yaw_w = 0;
        onArm = false;
        isUnlocked = false;
    }

  void writePosData(){
    //accelOutFile
    accelOutFile << GRAVITY*rawAccel.x() << "," << GRAVITY*rawAccel.y() << "," << GRAVITY*rawAccel.z() << std::endl;
    //quatFile
    quatOutFile << std::fixed << std::setprecision(8) << orientation.w()  << "," << orientation.x()  << "," << orientation.y()  << "," << orientation.z() <<  std::endl;
    // rollFile
    rollOutFile <<  std::fixed << std::setprecision(4) << roll_w  << "," << pitch_w  << "," << yaw_w << std::endl;
    
  }


  // Allegedly, frequency of IMU data is 50 Hz,
  // frequency of EMG data is 200 Hz.
  
  // onEmgData() is called whenever a paired Myo has provided new EMG data, and EMG streaming is enabled.
  void onEmgData(myo::Myo* myo, uint64_t timestamp, const int8_t* emg) {
    for (int i = 0; i < 8; i++) {
		  emgData[i] = emg[i];
    }
    writeEmgData();

  }

  
  void writeEmgData(){
    emgOutFile << std::to_string(emgData[0]) << "," << std::to_string(emgData[1]) << "," << std::to_string(emgData[2]) << "," <<
      std::to_string(emgData[3]) << "," << std::to_string(emgData[4]) << "," <<  std::to_string(emgData[5]) << "," <<
      std::to_string(emgData[6]) << "," << std::to_string(emgData[7]) << std::endl;
  }

  void calibrate(){
    myo::Quaternion<float> desiredQuat = myo::Quaternion<float>(0.0, 0.7071, 0.0, 0.7071); // x, y, z, w, for some odd reason

    myo::Quaternion<float> conj = orientation.conjugate();

    relQuat = conj.operator*(desiredQuat);

    // test example
    myo::Quaternion<float> test = relQuat.operator*(orientation);

     using std::atan2;
     using std::asin;
     using std::sqrt;
     using std::max;
     using std::min;

    float roll = atan2(2.0f * (test.w() * test.x() + test.y() * test.z()),
                           1.0f - 2.0f * (test.x() * test.x() + test.y() * test.y()));
    float pitch = asin(max(-1.0f, min(1.0f, 2.0f * (test.w() * test.y() - test.z() * test.x()))));
    float yaw = atan2(2.0f * (test.w() * test.z() + test.x() * test.y()),
                        1.0f - 2.0f * (test.y() * test.y() + test.z() * test.z()));

    float test1 = roll*180/3.14; 
    float test2 = pitch*180/3.14; 
    float test3  = yaw*180/3.14;;


    std::cout << "quat x: " << test.x() << std::endl;
    std::cout << "quat y: " << test.y() << std::endl;
    std::cout << "quat z: " << test.z() << std::endl;
    std::cout << "quat w: " << test.w() << std::endl;
    std::cout << "roll: " << test1  << std::endl;
    std::cout << "pitch: " << test2  << std::endl;
    std::cout << "yaw: " << test3  << std::endl;

    calibrated = true;

    
  }

  void onAccelerometerData(myo::Myo *myo, uint64_t timestamp, const myo::Vector3< float > &accel) {
    rawAccel = accel; // in units of gravity

    accelOutFile << GRAVITY*rawAccel.x() << "," << GRAVITY*rawAccel.y() << "," << GRAVITY*rawAccel.z() << std::endl;

    counter++;

    
    // adjust to m/s^2
    Accel =  myo::Vector3<float>(GRAVITY*rawAccel.x(),GRAVITY*rawAccel.y(), GRAVITY*rawAccel.z() );

    Accel = myo::rotate(orientation, Accel); // adjust to orientation
    // drop effect of gravity
    Accel =  myo::Vector3<float>(Accel.x(),Accel.y(), Accel.z() - GRAVITY); 
    
  }

    // onOrientationData() is called whenever the Myo device provides its current orientation, which is represented
    // as a unit quaternion.
    void onOrientationData(myo::Myo* myo, uint64_t timestamp, const myo::Quaternion<float>& quat)
    {
        using std::atan2;
        using std::asin;
        using std::sqrt;
        using std::max;
        using std::min;

	orientation = quat;

	// if we have calibrated, we can adjust by the relative quaternion
	
	if (calibrated){
	   orientation = orientation.operator*(relQuat);
	}
	

	// test validation
	
        // Calculate Euler angles (roll, pitch, and yaw) from the unit quaternion.
        float roll = atan2(2.0f * (orientation.w() * orientation.x() + orientation.y() * orientation.z()),
                           1.0f - 2.0f * (orientation.x() * orientation.x() + orientation.y() * orientation.y()));
        float pitch = asin(max(-1.0f, min(1.0f, 2.0f * (orientation.w() * orientation.y() - orientation.z() * orientation.x()))));
        float yaw = atan2(2.0f * (orientation.w() * orientation.z() + orientation.x() * orientation.y()),
                        1.0f - 2.0f * (orientation.y() * orientation.y() + orientation.z() * orientation.z()));

        roll_w = roll*180/3.14; 
	pitch_w = pitch*180/3.14; 
	yaw_w = yaw*180/3.14;;
    }


    // onArmSync() is called whenever Myo has recognized a Sync Gesture after someone has put it on their
    // arm. This lets Myo know which arm it's on and which way it's facing.
    void onArmSync(myo::Myo* myo, uint64_t timestamp, myo::Arm arm, myo::XDirection xDirection, float rotation,
                   myo::WarmupState warmupState)
    {
        onArm = true;
        whichArm = arm;
    }

    // onArmUnsync() is called whenever Myo has detected that it was moved from a stable position on a person's arm after
    // it recognized the arm. Typically this happens when someone takes Myo off of their arm, but it can also happen
    // when Myo is moved around on the arm.
    void onArmUnsync(myo::Myo* myo, uint64_t timestamp)
    {
        onArm = false;
    }

    // onUnlock() is called whenever Myo has become unlocked, and will start delivering pose events.
    void onUnlock(myo::Myo* myo, uint64_t timestamp)
    {
        isUnlocked = true;
    }

    // onLock() is called whenever Myo has become locked. No pose events will be sent until the Myo is unlocked again.
    void onLock(myo::Myo* myo, uint64_t timestamp)
    {
        isUnlocked = false;
    }

    // There are other virtual functions in DeviceListener that we could override here, like onAccelerometerData().
    // For this example, the functions overridden above are sufficient.

  void testPrint(){


    std::cout << "roll: " << roll_w << std::endl;
    std::cout << "pitch: " << pitch_w << std::endl;
    std::cout << "yaw: " << yaw_w << std::endl;

    //std::cout << "quat x: " << orientation.x() << std::endl;
    //std::cout << "quat y: " << orientation.y() << std::endl;
    //std::cout << "quat z: " << orientation.z() << std::endl;
    //std::cout << "quat w: " << orientation.w() << std::endl;

    //std::cout << "rawAccel x: " << GRAVITY*rawAccel.x() << std::endl;
    //std::cout << "rawAccel y: " << GRAVITY*rawAccel.y() << std::endl;
    //std::cout << "rawAccel z: " << GRAVITY*rawAccel.z() << std::endl;

    //std::cout << "Accelx: " << Accel.x() << std::endl;
    //std::cout << "Accely: " << Accel.y() << std::endl;
    //std::cout << "Accelz: " << Accel.z() << std::endl;
    
  }


    // We define this function to print the current values that were updated by the on...() functions above.
    void print()
    {
      std::cout << '\r';  // clear line

        // Print out the orientation. Orientation data is always available, even if no arm is currently recognized.
        std::cout << '[' << std::string(roll_w, '*') << std::string(18 - roll_w, ' ') << ']'
                  << '[' << std::string(pitch_w, '*') << std::string(18 - pitch_w, ' ') << ']'
                  << '[' << std::string(yaw_w, '*') << std::string(18 - yaw_w, ' ') << ']';

        if (onArm) {
            // Print out the lock state, the currently recognized pose, and which arm Myo is being worn on.

            // Pose::toString() provides the human-readable name of a pose. We can also output a Pose directly to an
            // output stream (e.g. std::cout << currentPose;). In this case we want to get the pose name's length so
            // that we can fill the rest of the field with spaces below, so we obtain it as a string using toString().
            std::string poseString = currentPose.toString();

            std::cout << '[' << (isUnlocked ? "unlocked" : "locked  ") << ']'
                      << '[' << (whichArm == myo::armLeft ? "L" : "R") << ']'
                      << '[' << poseString << std::string(14 - poseString.size(), ' ') << ']';
        } else {
            // Print out a placeholder for the arm and pose when Myo doesn't currently know which arm it's on.
            std::cout << '[' << std::string(8, ' ') << ']' << "[?]" << '[' << std::string(14, ' ') << ']';
        }

        std::cout << std::flush;
    }


  /* Variables  */
  
  // These values are set by onArmSync() and onArmUnsync() above.
  bool onArm;
  myo::Arm whichArm;
  
  // This is set by onUnlocked() and onLocked() above.
  bool isUnlocked;
  
  // These values are set by onOrientationData()
  float roll_w, pitch_w, yaw_w; 
  myo::Pose currentPose;

  //data from Armband
  myo::Vector3<float> rawAccel;
  myo::Vector3<float> Accel;
  myo::Quaternion<float> orientation;

  // adjustment quaternion
  myo::Quaternion<float> relQuat;
  bool calibrated;

  //EMG Data
  std::array<int8_t, 8> emgData;

};




int main(int argc, char** argv)
{
    // catch exceptions
    try {

    // First, we create a Hub with our application identifier. Be sure not to use the com.example namespace when
    // publishing your application. The Hub provides access to one or more Myos.
    myo::Hub hub("com.example.hello-myo");

    std::cout << "Attempting to find a Myo..." << std::endl;

    // find Myo.
    myo::Myo* myo = hub.waitForMyo(10000); //timeout, in milliseconds

    // throw if not found
    if (!myo) {
        throw std::runtime_error("Unable to find a Myo!");
    }

    // We've found a Myo.
    std::cout << "Connected to a Myo armband!" << std::endl << std::endl;

    // construct instance of DeviceListener
    DataCollector collector;

    // Hub::addListener() takes the address of any object whose class inherits from DeviceListener, and will cause
    // Hub::run() to send events to all registered device listeners.
    hub.addListener(&collector);


    // Enables EMG streaming on the found Myo
    myo->setStreamEmg(myo::Myo::streamEmgEnabled);


    std::cout << "Collecting EMG and Acceleration Data!" << std::endl;
    
    emgOutFile.open(EMGFile);
    accelOutFile.open(accelFile);

    int seconds = 60;
    hub.run(seconds*1000); // run for n milliseconds - this timing is accurate
    // for some reason, for short windows, EMG data is undersampled, but not IMU data is not

    // The following method accumulatees delay for long periods of run time
    // something to keep in mind for the future
    // for example, expected: 60 seconds, result: 62.4 seconds 
    /*
    float dt = 1.0/50; // update 50 times a second
    float hub_t = 1000*dt; // convert to milliseconds
    int i = 0;
    while (i < 3000) {  //look at dt for update rate
      hub.run(hub_t);
      i++;
    }
    */
       
    
    emgOutFile.close();
    accelOutFile.close();

    std::cout << counter << std::endl;

    std::cout << "Finished!" << std::endl;

    

    // test calibration
    /*
    while (i < 1) {
      i++;
      hub.run(hub_t); // update 20 times a second
      collector.testPrint();
      collector.calibrate();

    }

    std::cout << " we are now calibrated!: \n \n " << std::endl;

    */

    
    // Collect test data for stationary 

    /*
    accelOutFile.open(accelFile);
    emgOutFile.open(EMGFile);
    quatOutFile.open(quatFile);
    rollOutFile.open(rollFile);

    int i = 0;
    while (i < 20) {
      i++;
      hub.run(hub_t); // update 20 times a second
       collector.writePosData();
    }
    accelOutFile.close();
    quatOutFile.close();
    rollOutFile.close();

    */

    
    /*
    i = 0;
     while (i < 10) {
      i++;
      hub.run(hub_t); // update 20 times a second
      //collector.print();
      collector.testPrint();
    }
    */
    


    // If a standard exception occurred, we print out its message and exit.
    } catch (const std::exception& e) {
        std::cerr << "Error: " << e.what() << std::endl;
        std::cerr << "Press enter to continue.";
        std::cin.ignore();
        return 1;
    }
}
