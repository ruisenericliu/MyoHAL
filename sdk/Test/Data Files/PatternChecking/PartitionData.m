% Partitioning data randomly for machine learning

data = csvread('FiltNLabeled.csv');

num_row = size(data,1);
num_col = size(data,2);


% Divide data into train/test set
trainRatio = 0.8;
valRatio = 0.0;
testRatio = 0.2;

[trainInd,valInd,testInd] = dividerand(num_row,trainRatio,valRatio,testRatio);


% Create train and test set 
testset = zeros(size(testInd,2),num_col);

for i=1:size(testInd,2)
    testset(i,:) =  data(testInd(i),:);
end

trainset = zeros(size(testInd,2),num_col);

for i=1:size(trainInd,2)
    trainset(i,:) =  data(trainInd(i),:);
end

csvwrite('trainset.csv',trainset);
csvwrite('testset.csv',testset);
