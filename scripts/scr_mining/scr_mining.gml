function ore_get_under_mouse() {
    return instance_position(mouse_x, mouse_y, obj_resource_ore);
}

function ore_update_sprite(_ore) {
    if (_ore == noone) {
        return;
    }

    if (_ore.mined) {
        _ore.visible = false;
        return;
    }

    _ore.visible = true;

    if (!variable_instance_exists(_ore.id, "drop_item")) {
        _ore.drop_item = "ore";
    }

    if (_ore.drop_item == "coal") {
        // Provisorio: se ainda nao tiver sprite proprio de carvao,
        // pode usar o mesmo sprite de minerio.
        _ore.sprite_index = spr_ore_rock;
    }
    else {
        _ore.sprite_index = spr_ore_rock;
    }
}

function ore_can_mine(_ore, _player) {
    if (_ore == noone) {
        ui_message("Nenhum minerio selecionado.", 1);
        return false;
    }

    if (_ore.mined) {
        ui_message("Este minerio ja foi minerado.", 1);
        return false;
    }

    if (point_distance(_player.x, _player.y, _ore.x, _ore.y) > INTERACT_RANGE) {
        ui_message("Muito longe.", 1);
        return false;
    }

    if (_player.energy < _ore.energy_cost) {
        ui_message("Energia insuficiente.", 1);
        return false;
    }

    if (!player_can_add_item(_player, _ore.drop_item, _ore.drop_amount)) {
	    ui_message("Inventario cheio ou pesado demais.", 2);
	    return false;
	}

    return true;
}

function ore_mine(_ore, _player) {
    if (!ore_can_mine(_ore, _player)) {
        return false;
    }

    if (!player_add_item_to_inventory(_player, _ore.drop_item, _ore.drop_amount)) {
	    ui_message("Inventario cheio ou pesado demais.", 2);
	    show_debug_message("Mineracao falhou depois da validacao. Energia nao foi consumida.");
	    return false;
	}

	_player.energy -= _ore.energy_cost;
	_player.energy = max(_player.energy, 0);

    _ore.mined = true;
    _ore.respawn_days_left = _ore.respawn_days_required;

    ore_update_sprite(_ore);

    ui_message("Coletou " + item_get_name(_ore.drop_item) + ".", 1);

    show_debug_message(
        "Minerou " +
        item_get_name(_ore.drop_item) +
        " x" +
        string(_ore.drop_amount) +
        ". Respawn em " +
        string(_ore.respawn_days_left) +
        " dias."
    );

    return true;
}

function player_mine_ore_under_mouse() {
    var ore = ore_get_under_mouse();

    if (ore == noone) {
        ui_message("Nenhum minerio selecionado.", 1);
        return false;
    }

    return ore_mine(ore, id);
}

function ores_process_next_day() {
    var processed = 0;

    for (var i = 0; i < instance_number(obj_resource_ore); i++) {
        var ore = instance_find(obj_resource_ore, i);

        if (ore.mined) {
            ore.respawn_days_left -= 1;
            processed += 1;

            if (ore.respawn_days_left <= 0) {
                ore.mined = false;
                ore.respawn_days_left = 0;

                show_debug_message("Minerio respawnou em x:" + string(ore.x) + " y:" + string(ore.y));
            }

            ore_update_sprite(ore);
        }
    }

    show_debug_message("Minerios processados no novo dia: " + string(processed));
}