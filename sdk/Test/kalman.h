/**
 *  Kalman.h
 *  Ruisen (Eric) Liu
 *  UW-Madison, 2017
 */

#include <Eigen/Dense>

class KalmanFilter{

 public:

  /* Let:
   * A - State Dynamics Matrix 
   * C - Output Matrix 
   * P - Estimate error covariance matrix
   * Q - Motion State noise covariance matrix
   * R - Measurement noise covariance matrix 
   * dt - time step
   */

  KalmanFilter(
	       const Eigen::MatrixXd& A,
	       const Eigen::MatrixXd& C,
	       const Eigen::MatrixXd& P,
	       const Eigen::MatrixXd& Q,
	       const Eigen::MatrixXd& R,
	       double dt
  );

  // default constructor
  KalmanFilter();
  
  // set the Kalman filter to a particular state
  void setState(double t_init, const Eigen::VectorXd& x_init);

  // update the Kalman filter with a measurment
  void update(const Eigen::VectorXd& y);

  // get the current State
  Eigen::VectorXd getState() {return x_post;};

  // get the current Time 
  double getTime() { return t; };


  
 private: 

 
  // Matrices
  // Let I be the identity matrix 
  Eigen::MatrixXd A, C, P, Q, R, K;

  // time related material
  double t, dt;
  
   // check for existing default state
  bool haveState;

  // matrix dimensions
  int m, n;

  // estimated states
  Eigen::VectorXd x_pre, x_post;

  // Identity Matrix
  Eigen::MatrixXd I;

};
