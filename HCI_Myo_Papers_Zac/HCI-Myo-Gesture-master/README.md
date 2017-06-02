# HCI Myo Gesture

This is a repository for general gesture recognition for the UW-Madison HCI Lab

##Myo Armband

The Myo armband connects to a computer using Bluetooth 4.0 Low Energy to transfer data about its nine-axis IMUs 
(three-axis gyroscope, three-axis accelerometer, three-axis magnetometer). It provides two kinds of data to an 
application, spatial data and gestural data.  

**Spatial Data**  
* An orientation represents which way the Myo armband is pointed. Provided as a quaternion that can be converted 
  to rotation matrix or Euler angles. (Our gesture recognition program converts to Euler angles for most cases)   
  
**Gestural data**
* Tells what the user is doing with their hands, based on muscle movements sensed in their arm. The raw data is in 
  the form EMG (Electromyography) form all 8 sensors of the Myo.


##Train Gesture Program
Machine learning program that recognizes two seperate forms of gestures: static and dynamic.

###Static Gestures  
Recognizes EMG data for a still physical hand gesture. Currently uses Adaptive Naive Bayes Classifier (ANBC) to train
in new hand gestures as well as recognize train gestures in real time. This supervised learning algorithm takes in 
an 8-dimensional vector signal that represents the raw EMG data from all 8 Myo sensors. Works well with complex hand 
gestures by fitting an 8-dimensional Gaussian distribution to each gesture during the training phase. New gestures can 
then be recognized in the prediction phase by finding the gesture that results in the maximum likelihood value. It also 
computes rejection thresholds that enable the algorithm to automatically reject sensor values that are not any of the 
gestures the algorithm has been trained to recognized.

###Dynamic Gestures  
Recognizes both acceleromiter and gyroscope data to track a users gesture as they move their arm. Currently uses Dynamic 
Time Warping (DTW) classifier for training arm movements. This supervised learning algorithm takes in a 6-dimensional 
vector signal that represents the raw three-axis accelerometer and three-axis gyroscope. This is taken many times during 
the length of the gesture to create a matrix of all vector calculations. This algorithm works by creating a template time 
series for each gesture that needs to be recognized, and then warping the realtime signals to each of the templates to 
find the best match. Similar to ANBC it also computes rejection thresholds that enable the algorithm to automatically reject sensor values that are not any of the 
gestures the algorithm has been trained to recognized.


##Process Gesture 
This class is used to test the current training set. It creates a dynamic time warping classifier and allows for adding both pre and post processing modules to the classifier. It partitions the training data into 80% for training and 20% for testing. Then it tests the classifier and calculates its accuracy.


###Errors
* Biggest error right now is calibrating the data for movement in the Myo armband after training has occured. Currently 
  real time gesture recognition will only work if the user trains and test the data while the Myo is in the exact same
  orientation and placement on their arm.
  * Working on syncing data and Myo when user puts armband on again or moves it on their arm.
  * Creating listener for SyncMyo() to calibrate at each Myo sync   
  
###To Do
  * Fine tune dynamic gesture recognition with pre/post processing modules for more acurate recognition

