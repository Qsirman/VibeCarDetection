function segmentationMap = vibeSegmentation(buffer, historyImages, historyBuffer, param)
    %% Parameters
    height  = param.height;
    width   = param.width;
    numberOfSamples         = param.numberOfSamples;
    matchingThreshold       = param.matchingThreshold;
    matchingNumber          = param.matchingNumber;
    numberOfHistoryImages   = param.numberOfHistoryImages;
    
    %% Segmentation
    segmentationMap = uint8(ones(height, width)*(matchingNumber - 1));
    % First and Second history Image structure
    distance1 = abs(buffer - historyImages{1}) <= matchingThreshold;
    distance2 = abs(buffer - historyImages{2}) <= matchingThreshold;

    for ii = 1:height
        for jj = 1:width
            % ?????????????????????2
            if ~distance1(ii, jj)
                segmentationMap(ii, jj) = matchingNumber;
            end
            % ?????????????????????
            if distance2(ii, jj)
                segmentationMap(ii, jj) = segmentationMap(ii, jj) - 1;
            end
        end
    end
    % match the image and samples
    numberOfTests = numberOfSamples - numberOfHistoryImages;
    % ???????????????????segmentation??Mask
    for kk = 1:numberOfTests
        distance3 = uint8(abs(buffer - historyBuffer{kk}) <= matchingThreshold);
        segmentationMap = segmentationMap - distance3;
    end
    % ??????uint8
    segmentationMap = uint8(segmentationMap*255);
end