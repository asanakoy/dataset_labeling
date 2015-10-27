function [] = label( category_name, file_suffix)
%LABEL Pick the frame and label positives and negatives for it

path_prefix = '/net/hciserver03/storage/asanakoy/workspace/dataset_labeling/data/labels_';

if exist('file_suffix', 'var') && ~isempty(file_suffix)
    output_filename = [path_prefix, category_name, file_suffix, '.mat'];
end

if ~exist('file_suffix', 'var') || isempty(file_suffix)
    fprintf('Generating random filename suffix...\n');
    file_suffix = sprintf('_%d', ceil(rand * 1000000));
    output_filename = [path_prefix, category_name, file_suffix, '.mat'];
    
    while exist(output_filename, 'file')
        file_suffix = sprintf('_%d', ceil(rand * 1000000));
        output_filename = [path_prefix, category_name, file_suffix, '.mat'];
    end
end

fprintf('Output file path: %s\n', output_filename);

path_sim = ['/export/home/asanakoy/workspace/OlympicSports/sim/simMatrix_',category_name,'.mat'];
path_images = ['/export/home/asanakoy/workspace/OlympicSports/crops/',category_name,'/'];

fprintf('Welcome to the labelling tool application.\nFirst you are going to choose the anchor, please press k if the anchor is suitable and other key otherwise.\n');
load(path_sim);
negatives_per_seq = 10;

%#ok<*NODEF>
% image_names = image_names(:,3:end);
image_names = cellfun(@(z) z(3:end), image_names, 'UniformOutput', false);
N_FRAMES_TO_CHECK_FROM_ONE_SIDE = 300;

MAX_N_POSITIVES = 10;
MAX_N_NEGATIVES = 10;

close all;
h = figure();

for nframe = 1:50
    
    anchor_seq = seq_names{randperm(length(seq_names),1)}; %#ok<*USENS>
    anchor_seq_images_indices = find(cellfun(@(z) strncmpi(z, anchor_seq, length(anchor_seq)), image_names));
    
    subplot(1,2,2); plot(NaN); % to clear right subplot
    
    idx = 1;
    while 1
        labels(nframe).anchor = anchor_seq_images_indices(idx);
        anchor_name = fullfile(path_images, image_names{labels(nframe).anchor});
        figure(h);
        subplot(1,2,1);imshow(anchor_name); title('Anchor frame');
        
        fprintf('Press "enter" to go to the next frame OR\n print "q" or "w" and press "enter" to move 10 frames backward or forward (respectively).\n')
        anc = input('Is this a good anchor? (print "k" is yes):','s');
        if strcmp(anc,'k')
            break;
        elseif strcmp(anc,'q')
            idx = max(1, idx-10);
        elseif strcmp(anc,'w')
            idx = min(length(anchor_seq_images_indices), idx+10);
        else
            idx = min(length(anchor_seq_images_indices), idx+1);
        end
        
    end
    disp('Anchor selected');
    
    
    labels(nframe).positives.ids = [];
    labels(nframe).negatives.ids = [];
    labels(nframe).positives.flipval = [];
    labels(nframe).negatives.flipval = [];
    is_used = zeros(length(image_names), 1);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    anchor_sim = simMatrix(labels(nframe).anchor, :);
    anchor_flipval = flipval(labels(nframe).anchor, :);
    [~, permutation] = sort(anchor_sim, 'descend');
    
    perm_from_other_sequences = [];
    for i = 1:length(permutation)
        if ~strcmp(anchor_seq, getSeqName(image_names{permutation(i)}))
            perm_from_other_sequences(end + 1) = permutation(i);
        end
    end
    permutation = perm_from_other_sequences;
    
    n = min(N_FRAMES_TO_CHECK_FROM_ONE_SIDE, length(perm_from_other_sequences));
    
    abort_flag = 1;
    [labels(nframe).positives, labels(nframe).negatives, is_used] = ...
        iterateFrames(permutation(1:n), ...
        labels(nframe).positives, labels(nframe).negatives, ...
        is_used, image_names, path_images, ...
        anchor_sim, anchor_flipval, ...
        anchor_seq, MAX_N_POSITIVES, MAX_N_NEGATIVES, abort_flag, h);
    
    if (length(labels(nframe).positives.ids) < MAX_N_POSITIVES ||...
            length(labels(nframe).negatives.ids) < MAX_N_NEGATIVES)
        lb = min(length(permutation), max(n+1, length(permutation) - N_FRAMES_TO_CHECK_FROM_ONE_SIDE + 1));
        
        abort_flag = 0;
        [labels(nframe).positives, labels(nframe).negatives, is_used] = ...
            iterateFrames(permutation(end:-1:lb), ...
            labels(nframe).positives, labels(nframe).negatives, ...
            is_used, image_names, path_images, ...
            anchor_sim, anchor_flipval, anchor_seq, ...
            MAX_N_POSITIVES, MAX_N_NEGATIVES, abort_flag, h);
        
    end
    disp('Iteration is over.');
    
    save(output_filename, '-v7.3', 'labels', 'category_name');
    
end

end

%%
function [positives, negatives, is_used] = iterateFrames(permutation, ...
    positives, negatives, is_used, ...
    image_names, path_images, anchor_sim, ...
    anchor_flipval, ...
    anchor_seq, max_positives_count, ...
    max_negatives_count, abort_flag, h_figure)

WINDOW_SIZE = 5;
WINDOW_SIZE_TO_MARK = 3;


fprintf('Negatives count: %d\n', length(negatives.ids));

main_frameId = permutation(1);
frameId = main_frameId;
i = 1;
direction = 1;
n = length(permutation);

fprintf('Press p for positive, n for negative.\nPress q or w to move 5 frames backward or forward (respectively).\n')
fprintf('a or s to move 1 frame backward or forward (respectively).\n');
fprintf('j or k to move 1 frame backward or forward inside the sequence (respectively).\n');
while 1
    
    sim = anchor_sim(frameId);
    
    curr_seq_name = getSeqName(image_names{main_frameId});
    assert(strcmp(curr_seq_name, getSeqName(image_names{frameId})));
    
    if strcmp(curr_seq_name, anchor_seq) || is_used(main_frameId)
        if i + direction > 0 && i + direction <= n
            i = i + direction;
            main_frameId = permutation(i);
            frameId = main_frameId;
        else
            direction = -direction;
        end
        
        continue
    end
    
    image_path = fullfile(path_images, image_names{frameId});
    img = imread(image_path);
    flipval = anchor_flipval(frameId);
    if (flipval)
        img = fliplr(img);
    end
    subplot(1,2,2); imshow(img); title(sprintf('Frame %d of %d; Sim: %.3f', i, n, sim));
    figure(h_figure);
    
    w = 0; % mouse button pressed
    while w == 0
        w = waitforbuttonpress;
    end
    
    pressed_key = h_figure.CurrentCharacter;
    
    if strcmp(pressed_key,'p')
        
        if length(positives.ids) < max_positives_count
            positives.ids = [positives.ids frameId];
            positives.flipval = [positives.flipval flipval];
            is_used = markWindowAsUsed(is_used, frameId, WINDOW_SIZE_TO_MARK, image_names);
            
            [direction, i, main_frameId, frameId] = move(i, 1, direction, main_frameId, frameId, permutation);
            fprintf('Positive marked: %d\n', length(positives.ids));
        else
            fprintf('You have reached the maximum number of positives (%d)!\n', max_positives_count);
        end
        
    elseif strcmp(pressed_key,'n')
        
        if length(negatives.ids) < max_negatives_count
            negatives.ids = [negatives.ids frameId];
            negatives.flipval = [negatives.flipval flipval];
            
            is_used = markWindowAsUsed(is_used, frameId, WINDOW_SIZE_TO_MARK, image_names);
            
            [direction, i, main_frameId, frameId] = move(i, 1, direction, main_frameId, frameId, permutation);
            fprintf('Negative marked: %d\n', length(negatives.ids));
        else
            fprintf('You have reached the maximum number of negatives (%d)!\n', max_negatives_count);
        end
        
    elseif strcmp(pressed_key,'w')
        
        [direction, i, main_frameId, frameId] = move(i, 5, direction, main_frameId, frameId, permutation);
        
    elseif strcmp(pressed_key,'q')
        
        [direction, i, main_frameId, frameId] = move(i, -5, direction, main_frameId, frameId, permutation);
        
    elseif strcmp(pressed_key,'s')
        
        [direction, i, main_frameId, frameId] = move(i, 1, direction, main_frameId, frameId, permutation);
        
    elseif strcmp(pressed_key,'a')
        
        [direction, i, main_frameId, frameId] = move(i, -1, direction, main_frameId, frameId, permutation);
        
    elseif strcmp(pressed_key,'j')
        
        if ( (main_frameId - frameId) < WINDOW_SIZE && ...
                frameId > 1 && ~is_used(frameId-1) && ...
                strcmp(getSeqName(image_names{frameId-1}), curr_seq_name) == 1)
            
            frameId = frameId - 1;
        end
        
    elseif strcmp(pressed_key,'k')
        
        if ( (frameId - main_frameId) < WINDOW_SIZE && ...
                frameId < length(image_names) && ~is_used(frameId+1) &&...
                strcmp(getSeqName(image_names{frameId+1}), curr_seq_name) == 1)
            
            frameId = frameId + 1;
        end
        
    elseif strcmp(pressed_key,'f')
        
        anchor_flipval(frameId) = ~anchor_flipval(frameId);
        fprintf('Image flipped\n');
        
    elseif strcmp(pressed_key,'r')
        
        prompt = 'To stop print "yes" end press "enter": ';
        s = input(prompt, 's');
        if strcmp(s, 'yes')
            fprintf('Breaked cycle.\n');
            break;
        else
            fprintf('Incorrect answer. Continuing cycle.\n');
        end

    end
    
    
    if (abort_flag == 1 && length(positives.ids) == max_positives_count) || ...
            (abort_flag == -1 && length(negatives.ids) == max_negatives_count) || ...
            (length(positives.ids) == max_positives_count && length(negatives.ids) == max_negatives_count)
        
        break;
    end
    
end

end


%% Utility functions

function [seq_name] = getSeqName(image_name)
pos = regexp(image_name, '/I.*\.png');
seq_name = image_name(1:pos-1);
end

function [is_used] = markWindowAsUsed(is_used, main_frameId, WINDOW_SIZE, image_names)
for j = max(main_frameId - WINDOW_SIZE, 1):min(main_frameId + WINDOW_SIZE, length(image_names))
    if strcmp(getSeqName(image_names{j}), getSeqName(image_names{main_frameId})) == 1
        is_used(j) = 1;
    end
end
end

function [direction, i, main_frameId, frameId] = move(i, delta, old_direction, main_frameId, frameId, permutation)
direction = old_direction;
if i + delta > 0 && i + delta <= length(permutation)
    direction = sign(delta);
    i = i + delta;
    main_frameId = permutation(i);
    frameId = main_frameId;
    pause(0.01);
end
end
