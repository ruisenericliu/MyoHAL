%% Load data
clear;

% Load subset of Eric's data;

addPerson = true; % add Krittisak's data
first=1;
last=3;

X_data=[];
Y_data=[];

for i=first:last

%     if i~=8 % 8 was the calibration dataset
%     
%     folder_name = strcat('08181/0818E',num2str(i));
%     str_file = strcat('0818E', num2str(i));
% 
%     temp_X = csvread(strcat(folder_name,'/',str_file,'_X_full.csv'));
%     temp_Y = csvread(strcat(folder_name,'/',str_file,'_Y_full.csv'));
% 
%     X_data = [X_data, temp_X];
%     Y_data = [Y_data, temp_Y];
%     end

end

if (addPerson)
    for i=first:last

        if i~=8 % 8 was the calibration dataset
    
        folder_name = strcat('08181/0818E',num2str(i));
        str_file = strcat('0818E', num2str(i));

        temp_X = csvread(strcat(folder_name,'/',str_file,'_X_full.csv'));
        temp_Y = csvread(strcat(folder_name,'/',str_file,'_Y_full.csv'));

        X_data = [X_data, temp_X];
        Y_data = [Y_data, temp_Y];
        end
    end
end



%% Create Network

%net = fitnet (9);
net = patternnet(9);


%% Train

net = train (net, X_data, Y_data);

%% Predict the outputs

y_pred = net (X_data);

numExamples = size (y_pred, 2);
for i=1:numExamples
    temp = zeros (size (y_pred, 1), 1);
    [M, I] = max (y_pred (:, i));
    temp (I) = 1;
    y_pred (:, i) = temp;
end

%% Calculate the error rate

figure(1);
plotconfusion (Y_data, y_pred);


%% Try a decision tree

%% pack data 

np = size(Y_data,2);

X = X_data';

Y = zeros(np,1);
for i=1:np
   for j=1:size(Y_data,1)
       if (Y_data(j,i) == 1)
          Y(i) = j; 
       end
   end
end

%% Cross Validate for number of splits 
%This is easier than trying to guess a minimum leaf size

% rng('default');
% N = 50; % up to 50 splits
% splits = linspace(1,N,N);
% err = zeros(N,1);
% for n=1:N
%     t = fitctree(X,Y,'CrossVal','On',...
%         'MaxNumSplits', n);
%     err(n) = kfoldLoss(t);
% end
% figure;
% plot(splits,err);
% xlabel('Split Size');
% ylabel('cross-validated error');

%% 
%Test tree

ctree = fitctree(X,Y, 'MaxNumSplits', 20); % create classification tree

%view(ctree,'mode','graph'); % graphic description

% Test tree accuracy 
y_p = predict(ctree, X);

% See accuracy

counter = 0;

for i=1:np
   if y_p(i) == Y(i)
      counter=counter+1;
   end
end

Accuracy_tree = counter/np;


%% Test training network/tree on a singular dataset 

test = 1;
folder_name = strcat('08181/0818E',num2str(test));
str_file = strcat('0818E', num2str(test));

temp_X = csvread(strcat(folder_name,'/',str_file,'_X_full.csv'));
temp_Y = csvread(strcat(folder_name,'/',str_file,'_Y_full.csv'));

X = temp_X';
Y = temp_Y';



y_p = predict(ctree, X)-1;

figure(10);
plot(y_p);

% Show result with boxcar averaging

length=size(y_p,1); 

samples = 9; %10 samples has bias with rounding! 

% Round down
length_b = floor(length/samples);  
y_pb = zeros(1, length_b);

%Average every n samples 
for i=1:length_b
   y_pb(i) = round(mean(y_p(samples*(i-1)+1:samples*(i-1)+samples)));
    
end

x_b = linspace(1, length_b, length_b);

DC = sum(y_pb)/length_b;

figure(11);
plot(x_b,y_pb);
title('Decision Tree results after boxcar averaging')
xlabel('time (s)');
ylabel('Exertion boolean');

%% HAL Equation - for future use
% HAL = 6.56*log(D)*(F^1.31/(1+ 3.18*F^1.31))

