function [] = generate_negatives(labels_filepath)
% generate negatives based on WHitened HOG scores.

load(labels_filepath);
category_name
path_sim = ['/export/home/asanakoy/workspace/OlympicSports/sim/simMatrix_',category_name,'.mat']
load(path_sim);
fprintf('Total frames in the category: %d\n', length(simMatrix));
NEG_FRAMES_POOL_SIZE = length(simMatrix);
NEGATIVES_NUMBER = 10;

for i = 1:length(labels)
    assert(~isempty(labels(i).positives.ids));
    if isempty(labels(i).negatives.ids)
        fprintf('Generating negatives for anchor number %d (%d)\n', i, labels(i).anchor);
        anchor_sim = simMatrix(labels(i).anchor, :);
        negatives_indices = randperm(NEG_FRAMES_POOL_SIZE, NEGATIVES_NUMBER);
        labels(i).negatives.ids = negatives_indices;
        labels(i).negatives.flipval = 1 - flipval(negatives_indices);
        anchor_sim(negatives_indices)
    end
end

if ~exist('dataset_path', 'var')
    dataset_path = '~/workspace/OlympicSports'
end

save([labels_filepath], '-v7.3', ...
    'labels', 'category_name', 'category_offset', 'dataset_path');
end

