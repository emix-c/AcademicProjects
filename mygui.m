function varargout = mygui(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @mygui_OpeningFcn, ...
                   'gui_OutputFcn',  @mygui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

% --- Executes just before mygui is made visible.
function mygui_OpeningFcn(hObject, eventdata, handles, varargin)

% Choose default command line output for mygui
handles.output = hObject;

set(handles.axes2, 'visible', 'off')
set(handles.axes3, 'visible', 'off')

% Update handles structure
guidata(hObject, handles);


% --- Outputs from this function are returned to the command line.
function varargout = mygui_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)

global GRAY
[file,path] = uigetfile({'*.*'});
img_loc = fullfile(path, file);
img = imread(img_loc);
axes(handles.axes2);
imshow(img);
GRAY = rgb2gray(img);


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
global GRAY
k = get(handles.popupmenu1,'value');
switch k
   case 2
       enhancedImg = imadjust(GRAY);
       thresholdValue_auto = graythresh(enhancedImg);
       binMask_1 = imcomplement(imbinarize(enhancedImg, thresholdValue_auto));
       se = strel('disk',3);
       FinalBinaryMask = imclose(binMask_1, se);
   case 3
       enhancedImg = imadjust(GRAY);
       bw_Initial = imbinarize(enhancedImg);
       binMask_2 = imcomplement(activecontour(enhancedImg, bw_Initial));
       se = strel('disk', 20);
       FinalBinaryMask = imclose(binMask_2, se);
   case 4
       numClusters = 2;
       enhancedImg = imadjust(GRAY);
       reshapedImage = reshape(enhancedImg, [], 1);
       [idx, centroids] = kmeans(double(reshapedImage), numClusters);
       segmented_image = reshape(idx, size(enhancedImg));
       binMask_3 = imcomplement(segmented_image == mode(idx));
       se = strel('disk', 3);
       FinalBinaryMask = imclose(binMask_3, se);
   case 5
       enhancedImg = imadjust(GRAY);
       gaussthresh = adaptthresh(enhancedImg,0.4,"ForegroundPolarity","dark", "Statistic", "gaussian");
       binMask_4 = imbinarize(enhancedImg, gaussthresh);
       FinalBinaryMask = imcomplement(binMask_4);
   case 6
       enhancedImg = imadjust(GRAY);
       thresholdValue_auto = graythresh(enhancedImg);
       binMask_5 = imcomplement(imbinarize(enhancedImg, thresholdValue_auto));
       se_1 = strel('disk', 5);
       smoothed_Mask = imdilate(binMask_5, se_1);
       se_2 = strel('disk', 20);
       smoothed_Mask_2 = imopen(smoothed_Mask, se_2);
       boundary_Points_Common = bwboundaries(smoothed_Mask_2);
       for j = 1:length(boundary_Points_Common)
           current_Boundary = boundary_Points_Common{j};
       end
       touches_Border = true;
       if touches_Border
           remaining_Contour_Image = zeros(size(smoothed_Mask_2));
           for k = 1:length(boundary_Points_Common)
           current_Point = boundary_Points_Common{k};
           outside_Border = any(current_Point(:, 1) == 1 | current_Point(:, 2) == 1 | current_Point(:, 1) == size(binMask_5, 1) | current_Point(:, 2) == size(smoothed_Mask_2, 2));
               if ~outside_Border
                   remaining_Contour_Image(sub2ind(size(smoothed_Mask), current_Point(:, 1), current_Point(:, 2))) = 1;
               end
           end
           boundary_Points_Remaining = bwboundaries(remaining_Contour_Image);
           for m = 1:length(boundary_Points_Remaining)
               current_Boundary = boundary_Points_Remaining{m};
           end
       end
       FinalBinaryMask = imfill(remaining_Contour_Image, 'holes');
   otherwise
       disp('No Method');
end
axes(handles.axes3);
if isequal(k,1)
   imshow(GRAY);
else
   imshow(FinalBinaryMask);
end


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','pink');
end
