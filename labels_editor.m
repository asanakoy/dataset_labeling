function [labels] = labels_editor(labels_filepath)
%LABEL Summary of this function goes here
%   Detailed explanation goes here

load(labels_filepath);
dataset_path = '/export/home/asanakoy/workspace/ucf_sports/';
category_name
path_sim = [dataset_path, '/sim_pedro_hog_for_labeling/sim_hog_pedro_',category_name,'.mat'];
path_images = [dataset_path, '/crops_227x227/',category_name,'/'];
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
    fprintf('"a"/"s" to move 1 frame backward / forward (respectively).\n"r" to go tp the next anchor.');
   
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
    action = repmat('-',1, length(image_ids));
    
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
            title_str = ['Positive -> ', action(i)];
        else
            idx = i - length(labels(nframe).positives.ids);
            num_of_frames = length(labels(nframe).negatives.ids);
            title_str = ['Negative -> ', action(i)];
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
            
        elseif strcmp(pressed_key, 's')
            direction = 1;
            
        elseif strcmp(pressed_key, 'd')
            action(i) = 'd';
            direction = 0;
        elseif strcmp(pressed_key, 'n') && is_positive(i)
            action(i) = 'n';
            direction = 0;
        elseif strcmp(pressed_key, 'p') && ~is_positive(i)
            action(i) = 'p';
            direction = 0;
        elseif strcmp(pressed_key, 'c') 
            action(i) = '-';
            direction = 0;
            
        elseif strcmp(pressed_key,'r')
            break;
        else
            direction = 0;
        end
    end
    disp('Iteration is over. Applying actions.');
    
    pos.ids = [];
    pos.flipval = [];
    neg.ids = [];
    neg.flipval = [];
    
    for j = 1:length(action)
        fprintf('%s, ', action(j));
        act = action(j);
        flipval = flipvals(j);
        if act == 'd'
            continue;
        elseif act == 'p'
            pos = add_point(pos, image_ids(j), flipvals(j));
        elseif act == 'n'
            neg = add_point(neg, image_ids(j), flipvals(j));
        elseif act == 'f'
            flipval = 1 - flipval;
        end
        
        if is_positive(j)
            pos = add_point(pos, image_ids(j), flipval);
        else
            neg = add_point(neg, image_ids(j), flipval);
        end
    end
    fprintf('\n');
    
    labels(nframe).positives = pos;
    labels(nframe).negatives = neg;
    
end

end

function [struct] = add_point(struct, id, flipval)
    struct.ids = [struct.ids, id];
    struct.flipval = [struct.flipval, flipval];
end
