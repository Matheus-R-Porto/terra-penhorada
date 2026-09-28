function player_is_night_final_phase() {
    if (!instance_exists(obj_time)) {
        return false;
    }

    if (variable_instance_exists(obj_time.id, "time_phase")) {
        if (obj_time.time_phase >= 2) {
            return true;
        }
    }

    if (variable_instance_exists(obj_time.id, "phase_name")) {
        if (obj_time.phase_name == "Noite") {
            return true;
        }
    }

    return false;
}

function player_close_all_panels_for_faint(_player) {
    if (_player == noone) {
        return;
    }

    _player.inventory_panel_open = false;
    _player.chest_panel_open = false;
    _player.furnace_panel_open = false;
    _player.workbench_panel_open = false;
    _player.seed_shop_open = false;
    _player.sell_panel_open = false;
    _player.debug_panel_open = false;
    _player.contract_panel_open = false;

    _player.interaction_prompt = "";
    _player.action_prompt = "";
}

function player_apply_fatigue_speed(_player) {
    if (_player == noone) {
        return;
    }

    if (!variable_instance_exists(_player.id, "base_move_speed")) {
        _player.base_move_speed = PLAYER_MOVE_SPEED;
    }

    if (!variable_instance_exists(_player.id, "slow_fatigue_energy")) {
        _player.slow_fatigue_energy = -50;
    }

    if (_player.energy <= _player.slow_fatigue_energy) {
        _player.move_speed = _player.base_move_speed * 0.55;
    }
    else {
        _player.move_speed = _player.base_move_speed;
    }
}

function player_move_to_bed_after_faint(_player) {
    if (_player == noone) {
        return;
    }

    if (instance_exists(obj_bed)) {
        var bed = instance_find(obj_bed, 0);

        _player.x = bed.x;
        _player.y = bed.y + 32;
    }
}

function player_faint_from_exhaustion(_player) {
    if (_player == noone) {
        return false;
    }

    if (!variable_instance_exists(_player.id, "is_fainting")) {
        _player.is_fainting = false;
    }

    if (_player.is_fainting) {
        return false;
    }

    _player.is_fainting = true;

    player_close_all_panels_for_faint(_player);

    if (!variable_instance_exists(_player.id, "faint_count")) {
        _player.faint_count = 0;
    }

    _player.faint_count += 1;

    ui_message("Voce desmaiou de exaustao.", 3);

    // Passa o dia e processa sistemas.
    time_advance_day();

    // Volta para a cama e recupera energia.
    player_move_to_bed_after_faint(_player);

    _player.energy = _player.max_energy;
    _player.fatigue_drain_timer = 0;
    _player.move_speed = _player.base_move_speed;

    // Autosave depois do desmaio.
    // Se voce ainda NAO fez o bloco de save slots, troque temporariamente por save_game();
    save_game(true);

    show_debug_message("Player desmaiou por exaustao. Total de desmaios: " + string(_player.faint_count));

    _player.is_fainting = false;

    return true;
}

function player_update_fatigue(_player) {
    if (_player == noone) {
        return false;
    }

    if (!variable_instance_exists(_player.id, "min_fatigue_energy")) {
        _player.min_fatigue_energy = -100;
    }

    if (!variable_instance_exists(_player.id, "slow_fatigue_energy")) {
        _player.slow_fatigue_energy = -50;
    }

    if (!variable_instance_exists(_player.id, "fatigue_drain_timer")) {
        _player.fatigue_drain_timer = 0;
    }

    if (!variable_instance_exists(_player.id, "fatigue_drain_frames")) {
        _player.fatigue_drain_frames = 60;
    }

    if (!variable_instance_exists(_player.id, "base_move_speed")) {
        _player.base_move_speed = PLAYER_MOVE_SPEED;
    }

    player_apply_fatigue_speed(_player);

    // Fora da noite/fase final, nao drena energia automaticamente.
    if (!player_is_night_final_phase()) {
        _player.fatigue_drain_timer = 0;
        return false;
    }

    _player.fatigue_drain_timer += 1;

    if (_player.fatigue_drain_timer >= _player.fatigue_drain_frames) {
        _player.fatigue_drain_timer = 0;

        _player.energy -= 1;

        if (_player.energy == 0) {
            ui_message("Voce esta sem energia. Melhor dormir.", 2);
        }
        else if (_player.energy == _player.slow_fatigue_energy) {
            ui_message("Voce esta exausto e se movendo mais devagar.", 3);
        }

        if (_player.energy <= _player.min_fatigue_energy) {
            _player.energy = _player.min_fatigue_energy;
            player_faint_from_exhaustion(_player);
            return true;
        }
    }

    return false;
}