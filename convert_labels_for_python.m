function [anchors, neg_ids, neg_flipvals, pos_ids, pos_flipvals] = convert_labels_for_python(labels)

anchors = arrayfun(@(x) x.anchor, labels);
neg_ids = arrayfun(@(x) x.negatives.ids, labels, 'UniformOutput', false);
neg_flipvals = arrayfun(@(x) x.negatives.flipval, labels, 'UniformOutput', false);

pos_ids = arrayfun(@(x) x.positives.ids, labels, 'UniformOutput', false);
pos_flipvals = arrayfun(@(x) x.positives.flipval, labels, 'UniformOutput', false);



end