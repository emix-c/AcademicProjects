% Choose multiple image files
[filenames, folder] = uigetfile({'*.jpg'; '*.png'}, 'Select Image Files', 'MultiSelect', 'on');
% Check if the user selected files
if isequal(filenames, 0) || isequal(folder, 0)
   disp('User canceled the operation.');
else
   % Check if the user selected a single file or multiple files
   if ischar(filenames)
       % If only one file is selected, convert it to a cell array
       filenames = {filenames};
   end
   % Process each selected image
   for i = 1:length(filenames)
       % Construct the full file path for each selected image
       image_filename = fullfile(folder, filenames{i});
       % Process the selected image using the existing function
       processImage(image_filename);
   end
end
function processImage(image_filename)
   % Load the MRI image
   original_Image = imread(image_filename);
   % Extract file name without extension
   [~, image_name, ~] = fileparts(image_filename);
   % Read the image and convert it to grayscale
   gray_Image = rgb2gray(original_Image);
   % Enhance contrast of the grayscale image
   enhanced_Image = imadjust(gray_Image);
   % Auto find and construct masking
   thresholdValue_auto = graythresh(enhanced_Image);
   binary_Mask = imcomplement(imbinarize(enhanced_Image, thresholdValue_auto));
   % Perform morphological operations on the masks for smoothing
   se_1 = strel('disk', 5);
   smoothed_Mask = imdilate(binary_Mask, se_1);
   % Perform additional morphological operations on the masks for smoothing
   se_2 = strel('disk', 20);
   smoothed_Mask_2 = imopen(smoothed_Mask, se_2);
   % Extract the perimeter of the filled mask and plot the red contour
   figure;
   subplot(3, 4, 2), imshow(original_Image), title('Original Image');
   subplot(3, 4, 3), imshow(enhanced_Image), title('Enhanced Grayscale Image');
   subplot(3, 4, 4), imshow(binary_Mask), title('Auto-masking: Otsu''s method');
   subplot(3, 4, 5), imshow(smoothed_Mask), title('Morphological with masking');
   subplot(3, 4, 6), imshow(smoothed_Mask_2), title('Morphological with masking');
   % Plot the common contour using the boundary function
   subplot(3, 4, 7);
   boundary_Points_Common = bwboundaries(smoothed_Mask_2);
   for i = 1:length(boundary_Points_Common)
       current_Boundary = boundary_Points_Common{i};
       plot(current_Boundary(:, 2), current_Boundary(:, 1), 'r', 'LineWidth', 2);
       hold on;
   end
   axis tight;
   axis equal;
   title('Common Contour');
   % If the contour touches the border, create a new subplot to display the remaining part
   touches_Border = true; % You can modify this based on your specific condition
   if touches_Border
       subplot(3, 4, 8);
       remaining_Contour_Image = zeros(size(smoothed_Mask_2));
       % Iterate through boundary points and remove points touching the border
       for i = 1:length(boundary_Points_Common)
           current_Point = boundary_Points_Common{i};
           outside_Border = any(current_Point(:, 1) == 1 | current_Point(:, 2) == 1 | current_Point(:, 1) == size(binary_Mask, 1) | current_Point(:, 2) == size(smoothed_Mask_2, 2));
           if ~outside_Border
               remaining_Contour_Image(sub2ind(size(smoothed_Mask), current_Point(:, 1), current_Point(:, 2))) = 1;
           end
       end
       % Plot the remaining part of the contour using the boundary function
       boundary_Points_Remaining = bwboundaries(remaining_Contour_Image);
       for i = 1:length(boundary_Points_Remaining)
           current_Boundary = boundary_Points_Remaining{i};
           plot(current_Boundary(:, 2), current_Boundary(:, 1), 'r', 'LineWidth', 2);
           hold on;
       end
       axis tight;
       axis equal;
       title('Remaining Contour');
   end
   % Fill the interior of the closed boundary with white color
   filled_Contour_Image = imfill(remaining_Contour_Image, 'holes');
   % Create a subplot to display the filled mask
   subplot(3, 4, 9);
   imshow(filled_Contour_Image);
   title('Filled Mask based on Remaining Contour');
   % Find the segmentation image with the same name
   segmentation_image_name = [image_name '_Segmentation.png'];
   segmentation_image_path = fullfile(pwd, segmentation_image_name);
   % Check if the segmentation image exists
   if exist(segmentation_image_path, 'file')
       % Read the segmentation image
       segmentation_image = imread(segmentation_image_path);
       % Display the segmentation image in subplot (3, 4, 1)
       subplot(3, 4, 1), imshow(segmentation_image), title('Ground Truth Image');
   else
       disp('Segmentation image not found.');
   end
   % Calculate IoU
   iou_score = calculateIoU(segmentation_image, filled_Contour_Image);
   % Display the IoU score in subplot 3, 4, 10
   subplot(3, 4, 10);
   text(0.5, 0.5, ['IoU: ' num2str(iou_score)], 'FontSize', 30, 'HorizontalAlignment', 'center');
   axis off;
   % Save IoU score to Excel file
   saveIoUScoreToExcel(image_name, iou_score);
end
% Function to calculate IoU
function iou = calculateIoU(seg_image, filled_contour_image)
   intersection = sum(sum(seg_image & filled_contour_image));
   union = sum(sum(seg_image | filled_contour_image));
   iou = intersection / union;
end
% Function to save IoU score to Excel file
function saveIoUScoreToExcel(image_name, iou_score)
   % Create a table with image name and IoU score
   data = table({image_name}, iou_score, 'VariableNames', {'ImageName', 'IoUScore'});
   % Check if the Excel file already exists
   excel_filename = 'IoU_Scores.xlsx';
   if exist(excel_filename, 'file')
       % If the file exists, append the new data
       existing_data = readtable(excel_filename);
       updated_data = [existing_data; data];
       writetable(updated_data, excel_filename);
   else
       % If the file does not exist, create a new file with the data
       writetable(data, excel_filename);
   end
end

