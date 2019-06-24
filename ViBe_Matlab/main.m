clear; clc; close all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: Brilliantdo
% Last modified time : 2016/12/1
% Blog: http://blog.csdn.net/brilliantdo
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Parameters
param.numberOfSamples           = 10;
param.matchingThreshold         = 10;
param.matchingNumber            = 2;
param.updateFactor              = 5;
param.numberOfHistoryImages     = 2;
param.lastHistoryImageSwapped   = 0;

%% Video Information
filename = 'video.avi';
vidObj = VideoReader(filename);

firstFrame = true;
height = vidObj.Height;
width = vidObj.Width;

param.height = height;
param.width = width;

frame = 0;

%% ViBe Moving Object Detection
figure(1)
while hasFrame(vidObj)
    frame = frame + 1;
    
    % ????
    vidFrame = readFrame(vidObj);
    % ??????
    if frame < 55
        continue;
    end
    drawnow
    subplot(2,2,1), imshow(vidFrame),title('original');
    text(10,10,num2str(frame));
    % ?RGB??????????double
    vidFrame = rgb2gray(vidFrame);
    vidFrame = double(vidFrame);

    tic;
    % ??????????VIBE??
    if firstFrame
        firstFrame = false;
        initViBe;
    end
    % ???????(8int)
    segmentationMap = vibeSegmentation(vidFrame, historyImages, historyBuffer, param);    
    % ?????VIBE????????
%     [historyImages, historyBuffer] = vibeUpdate(vidFrame, segmentationMap, historyImages, historyBuffer, param, ...
%         jump, neighborX, neighborY, position);
    % 2D????????????
    segmentationMap = medfilt2(segmentationMap);
    toc;

%     [B,L] = bwboundaries(segmentationMap,'noholes');
%     max_ = size(B,1);
%     index = 1;
     subplot(2,2,2),imshow(segmentationMap),title('segmentation');
%     hold on;
%     if max_ ~= 0
%         for iii=1:max_
%             index = uint8(ceil(rand()*size(historyBuffer,2)));
%             boundary = B{iii};
%             tempItem = (L == iii);
%             tempBackground = historyBuffer{index}.*tempItem;
%             itemRhist = hist(tempItem(:),1:1:256);
%             bgRhist = hist(tempBackground(:),1:1:256);
%             g = corrcoef(itemRhist ,bgRhist);
%             if g(1,2) > 0.9999
%                 row = boundary(:,2);
%                 col = boundary(:,1);
%                 row(row<=0) = 1;
%                 col(col<=0) = 1;
%                 row(row > param.height) = param.height;
%                 col(col > param.width) = param.width;
%                 historyBuffer{index}(row,col) = vidFrame(row,col);
%                 
%             end
%             disp([iii,g(1,2)]);
%             rndRow = ceil(length(boundary)/(mod(rand*iii,7)+1));
%             col = boundary(rndRow,2); row = boundary(rndRow,1);
%             h = text(col+1, row-1, num2str(L(row,col)));
%             set(h,'Color','m','FontSize',14,'FontWeight','bold');
%         end
%     end
name = sprintf('%d.jpg',frame);
imwrite(segmentationMap,name,'jpg');
end