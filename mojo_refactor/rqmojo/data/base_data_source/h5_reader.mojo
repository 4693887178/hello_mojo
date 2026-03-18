"""
RQAlpha Mojo - HDF5 Storage Reader
Uses Python h5py for HDF5 file reading
"""

from collections import List, Dict
from python import Python


struct H5Reader(Movable):
    var _path: String

    fn __init__(out self, path: String):
        self._path = path

    fn read_dataset(ref self, dataset_name: String) raises -> List[Dict[String, Float64]]:
        var py = Python()
        var h5py = py.import_module("h5py")
        var np = py.import_module("numpy")
        
        var f = h5py.File(self._path, "r")
        try:
            var data = f[dataset_name]
            var result = List[Dict[String, Float64]]()
            
            var py_list = data[:]
            for i in range(len(py_list)):
                var row = py_list[i]
                var row_dict = Dict[String, Float64]()
                for field_name in row.dtype.names:
                    var val = row[field_name]
                    row_dict[String(field_name)] = Float64(val)
                result.append(row_dict^)
            return result^
        except:
            return List[Dict[String, Float64]]()

    fn get_date_range(ref self, dataset_name: String) raises -> Tuple[Int, Int]:
        var py = Python()
        var h5py = py.import_module("h5py")
        
        var f = h5py.File(self._path, "r")
        try:
            var data = f[dataset_name]
            var first = data[0]
            var last = data[-1]
            var start_dt = Int(first["datetime"])
            var end_dt = Int(last["datetime"])
            return (start_dt, end_dt)
        except:
            return (20050104, 20050104)

    fn get_dataset_names(ref self) raises -> List[String]:
        var py = Python()
        var h5py = py.import_module("h5py")
        
        var f = h5py.File(self._path, "r")
        var result = List[String]()
        try:
            var keys = list(f.keys())
            for i in range(len(keys)):
                result.append(String(keys[i]))
        except:
            pass
        return result^


fn create_h5_reader(path: String) -> H5Reader:
    return H5Reader(path)
