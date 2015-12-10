function [] = merge_labeled_data( dir_path, filename_suffix, category_name, data_info)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

if ~exist(dir_path, 'dir')
    error('Dir does not exist : %s\n', dir_path);
end

labeling_dir_path = '/net/hciserver03/storage/asanakoy/workspace/dataset_labeling';
% output_filename = 'long_jump_21.10.mat';
% category_name = 'long_jump';

dataset_path = '~/workspace/OlympicSports';
if ~exist('data_info', 'var')
    data_info = load(DatasetStructure.getDataInfoPath(dataset_path));
end

labels_prefix = '';
if exist('category_name', 'var')
    labels_prefix = ['labels_' category_name '_'];
end
labels_prefix
file_list = getFilesInDir(dir_path, [labels_prefix '.*\.mat']);

if isempty(file_list)
    fprintf('No matched files in the folder!');
    return;
end

file = load(fullfile(dir_path, file_list{1}));
category_name = file.category_name;

category_offset = get_category_offset(category_name, data_info);

for i = 1:length(file_list)
    fprintf('File %d\n', i);
    file = load(fullfile(dir_path, file_list{i}));
    assert(strcmp(file.category_name, category_name));
    
    if i == 1
        labels = file.labels;
    else
        labels = [labels file.labels];
    end
end


%% merge labels with the same anchor
assert(length(labels) > 0);
merged_labels = labels(1);
for j = 2:length(labels)
    
    index = find(arrayfun(@(x)(x.anchor == labels(j).anchor), merged_labels));
    
    if isempty(labels(j).positives.ids)
        fprintf('pos: %d, neg:%d\n', length(labels(j).positives.ids), length(labels(j).negatives.ids));
        fprintf('skipping unlabeled anchor: %d\n', labels(j).anchor);
        continue;
    end

    if isempty(index)
        merged_labels = [merged_labels labels(j)];
    else
        fprintf('merging two labels with the same anchor: %d\n', labels(j).anchor);
        assert(length(index) == 1);
        
        merged_labels(index).positives.ids = [merged_labels(index).positives.ids...
                                                         labels(j).positives.ids];
        merged_labels(index).positives.flipval = [merged_labels(index).positives.flipval...
                                                             labels(j).positives.flipval];
        % remove duplicates
        [merged_labels(index).positives.ids, perm] = unique(merged_labels(index).positives.ids);
        merged_labels(index).positives.flipval = merged_labels(index).positives.flipval(perm);
                                                   
        
        merged_labels(index).negatives.ids = [merged_labels(index).negatives.ids...
                                                         labels(j).negatives.ids];
        merged_labels(index).negatives.flipval = [merged_labels(index).negatives.flipval...
                                                             labels(j).negatives.flipval];        
        % remove duplicates                                            
        [merged_labels(index).negatives.ids, perm] = unique(merged_labels(index).negatives.ids);
        merged_labels(index).negatives.flipval = merged_labels(index).negatives.flipval(perm);
    end

end

labels = merged_labels;
output_filename = ['labels_' category_name filename_suffix '.mat'];

save(fullfile(labeling_dir_path, 'merged_data', output_filename), '-v7.3', ...
    'labels', 'category_name', 'category_offset', 'dataset_path');
end
