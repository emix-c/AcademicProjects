% Read the image and convert it to grayscale
original_Image = imread('ISIC_0000383.jpg');
gray_Image = rgb2gray(original_Image); 
% Changed to rgb2gray to convert to grayscale and enhance contrast 
enhanced_Image = imadjust(gray_Image);
% make histogram of the image which shows regions
[counts, bins] = imhist(enhanced_Image);
% -----------first-way: auto find
thresholdValue_auto = graythresh(enhanced_Image); % Automatically compute threshold by Otsu's method
binary_Mask_1 = imcomplement(imbinarize(enhanced_Image, thresholdValue_auto)); % Morphological step
% -----------second-way: auto find
bw_Initial = imbinarize(enhanced_Image);
binary_Mask_2 = imcomplement(activecontour(enhanced_Image, bw_Initial)); % Active Contour (Snakes)
% -----------third-way: manually choose region
maskedImage = roipoly(enhanced_Image);
maskedImage_roi = double(maskedImage); % Convert maskedImage to the appropriate type for imbinarize
edge = activecontour(enhanced_Image, maskedImage_roi, 75, 'edge'); % Create the edge
chanVese = activecontour(enhanced_Image, maskedImage_roi, 75, 'Chan-Vese'); % Create Chan-Vese contours
chanVeseMask = chanVese > 0.5; % Create a binary mask based on Chan-Vese contour
% -----------fourth: auto find
numClusters = 2; % Specify the number of clusters (you may need to adjust this based on your image)
reshapedImage = reshape(enhanced_Image, [], 1); % Reshape the enhanced image to a column vector for k-means clustering
[idx, centroids] = kmeans(double(reshapedImage), numClusters); % Perform k-means clustering
segmented_image = reshape(idx, size(enhanced_Image)); % Reshape the index matrix back to the size of the image
binary_mask_3 = imcomplement(segmented_image == mode(idx)); % Create a binary mask based on the cluster with higher intensity (assuming the lesion is brighter)
%------smooth the mask
% Perform morphological operations on the masks for smoothing
se = strel('disk', 3); % Define a disk-shaped structuring element with a radius of 3 pixels
smoothed_Mask_1 = imclose(binary_Mask_1, se); % Closing operation
smoothed_Mask_2 = imclose(binary_Mask_2, se);
smoothed_Mask_3 = imclose(chanVeseMask, se);
smoothed_Mask_4 = imclose(binary_mask_3, se);
% Display the results
figure;
subplot(4, 4, 1);
imshow(original_Image);
title('Original Image');
subplot(4, 4, 2);
imshow(enhanced_Image);
title('Enhanced Grayscale Image');
subplot(4, 4, 3);
bar(bins, counts);
title('Histogram of image');
% Automatically adjust x-axis limits based on the data
maxCount = max(counts);
xlim([find(counts > maxCount * 0.05, 1, 'first'), find(counts > maxCount * 0.95, 1, 'last')]);
groundTruthMask = imread("ISIC_0000383_Segmentation.png");
subplot(4, 4, 4);
imshow(groundTruthMask);
title('groundTruthMask Image for IoU');
subplot(4, 4, 5);
imshow(binary_Mask_1);
title('First mask (auto): Otsu''s method');
subplot(4, 4, 6);
imshow(binary_Mask_2);
title('Second mask (auto): activecontour-Snakes)');
subplot(4, 4, 7);
imshow(chanVeseMask);
title('Third mask (manually pick region): Active Contour-chanVeseMask');
subplot(4, 4, 8);
imshow(binary_mask_3);
title('Fourth mask (auto): clustering-based methods');
% Display the smoothed masks
subplot(4, 4, 9);
imshow(smoothed_Mask_1);
title('Smoothed Mask 1');
subplot(4, 4, 10);
imshow(smoothed_Mask_2);
title('Smoothed Mask 2');
subplot(4, 4, 11);
imshow(smoothed_Mask_3);
title('Smoothed Mask 3');
subplot(4, 4, 12);
imshow(smoothed_Mask_4);
title('Smoothed Mask 4');
