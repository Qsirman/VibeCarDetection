%% Parameters
numberOfSamples         = param.numberOfSamples;
matchingThreshold       = param.matchingThreshold;
matchingNumber          = param.matchingNumber;
updateFactor            = param.updateFactor;
numberOfHistoryImages   = param.numberOfHistoryImages;

%% Initialize ViBe
historyImages = cell(1, numberOfHistoryImages);
for ii = 1:length(historyImages)
    historyImages{ii} = vidFrame;
end

historyBuffer = cell(1, numberOfSamples - numberOfHistoryImages);
for ii = 1:length(historyBuffer)
    historyBuffer{ii} = vidFrame + double(floor(rand(height, width))*20 - 10);
end

%% Random Part
size_ = 2*max(height, width) + 1;
% jump[] from 1 to 2*updateFactor
jump = floor(rand(1, size_)*2*updateFactor) + 1;
% neighborX, Y represent the neighbor index
neighborX = floor(rand(1, size_)*3) - 1;
neighborY = floor(rand(1, size_)*3) - 1;
% position[] from 1 to numberOfSamples
position = floor(rand(1, size_)*numberOfSamples) + 1;

disp('Initialize ViBe')