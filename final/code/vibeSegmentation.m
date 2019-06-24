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
            % check if distance 1 is a zero matrix
            % make it into matching number
            if ~distance1(ii, jj)
                segmentationMap(ii, jj) = matchingNumber;
            end
            % check if distance 2 is an one matrix
            % make it minus 1 to pull it off the updating
            if distance2(ii, jj)
                segmentationMap(ii, jj) = segmentationMap(ii, jj) - 1;
            end
        end
    end
    % match the image and samples
    numberOfTests = numberOfSamples - numberOfHistoryImages;
    % update the mask in time
    for kk = 1:numberOfTests
        distance3 = uint8(abs(buffer - historyBuffer{kk}) <= matchingThreshold);
        segmentationMap = segmentationMap - distance3;
    end
    % make the segmentation image from double to unsigned int 8
    segmentationMap = uint8(segmentationMap*255);
end