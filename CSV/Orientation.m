% Plot Values 

raw_accel = csvread('accelStill.csv');
orientation = csvread('quatStill.csv');
euler = csvread('rollStill.csv');

t = linspace(1,20, 20);

% acceleration
a_x_bar = mean(raw_accel(:,1));
a_y_bar = mean(raw_accel(:,2));
a_z_bar = mean(raw_accel(:,3));

a_mag = sqrt(a_x_bar^2 + a_y_bar^2 + a_z_bar);

figure(1);
hold on;
plot (t, raw_accel(:,1)); 
plot (t, raw_accel(:,2));
plot (t, raw_accel(:,3));
title('Raw Acceleration Vector - Stationary');
ylabel('m/s^2');
legend('Ax', 'Ay', 'Az');
hold off;


% Orientation
o_w_bar = mean(orientation(:,1));
o_x_bar = mean(orientation(:,2));
o_y_bar = mean(orientation(:,3));
o_z_bar = mean(orientation(:,4));

figure(2);
hold on;
plot (t, orientation(:,1)); 
plot (t, orientation(:,2)); 
plot (t, orientation(:,3)); 
plot (t, orientation(:,4));
title('Orientation Quaternion - Stationary');
legend('Ow', 'Ox', 'Oy', 'Oz');
hold off;


% Euler Angles 
roll_bar = mean(euler(:,1));
pitch_bar = mean(euler(:,2));
yaw_bar = mean(euler(:,3));

figure(3);
hold on;
plot (t, euler(:,1)); 
plot (t, euler(:,2));
plot (t, euler(:,3));
title('Euler Angles - Stationary')
legend('Roll', 'Pitch', 'Yaw');
hold off;


