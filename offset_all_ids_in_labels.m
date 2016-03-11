function [labels] = offset_all_ids_in_labels(labels, increment)

for i = 1:length(labels)
    labels(i).anchor = labels(i).anchor + increment;
    for j = 1:length(labels(i).positives.ids)
        labels(i).positives.ids(j) = labels(i).positives.ids(j) + increment;
    end
    for j = 1:length(labels(i).negatives.ids)
        labels(i).negatives.ids(j) = labels(i).negatives.ids(j) + increment;
    end
end

end