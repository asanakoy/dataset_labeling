% Convert labels for easy reading in python for each category separately

labels_dir_path = '/net/hciserver03/storage/asanakoy/workspace/dataset_labeling/merged_data_last';
dataset_path = '~/workspace/OlympicSports';
output_dir_path = 'converted_for_python_19.02.16';

if ~exist('data_info', 'var')
    data_info = load(DatasetStructure.getDataInfoPath(dataset_path));
end

for i = 1:length(data_info.categoryNames)
    fprintf('Converting for category %s\n', data_info.categoryNames{i})
    file_basename = sprintf('labels_%s.mat', data_info.categoryNames{i});
    load(fullfile(labels_dir_path, file_basename));
    whos labels
    [anchors, neg_ids, neg_flipvals, pos_ids, pos_flipvals] = ...
        convert_labels_for_python(labels);
    assert(length(labels) == length(anchors) && length(neg_ids) == length(pos_ids) && length(labels) == length(pos_ids));
    file_to_save = fullfile(output_dir_path, file_basename);
    save(file_to_save, '-v7.3', 'anchors', 'neg_ids', 'neg_flipvals', 'pos_ids', 'pos_flipvals', ...
        'category_name', 'category_offset', 'dataset_path');
end
