subplot(4, 4, 13);
imshow(binary_Mask_1);
title('First mask(auto): Otsu''s  with IoU ');
calculateAndDisplayIoU(binary_Mask_1, groundTruthMask, 'IoU Mask 1', [0.1, 0.01]);
subplot(4, 4, 14);
imshow(binary_Mask_2);
title('second mask(auto): activecontour-Snakes with IoU');
calculateAndDisplayIoU(binary_Mask_2, groundTruthMask, 'IoU Mask 2', [0.3, 0.01]);
subplot(4, 4, 15);
imshow(chanVeseMask);
title('Third mask(manually pick region): Active Contour-chanVeseMask with IoU');
calculateAndDisplayIoU(chanVeseMask, groundTruthMask, 'IoU Mask 3', [0.5, 0.01]);
subplot(4, 4, 16);
imshow(binary_mask_3);
title('Fourth mask(auto): clustering-based with IoU');
calculateAndDisplayIoU(binary_mask_3, groundTruthMask, 'IoU Mask 4', [0.7, 0.01]);
%-------IoU score
% Resize the ground truth mask to match the size of the binary masks
groundTruthMask = imresize(groundTruthMask, size(binary_Mask_1));
function calculateAndDisplayIoU(segmentationMask, groundTruthMask, titleString, position)
   % Compute the intersection and union
   intersection = sum(sum(segmentationMask & groundTruthMask));
   union = sum(sum(segmentationMask | groundTruthMask));
   % Compute IoU
   iou = intersection / union;
   % Display the IoU value
   fprintf('%s: Intersection over Union (IoU): %.4f\n', titleString, iou);
   % Display the IoU score on the figure
   annotation('textbox', [position, 0.1, 0.1], 'String', sprintf('IoU: %.4f', iou), 'FontSize', 18, 'Color', 'r', 'EdgeColor', 'none');
end
