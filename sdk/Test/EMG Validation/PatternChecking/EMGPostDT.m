% Testing a Decision tree on EMG data


trainset = csvread('FullDTset/trainset.csv');
testset = csvread('FullDTset/testset.csv');

plotset= csvread('FullDTset/plotset.csv');

num_col = size(trainset,2);

 
X = trainset(:,1:num_col-1);
Y = trainset(:,num_col);

%% Cross Validate for number of splits 
% This is easier than trying to guess a minimum leaf size

% rng('default');
% N = 50; % up to 50 splits
% splits = linspace(1,N,N);
% err = zeros(N,1);
% for n=1:N
%     t = fitctree(X,Y,'CrossVal','On',...
%         'MaxNumSplits', n);
%     err(n) = kfoldLoss(t);
% end
% plot(splits,err);
% xlabel('Split Size');
% ylabel('cross-validated error');

% This yielded an optimal split value between 20-25


%% Generate the tree

ctree = fitctree(X,Y, 'MaxNumSplits', 20); % create classification tree

view(ctree,'mode','graph'); % graphic description

% Test tree accuracy 
y_p = predict(ctree, testset(:,1:8));

% See accuracy

counter = 0;

for i=1:size(testset,1)
   if y_p(i) == testset(i,num_col)
      counter=counter+1;
   end
end

Accuracy = counter/size(testset,1);

%% Plot for an example plotset
% Generated in EMGLabeled.m 

%% See what happens when you post-process the decision tree


y_p = predict(ctree, plotset(:,1:8));
truth = plotset(:,num_col);

length=size(y_p,1); 
x = linspace(1, length/200, length);


% Show the decision without boxcar averaging
figure;
plot(x,y_p);
title('Decision Tree results before boxcar averaging')
xlabel('time (s)');
ylabel('Exertion boolean');

% Show result with boxcar averaging

samples = 40;

% Round down
length_b = floor(length/samples); % 200 Hz to 20 Hz 
y_pb = zeros(1, length_b);

%Average every n samples 
for i=1:length_b
   y_pb(i) = round(mean(y_p(samples*(i-1)+1:samples*(i-1)+samples)));
    
end

x_b = linspace(1, length_b/(200/samples), length_b);

figure;
plot(x_b, y_pb);
title('Decision Tree results after boxcar averaging')
xlabel('time (s)');
ylabel('Exertion boolean');


