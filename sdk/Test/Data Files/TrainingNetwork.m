%% Load data

str_file1 = '0731EricHTherblig';
str_file2 = '0731EricWTherblig';

X_data1 = csvread(strcat(str_file1,'_X.csv'));
y_data1 = csvread(strcat(str_file1,'_y.csv'));

X_data2 = csvread(strcat(str_file2,'_X.csv'));
y_data2 = csvread(strcat(str_file2,'_y.csv'));

X_data = [X_data1, X_data2];
y_data = [y_data1, y_data2];

%X_data = X_data2;
%y_data = y_data2;


%% Create Network

%net = fitnet (9);
net = patternnet(9);


%% Train

net = train (net, X_data, y_data);

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

plotconfusion (y_data, y_pred);


%% Try a decision tree

%% pack data 

np = size(y_data,2);

X = X_data';

Y = zeros(np,1);
for i=1:np
   for j=1:size(y_data,1)
       if (y_data(j,i) == 1)
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

% This yielded an optimal split value ~ 25


%% 
%Test tree

ctree = fitctree(X,Y, 'MaxNumSplits', 10); % create classification tree

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

