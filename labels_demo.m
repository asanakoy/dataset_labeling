function [] = labels_demo(labels_filepath)
%LABEL Summary of this function goes here
%   Detailed explanation goes here

load(labels_filepath);
category_name
path_sim = ['/export/home/asanakoy/workspace/OlympicSports/sim/simMatrix_',category_name,'.mat']
path_images = ['/export/home/asanakoy/workspace/OlympicSports/crops/',category_name,'/'];
load(path_sim);

% category_name = 'long_jump';

%#ok<*NODEF>
% image_names = image_names(:,3:end);
image_names = cellfun(@(z) z(3:end), image_names, 'UniformOutput', false);
h = figure();
    
for nframe = 1:length(labels)
    
    anchor_id = labels(nframe).anchor;
   
    
    figure(h);
    anchor_path = fullfile(path_images, image_names{anchor_id});
    subplot(1,2,1);imshow(anchor_path); title(sprintf('Anchor frame %d', anchor_id));
    fprintf('a or s to move 1 frame backward or forward (respectively).\n');
   
    fprintf('Positives: %d; Negatives: %d\n', ...
        length(labels(nframe).positives.ids), length(labels(nframe).negatives.ids));
    
    if (length(labels(nframe).positives.ids) == 0)
        fprintf('Empty label. Skipping\n');
        continue;
    end
    
    image_ids = [labels(nframe).positives.ids labels(nframe).negatives.ids];
    flipvals = [labels(nframe).positives.flipval labels(nframe).negatives.flipval];
    is_positive = zeros(size(image_ids));
    is_positive(1:length(labels(nframe).positives.ids)) = 1;
    
    i = 0;
    direction = 1;
    n = length(image_ids);
    while 1
        
        
        if i + direction > 0 && i + direction <= n
            i = i + direction;
            frameId = image_ids(i);
        end

        
        image_path = fullfile(path_images, image_names{frameId});
        img = imread(image_path);
        flipval = flipvals(i);
        if (flipval)
            img = fliplr(img);
        end
        if is_positive(i)
            num_of_frames = length(labels(nframe).positives.ids);
            idx = i;
            title_str = 'Positive';
        else
            idx = i - length(labels(nframe).positives.ids);
            num_of_frames = length(labels(nframe).negatives.ids);
            title_str = 'Negative';
        end
        subplot(1,2,2); imshow(img); title(sprintf('%s Frame %d of %d;', title_str, idx, num_of_frames));
        figure(h);
        
        w = 0; % mouse button pressed
        while w == 0
            w = waitforbuttonpress;
        end
        
        pressed_key = h.CurrentCharacter;
        
        if strcmp(pressed_key,'a')
            
                
            direction = -1;
               
            
        elseif strcmp(pressed_key,'s')
            direction = 1;
            
        elseif strcmp(pressed_key,'r')
            break;
        else
            direction = 0;
        end
    end
    
   
    disp('Iteration is over.');
    
    
end

end
