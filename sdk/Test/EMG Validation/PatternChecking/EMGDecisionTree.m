% Testing a Decision tree on EMG data

trainset = csvread('trainset.csv');
testset = csvread('testset.csv');

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



%% Cross Validate by minimum leaf size (?)
% Will not try at the moment -105,000 data points


%%

ctree = fitctree(X,Y, 'MaxNumSplits', 20); % create classification tree

view(ctree,'mode','graph'); % graphic description

y_p = predict(ctree, testset(:,1:8));

% See accuracy

counter = 0;

for i=1:size(testset,1)
   if y_p(i) == testset(i,num_col)
      counter=counter+1;
   end
end

Accuracy = counter/size(testset,1);