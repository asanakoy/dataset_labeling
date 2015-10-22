function [] = merge_labeled_data( dir_path )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

if ~exist(dir_path, 'dir')
    error('Dir does not exist : %s\n', dir_path);
end

labeling_dir_path = '/net/hciserver03/storage/asanakoy/workspace/dataset_labeling';
output_filename = 'long_jump_21.10.mat';

file_list = getFilesInDir(dir_path, '.*\.mat');

for i = 1:length(file_list)
    fprintf('File %d\n', i);
    file = load(fullfile(dir_path, file_list{i}));
    
    if i == 1
        labels = file.labels;
    else
        labels = [labels file.labels];
    end
end

save(fullfile(labeling_dir_path, 'merged_data', output_filename), '-v7.3', 'labels');
end

