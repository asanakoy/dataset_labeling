function [] = label( category )
%LABEL Summary of this function goes here
%   Detailed explanation goes here
path_sim = ['/export/home/asanakoy/workspace/OlympicSports/sim/simMatrix_',category,'.mat']
path_images = ['/export/home/asanakoy/workspace/OlympicSports/crops/',category,'/'];

fprintf('Welcome to the labelling tool application.\nFirst you are going to choose the anchor, please press k if the anchor is suitable and other key otherwise.');
load(path_sim);
negatives_per_seq = 10;

%#ok<*NODEF>
% image_names = image_names(:,3:end);
image_names = cellfun(@(z) z(3:end), image_names, 'UniformOutput', false);

for nframe = 1:50
    
    anchor_seq = seq_names{randperm(length(seq_names),1)}; %#ok<*USENS>
    anchor = randperm(size(image_names,1),1);
    anchor_seq_images_indices = find(cellfun(@(z) strncmpi(z, anchor_seq, length(anchor_seq)), image_names));
    h = figure();
    idx = 1;
    while idx < length(anchor_seq_images_indices) 
        labels(nframe).anchor = anchor;
        anchor_name = fullfile(path_images, image_names{anchor_seq_images_indices(idx)});
        figure(h);
        subplot(1,2,1);imshow(anchor_name); title('Anchor frame');

       anc = input('Is this a good anchor?','s');
        if strcmp(anc,'k')
            break;
        else
            idx = idx+1;
        end
        
    end
    disp('Anchor selected');
    
    
    labels(nframe).positives = [];
    labels(nframe).negatives = [];
    positives = [];
    negatives = [];
    
    for seq_id = randperm(length(seq_names), 10)
        curr_seq_name = seq_names{seq_id};
        if ~strcmp(curr_seq_name, anchor_seq)
            images_seq_indices = find(cellfun(@(z) strncmpi(z, curr_seq_name, ...
                                                            length(curr_seq_name)), image_names));
                                                        
            count = 1;
            while count < length(images_seq_indices)
                
                image_name = fullfile(path_images, image_names{images_seq_indices(count)});
                subplot(1,2,2); imshow(image_name); title(sprintf('Frame %d of %d', count, length(images_seq_indices)));
                
                figure(h);
                %positives
                %negatives
                fprintf('Press p for positive, n for negative.\nPress q or w to move 5 frames backward or forward (respectively).\nPress a or s to move one frame backward or forward (respectively).');
                
                
                w = 0; % mouse button pressed
                while w == 0
                    w = waitforbuttonpress;
                end

                pressed_key = h.CurrentCharacter;
                fprintf('\nKey %s pressed\n', pressed_key);
                
                if strcmp(pressed_key,'p')
                    positives = [positives images_seq_indices(count)];
                    count = count + 5;
                elseif strcmp(pressed_key,'n')
                    
                    if length(negatives) < 10
                        negatives = [negatives images_seq_indices(count)];
                    else
                        disp(['You already labelled ',num2str(negatives_per_seq),' negatives, which is the maximum.'])
                    end
                    count = count + 3;
                    
                elseif strcmp(pressed_key,'w')
                    
                        count = count + 5;
                
                elseif strcmp(pressed_key,'q')
                    
                    if count > 5
                        count = count - 5;
                    end
                    
                elseif strcmp(pressed_key,'s')

                        count = count + 1;

                elseif strcmp(pressed_key,'a')
                    
                    if count > 1
                        count = count - 1;
                    end
                    
                end
                
            end
            disp('End of current sequence.');
        end
        
        labels(nframe).positives = [labels(nframe).positives positives];
        labels(nframe).negatives = [labels(nframe).negatives negatives];
        save(['labels_',category,'.mat'],'labels');
        
    end
    
end

