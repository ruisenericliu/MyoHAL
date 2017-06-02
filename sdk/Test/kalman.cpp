/**
 * Kalman.cpp - implementation of a Kalman Filter.
 * Ruisen (Eric) Liu
 * UW-Madison, 2017
 */

#include <iostream>
#include <stdexcept>
#include "kalman.h"


KalmanFilter::KalmanFilter(
			   const Eigen::MatrixXd& A,
			   const Eigen::MatrixXd& C,
			   const Eigen::MatrixXd& P,
			   const Eigen::MatrixXd& Q,
			   const Eigen::MatrixXd& R,
			   double dt
			   ) : A(A), C(C), P(P), Q(Q), R(R), dt(dt),
			     haveState(false),m(C.rows()), n(A.rows()),
			     x_pre(n), x_post(n), I(n,n)
{
  I.setIdentity();
}

KalmanFilter::KalmanFilter() {}

void KalmanFilter::setState(double t_init, const Eigen::VectorXd& x_init) {
  x_post = x_init;
  t = t_init;
  haveState = true;
}

void KalmanFilter::update(const Eigen::VectorXd& y) {

  if(!haveState){
    throw std::runtime_error("Cannot update: No state initialized for Kalman Filter!");
  }

  // motion update
  x_pre = A * x_post;
  P = A*P*A.transpose() + Q;

  // measurement update
  K = P*C.transpose()*(C*P*C.transpose() + R).inverse();
  x_post = x_pre + K * ( y - C*x_pre);
  P = (I - K*C)*P;

  // time update
  t += dt;
  
}

