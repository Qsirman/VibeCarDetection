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
    
    % get all Connected domains except for holes
    [B,L] = bwboundaries(segmentationMap,'noholes');
    % get max number of kind for all the connnected domains
    max_ = size(B,1);
    % declear a variable for storing a random index
    index = 1;
    % show segmentation image at second subplot
    subplot(2,2,2),imshow(segmentationMap),title('segmentation');
    hold on;
    % check if there is any detection
    if max_ ~= 0
        % handle every single situation independently
        for iii=1:max_
            % get a random index in it's range
            % you must make it ceilling 
            % because it must greater than 0
            index = uint8(ceil(rand()*size(historyBuffer,2)));
            % get boundary ceil
            boundary = B{iii};
            % filter the iii th connected domain
            tempItem = (L == iii);
            % get the background of iii th connected domain
            tempBackground = historyBuffer{index}.*tempItem;
            % get Histogram distribution of item image
            itemRhist = hist(tempItem(:),1:1:256);
            % get Histogram distribution of background image of item
            bgRhist = hist(tempBackground(:),1:1:256);
            % get the Relationship coefficient between the histogram
            % distribution of item image and Histogram distribution 
            % of background image of item
            g = corrcoef(itemRhist ,bgRhist);
            % in expriment, I found if it's ghost, it's Relationship 
            % coefficient are almost all greater than 0.999
            % which is really big but really works
            if g(1,2) > 0.9999
                % to get its row and col range
                row = boundary(:,2);
                col = boundary(:,1);
                % try not to make it out of normal range
                row(row<=0) = 1;
                col(col<=0) = 1;
                row(row > param.height) = param.height;
                col(col > param.width) = param.width;
                % update its pixels to the background
                historyBuffer{index}(row,col) = vidFrame(row,col);
                
            end
            % display the kind number and Relationship coefficient
            % disp([iii,g(1,2)]);
            % display the kind number in the connected domain in the plot
            % to display better, random it's loation around the range
            rndRow = ceil(length(boundary)/(mod(rand*iii,7)+1));
            col = boundary(rndRow,2); row = boundary(rndRow,1);
            h = text(col+1, row-1, num2str(L(row,col)));
            set(h,'Color','m','FontSize',14,'FontWeight','bold');
        end
    end
    % end of timing
    toc;
    subplot(1,2,2),imshow(segmentationMap),title('segmentationMap');
end