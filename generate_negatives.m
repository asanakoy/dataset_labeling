function [] = generate_negatives(labels_filepath)

load(labels_filepath);
category_name
path_sim = ['/export/home/asanakoy/workspace/OlympicSports/sim/simMatrix_',category_name,'.mat']
load(path_sim);
fprintf('Total frames in the category: %d\n', length(simMatrix));
MOST_DISTANT_FRAMES_POOL_SIZE = min(100, length(simMatrix) * 0.15);
NEGATIVES_NUMBER = 10;

for i = 1:length(labels)
    assert(~isempty(labels(i).positives.ids));
    if isempty(labels(i).negatives.ids)
        fprintf('Generating negatives for anchor number %d (%d)\n', i, labels(i).anchor);
        anchor_sim = simMatrix(labels(i).anchor, :);
        [~, permutation] = sort(anchor_sim, 'ascend');
        negatives_indices = randperm(min(MOST_DISTANT_FRAMES_POOL_SIZE, length(permutation)),...
                                     NEGATIVES_NUMBER);
       labels(i).negatives.ids = permutation(negatives_indices);
       labels(i).negatives.flipval = 1 - flipval(permutation(negatives_indices));
       anchor_sim( permutation(negatives_indices))
    end
end

if ~exist('dataset_path', 'var')
    dataset_path = '~/workspace/OlympicSports'
end

save([labels_filepath], '-v7.3', ...
    'labels', 'category_name', 'category_offset', 'dataset_path');
end

