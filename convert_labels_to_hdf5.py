import numpy as np
import sys
import glob
import hdf5storage
import os
import h5py


def parse(mat):
    """
    Parse matfile structure. Convert 1-based indices to 0-based.
    :param mat:
    :return:
    """
    indices_offset = 1

    attrs = dict()
    attrs['category_offset'] = int(mat['category_offset'][0, 0])
    for key in ['category_name', 'dataset_path']:
        attrs[key] = str(mat[key][0, 0])

    datasets = dict()
    for key in ['neg_flipvals', 'pos_ids', 'neg_ids', 'pos_flipvals']:
        datasets[key] = np.asarray([mat[key][0, i].astype(np.int32).reshape(-1) for i in xrange(mat[key].shape[1])])
        if datasets[key].dtype != np.int32:
            # special type to store variable length arrays in hdf5 dataset
            # WARNING: (Possible numpy/h5py bug) don't cast normal 2D array to vlen type - it will overwrite the original type of rows!
            datasets[key] = datasets[key].astype(h5py.special_dtype(vlen=np.dtype('int32')))
    datasets['anchors'] = mat['anchors'].astype(np.int32).reshape(-1)

    # Convert 1-based indices to 0-based
    for key in ['pos_ids', 'neg_ids', 'anchors']:
        datasets[key] -= indices_offset

    return attrs, datasets


def main(argv):
    assert len(argv) == 2, 'Usage: source_dir output_dir'
    source_dir = argv[0]
    output_dir = argv[1]

    pathes = glob.glob(source_dir + "/*.mat")

    for mat_path in pathes:
        print 'Converting {}'.format(mat_path)
        mat = hdf5storage.loadmat(mat_path)
        attrs, datasets = parse(mat)

        name = os.path.splitext(os.path.basename(mat_path))[0]
        f = h5py.File(os.path.join(output_dir, name + '.hdf5'), 'w')
        for key, val in attrs.items():
            f.attrs[key] = val
        for key, val in datasets.iteritems():
            f.create_dataset(key, data=val)


if __name__ == '__main__':
    main(['converted_for_python_19.02.16/', 'labels_hdf5/'])
    # main(sys.argv[1:])
