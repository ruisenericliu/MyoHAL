% Testing a Decision tree on EMG data

n = 40; % # of averaged samples - from EMGLabelBoxCar.m

trainset = csvread('AveragedDTset/trainset.csv');
testset = csvread('AveragedDTset/testset.csv');

plotset= csvread('AveragedDTset/plotset.csv');

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
% figure;
% plot(splits,err);
% xlabel('Split Size');
% ylabel('cross-validated error');

% This yielded an optimal split value ~ 25


%% Generate the tree

ctree = fitctree(X,Y, 'MaxNumSplits', 25); % create classification tree

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

y_p = predict(ctree, plotset(:,1:8));
truth = plotset(:,num_col);

length=size(y_p,1); 
x = linspace(1, length/(200/n), length);

figure;
plot(x,y_p);
title('Results from Decision Tree built from averaged data')
xlabel('time (s)');
ylabel('Exertion boolean');

