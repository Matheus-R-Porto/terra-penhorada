function snap_to_grid(_value, _grid_size) {
    return floor(_value / _grid_size) * _grid_size + (_grid_size / 2);
}

function grid_snap_x(_x) {
    return snap_to_grid(_x, GRID_SIZE);
}

function grid_snap_y(_y) {
    return snap_to_grid(_y, GRID_SIZE);
}