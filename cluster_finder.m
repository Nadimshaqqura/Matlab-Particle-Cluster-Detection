% Input and output folder paths
inputFolder = ''; 
outputFolder = '';  % folder to save proccesed images

%dont forget to define the cluster size 
% define the size of cluster
px=200
% Get a list of all image files in the input folder
imageFiles = dir(fullfile(inputFolder, '*.png')); 

for i = 1:length(imageFiles)
    % Read the current image
    inputImagePath = fullfile(inputFolder, imageFiles(i).name);
    img = imread(inputImagePath);

% convert to greyscale and create binary image
grayImg = rgb2gray(img);
threshold = graythresh(grayImg);% unnötig 
binaryImg = imbinarize(grayImg,'adaptive','ForegroundPolarity','dark','Sensitivity',0.6);
binaryImg = ~binaryImg; %invert


% label connected components in the binary image
[labeledImg, numObjects] = bwlabel(binaryImg);

% calculate region properties 
objectStats = regionprops(labeledImg, 'Area', 'PixelIdxList');

% create an RGB image for visualizationm 
coloredImg = uint8(zeros([size(binaryImg), 3])); 



for k = 1:numObjects
    % Get the area of the current object
    area = objectStats(k).Area;
    
    % Get the pixel indices of the current object
    indList = objectStats(k).PixelIdxList;
    
    % Color clusters
    if area > px
        % Red color (255, 0, 0)
        coloredImg(indList) = 255;     % Red channel
        coloredImg(indList + numel(binaryImg)) = 0;  % Green channel
        coloredImg(indList + 2 * numel(binaryImg)) = 0;  % Blue channel
    else
        % Blue color (0, 0, 255)
        coloredImg(indList) = 0;       
        coloredImg(indList + numel(binaryImg)) = 0;  
        coloredImg(indList + 2 * numel(binaryImg)) = 255; 
    end
end

% Set the background to white (255, 255, 255)
backgroundIdx = find(binaryImg == 0); % Find background pixels
coloredImg(backgroundIdx) = 255; % Set the red channel of background to 255
coloredImg(backgroundIdx + numel(binaryImg)) = 255; % Set the green channel of background to 255
coloredImg(backgroundIdx + 2 * numel(binaryImg)) = 255; % Set the blue channel of background to 255

% save the resulting image to the output folder
    outputImagePath = fullfile(outputFolder, imageFiles(i).name);
    imwrite(coloredImg, outputImagePath);

    % Display progress
    fprintf('Processed and saved: %s\n', imageFiles(i).name);
end
% Display visualized image 
figure;
imshow(coloredImg);
figure;
subplot(1, 2, 1);
imshow(img);
title('original');

subplot(1, 2, 2);
imshow(coloredImg);
title('colored');





