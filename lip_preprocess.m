function [featLip, infoLip, framesWithBox] = lip_preprocess(vidReader, frameRate, visualize)
% LIP_PREPROCESS - Extract lip features from video frames (toolbox-free)
% Restricts detection to lower half of face to focus on lips.

fprintf('hi\n'); % confirmation message

% Parameters
skipFrames = 3;   % process every Nth frame
minObjSize = 30;  % minimum blob size for lips

% Initialize outputs
featLip = {};
infoLip = {};
framesWithBox = {};

frameIdx = 0;   % total frames read
procIdx  = 0;   % processed frames

while hasFrame(vidReader)
    frameIdx = frameIdx + 1;
    frame = readFrame(vidReader);

    % Frame skipping
    if mod(frameIdx, skipFrames) ~= 0
        continue;
    end
    procIdx = procIdx + 1;

    % Convert to YCbCr
    ycbcrFrame = my_rgb2ycbcr(frame);

    % --- Step 1: Restrict ROI to lower half (mouth region) ---
    [h, w, ~] = size(frame);
    roiTop = round(h*0.55);   % approx mouth starts at 55% of face
    roiBottom = h;            % till bottom
    roi = roiTop:roiBottom;

    % Extract Cr channel
    Cr = ycbcrFrame(:,:,3);

    % Apply threshold only inside ROI
    lipMask = false(h, w);
    roiMask = Cr(roi, :) > 150 & Cr(roi, :) < 200;
    lipMask(roi, :) = roiMask;

    % Remove small blobs
    lipMask = removeSmallObjectsFast(lipMask, minObjSize);

    % Get bounding box
    props = my_regionprops(lipMask);
    bbox = [];

    if ~isempty(props)
        % Largest blob = lips
        [~, idx] = max([props.Area]);
        bbox = props(idx).BoundingBox;

        featLip{end+1} = bbox;
        infoLip{end+1} = props(idx);
    end

    % --- Visualization ---
    if visualize
        frameBox = frame;
        if ~isempty(bbox)
            frameBox = drawRectangle(frame, bbox, [0 255 0]); % green
        end
        framesWithBox{end+1} = frameBox;
        combined = [frame, frameBox];

        imshow(combined);
        title(sprintf('Original (Left) | Detection (Right) | Frame: %d (Processed: %d)', ...
            frameIdx, procIdx));
        drawnow;
        pause(1/frameRate);
    end
end

fprintf('Total frames read: %d\n', frameIdx);
fprintf('Frames processed (after skipping): %d\n', procIdx);

end

%% ---------- Helper: RGB → YCbCr ----------
function ycbcr = my_rgb2ycbcr(rgb)
rgb = im2double(rgb);
R = rgb(:,:,1); G = rgb(:,:,2); B = rgb(:,:,3);

Y  = 0.299*R + 0.587*G + 0.114*B;
Cb = -0.168736*R - 0.331264*G + 0.5*B + 0.5;
Cr =  0.5*R - 0.418688*G - 0.081312*B + 0.5;

ycbcr = cat(3, Y*255, Cb*255, Cr*255);
end

%% ---------- Remove small objects ----------
function BW2 = removeSmallObjectsFast(BW, minSize)
BW = logical(BW);
[labeled, num] = bwlabel_simple(BW);
props = my_regionprops(labeled);

BW2 = false(size(BW));
for k = 1:num
    if props(k).Area >= minSize
        BW2 = BW2 | (labeled == k);
    end
end
end

%% ---------- Simple bwlabel ----------
function [labeled, num] = bwlabel_simple(BW)
[m,n] = size(BW);
labeled = zeros(m,n);
label = 0;

for i = 1:m
    for j = 1:n
        if BW(i,j) && labeled(i,j) == 0
            label = label + 1;
            labeled = floodFill(labeled, BW, i, j, label);
        end
    end
end
num = label;
end

%% ---------- Flood Fill ----------
function labeled = floodFill(labeled, BW, i, j, label)
[m,n] = size(BW);
stack = [i,j];
while ~isempty(stack)
    p = stack(end,:); stack(end,:) = [];
    x = p(1); y = p(2);
    if x>0 && x<=m && y>0 && y<=n
        if BW(x,y) && labeled(x,y)==0
            labeled(x,y) = label;
            stack = [stack; x+1,y; x-1,y; x,y+1; x,y-1];
        end
    end
end
end

%% ---------- Custom regionprops ----------
function props = my_regionprops(labeled)
props = [];
labels = unique(labeled);
labels(labels==0) = [];

for k = 1:length(labels)
    mask = (labeled == labels(k));
    [rows, cols] = find(mask);
    if isempty(rows), continue; end
    xmin = min(cols); xmax = max(cols);
    ymin = min(rows); ymax = max(rows);

    props(k).Area = numel(rows);
    props(k).BoundingBox = [xmin, ymin, xmax-xmin+1, ymax-ymin+1];
end
end

%% ---------- Draw Rectangle ----------
function imgOut = drawRectangle(img, bbox, color)
imgOut = img;
x = round(bbox(1)); y = round(bbox(2));
w = round(bbox(3)); h = round(bbox(4));

[m, n, ~] = size(imgOut);
x = max(1, min(n, x));
y = max(1, min(m, y));
w = max(1, min(n-x, w));
h = max(1, min(m-y, h));

lineThickness = 3;
c = reshape(color,1,1,3);

imgOut(y:y+lineThickness-1, x:x+w, :) = repmat(c, [lineThickness, w+1, 1]);
imgOut(y+h-lineThickness+1:y+h, x:x+w, :) = repmat(c, [lineThickness, w+1, 1]);
imgOut(y:y+h, x:x+lineThickness-1, :) = repmat(c, [h+1, lineThickness, 1]);
imgOut(y:y+h, x+w-lineThickness+1:x+w, :) = repmat(c, [h+1, lineThickness, 1]);
end
