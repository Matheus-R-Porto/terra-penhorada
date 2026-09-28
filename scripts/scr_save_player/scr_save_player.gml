function save_player_write(_data) {
    if (!instance_exists(obj_player)) {
        return _data;
    }

    _data.player_x = obj_player.x;
    _data.player_y = obj_player.y;

    _data.energy = obj_player.energy;
    _data.max_energy = obj_player.max_energy;

    if (variable_instance_exists(obj_player.id, "faint_count")) {
        _data.faint_count = obj_player.faint_count;
    }
    else {
        _data.faint_count = 0;
    }

    _data.carry_weight_max = obj_player.carry_weight_max;

    return _data;
}

function save_player_read(_data) {
    if (!instance_exists(obj_player)) {
        ui_message("Erro: player nao encontrado.", 2);
        return false;
    }

    if (variable_struct_exists(_data, "player_x")) {
        obj_player.x = _data.player_x;
    }

    if (variable_struct_exists(_data, "player_y")) {
        obj_player.y = _data.player_y;
    }

    if (variable_struct_exists(_data, "energy")) {
        obj_player.energy = _data.energy;
    }

    if (variable_struct_exists(_data, "max_energy")) {
        obj_player.max_energy = _data.max_energy;
    }

    if (variable_struct_exists(_data, "faint_count")) {
        obj_player.faint_count = _data.faint_count;
    }
    else {
        obj_player.faint_count = 0;
    }

    if (!variable_instance_exists(obj_player.id, "base_move_speed")) {
        obj_player.base_move_speed = PLAYER_MOVE_SPEED;
    }

    if (!variable_instance_exists(obj_player.id, "min_fatigue_energy")) {
        obj_player.min_fatigue_energy = -100;
    }

    if (!variable_instance_exists(obj_player.id, "slow_fatigue_energy")) {
        obj_player.slow_fatigue_energy = -50;
    }

    if (!variable_instance_exists(obj_player.id, "fatigue_drain_timer")) {
        obj_player.fatigue_drain_timer = 0;
    }

    if (!variable_instance_exists(obj_player.id, "fatigue_drain_frames")) {
        obj_player.fatigue_drain_frames = 60;
    }

    if (!variable_instance_exists(obj_player.id, "is_fainting")) {
        obj_player.is_fainting = false;
    }

    player_apply_fatigue_speed(obj_player);

    if (variable_struct_exists(_data, "carry_weight_max")) {
        obj_player.carry_weight_max = _data.carry_weight_max;
    }

    return true;
}