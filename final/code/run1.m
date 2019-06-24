% this is a main "function" file
% so you just need to ensure that you are at the correct folder and just
% type run

% clear to clean all the variables in Workspace in case of interruption
% clc to clean the output show, it's not necessary
% close all to close all figures, it's not necessary either.
clear; clc; close all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initiate Parameters
% Initial sample numbers is 10
param.numberOfSamples           = 10;
% Initial matching theshold is 10
param.matchingThreshold         = 10;
% Initial matching number is 2
param.matchingNumber            = 2;
% Initial update factor is 5, can't be too great
param.updateFactor              = 5;
% Initial history images number is 2
param.numberOfHistoryImages     = 2;
% Initial swapped histroy image is 0
param.lastHistoryImageSwapped   = 0;

% read a video as input
% it must be placed at the same directory with this file
filename = 'video.avi';

% read one frame first.
vidObj = VideoReader(filename);

% a flag variable to flag the first time to initiate
firstFrame = true;

% get frame's size
height = vidObj.Height;
width = vidObj.Width;

% store frame's size info into parameter
param.height = height;
param.width = width;

% frame counter, just to show debug infomation
frame = 0;

% show figure 1 window
% you'd better put it out of the loop to speed scope up
figure(1)

% Moving object detection till the video ends up
while hasFrame(vidObj)
    % count for frame
    frame = frame + 1;
    % read an another new frame
    vidFrame = readFrame(vidObj);
    % it's just for debug
    % because 1 to 64 frames are nothing
    % just for time reducing
    if frame < 55
        continue;
    end
    % create a 2 by 2 suplots
    % show original image at first subplot
    drawnow
    subplot(1,2,1), imshow(vidFrame),title('original');
    % shou frame number at coordinate (10, 10)
    text(10,10,num2str(frame));
    % trans RGB to gray for more conenient operation
    vidFrame = rgb2gray(vidFrame);
    % for more precision, make it double
    vidFrame = double(vidFrame);
    
    % start timing
    tic;
    % if it is the first frame
    % then initiate the Vibe model first
    if firstFrame
        firstFrame = false;
        initViBe;
    end
    % use threshold to get segmentation
    % be careful, this function input a double matrix and output an uint8
    % one instead
    segmentationMap = vibeSegmentation(vidFrame, historyImages, historyBuffer, param);    
    % update background model
    [historyImages, historyBuffer] = vibeUpdate(vidFrame, segmentationMap, historyImages, historyBuffer, param, ...
        jump, neighborX, neighborY, position);
    % to get a better vision, make segmentation binary
    segmentationMap = medfilt2(segmentationMap);
    % end of timing
    toc;
    subplot(1,2,2),imshow(segmentationMap),title('segmentationMap');
end