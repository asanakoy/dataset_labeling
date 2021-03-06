function [] = merge_labeled_data()

% Merge all data, each category separately from data_dir_path 

data_dir_path = '/net/hciserver03/storage/asanakoy/workspace/ucf_sports/dataset_labeling/to_merge';

dataset_path = '~/workspace/ucf_sports';

if ~exist('data_info', 'var')
    data_info = load(DatasetStructure.getDataInfoPath(dataset_path));
end

for i = 1:length(data_info.categoryNames)
    fprintf('Merging for category %s\n', data_info.categoryNames{i})
    merge_labeled_data(data_dir_path, '', data_info.categoryNames{i}, data_info)
end

end