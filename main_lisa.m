function main_lisa()
    clc; clear; close all;

    % -------------------------------
    % Settings
    % -------------------------------
    INPUT_FILE = 'C:\\Rohith\\achivement\\lisa\\hi.avi';  % <-- change if needed
    VISUALIZE  = true;   % set false to skip visualization
    OUTPUT_FILE = 'C:\\Rohith\\achivement\\lisa\\output_with_boxes.avi';

    % -------------------------------
    % Load Video
    % -------------------------------
    if ~isfile(INPUT_FILE)
        error(['❌ Could not load video file: ', INPUT_FILE, ...
               '. Check if file exists and path is correct.']);
    end

    try
        vidReader = VideoReader(INPUT_FILE);
        disp('✅ Video file loaded successfully!');
        disp('--- Video Info ---');
        disp(['Duration (s): ', num2str(vidReader.Duration)]);
        disp(['Frame rate (fps): ', num2str(vidReader.FrameRate)]);
        disp(['Resolution: ', num2str(vidReader.Width), 'x', num2str(vidReader.Height)]);
    catch ME
        error(['❌ Could not load video: ', ME.message]);
    end

    % -------------------------------
    % Lip Preprocessing
    % -------------------------------
    disp('🔍 Extracting lip features...');
    [featLip, infoLip, framesWithBox] = lip_preprocess(vidReader, vidReader.FrameRate, VISUALIZE);

    disp('✅ Feature extraction complete!');
    disp(['Extracted features for ', num2str(size(featLip, 1)), ' frames.']);

    % -------------------------------
    % Save output video (if visualize = true)
    % -------------------------------
    if VISUALIZE && ~isempty(framesWithBox)
        disp('💾 Saving output video with bounding boxes...');
        vout = VideoWriter(OUTPUT_FILE, 'Uncompressed AVI');
        vout.FrameRate = vidReader.FrameRate;
        open(vout);
        for k = 1:length(framesWithBox)
            writeVideo(vout, framesWithBox{k});
        end
        close(vout);
        disp(['✅ Output video saved at: ', OUTPUT_FILE]);
    end
end
