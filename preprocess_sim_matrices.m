function [] = preprocess_sim_matrices()
%PREPROCESS_SIM_MATRICES Summary of this function goes here
%   Detailed explanation goes here

dataset_path = '/net/hciserver03/storage/asanakoy/workspace/ucf_sports';
data_info = load(DatasetStructure.getDataInfoPath(dataset_path));
crops = load(fullfile(DatasetStructure.getDataDirPath(dataset_path), 'crops_global_info.mat'));
crops = crops.crops;

for i = 1:length(data_info.categoryNames)
    category_name = data_info.categoryNames{i};
    fprintf('preprocess_sim_matrices for %s ...\n', category_name);
    path_sim = ['/export/home/asanakoy/workspace/ucf_sports/sim_pedro_hog/sim_hog_pedro_', category_name, '.mat'];
    output_path = ['/export/home/asanakoy/workspace/ucf_sports/sim_pedro_hog_for_labeling/sim_hog_pedro_', category_name, '.mat'];
    load(path_sim);
    
    category_offset = get_category_offset(category_name, data_info);
    category_size = get_category_size(category_name, data_info);
    
    seq_names = sort(unique(arrayfun(@(x)x.vname, ...
        crops(category_offset + 1:category_offset + category_size), 'UniformOutput', false)));
    
    image_names = cell(1, category_size);
    
    for image_id = category_offset + 1:category_offset + category_size
        pos = strfind(crops(image_id).img_relative_path, '/');
        assert(length(pos) == 2);
        pos = pos(1) + 1;
        image_names{image_id - category_offset} = ['./', crops(image_id).img_relative_path(pos:end)]; % string in format './seq_name/image_name.ext'
    end
    
    simMatrix_flipped = simMatrix_flipped - diag(diag(simMatrix_flipped));
    [simMatrix, flipval] = max(cat(3, simMatrix, simMatrix_flipped), [], 3);
    flipval = uint8(flipval - 1);
    
    save(output_path, 'simMatrix', 'flipval', 'image_names', 'seq_names', '-v7.3');
end




end

