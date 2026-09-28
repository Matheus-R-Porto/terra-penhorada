function save_get_current_slot() {
    if (!variable_global_exists("current_save_slot")) {
        global.current_save_slot = 1;
    }

    global.current_save_slot = clamp(global.current_save_slot, 1, 3);

    return global.current_save_slot;
}
function save_set_current_slot(_slot) {
    global.current_save_slot = clamp(_slot, 1, 3);
}
function save_get_file_name_for_slot(_slot) {
    var slot = clamp(_slot, 1, 3);

    return "save_p2_slot_" + string(slot) + ".json";
}
function save_get_file_name() {
    return save_get_file_name_for_slot(save_get_current_slot());
}
function save_slot_exists(_slot) {
    return file_exists(save_get_file_name_for_slot(_slot));
}

function save_game(_is_auto = false) {
    if (!instance_exists(obj_player)) {
        ui_message("Erro: player nao encontrado.", 2);
        return false;
    }

    if (!instance_exists(obj_time)) {
        ui_message("Erro: tempo nao encontrado.", 2);
        return false;
    }

    var data = save_core_create_data();
	
	data = save_economy_write(data);
	data = save_reputation_write(data);

    // Player / inventario / hotbar
	data = save_player_write(data);
	data = save_inventory_write(data);

    // Tempo / calendario / clima / divida
	data = save_time_debt_write(data);

    // Mundo: plantações, baús e minérios
	data = save_world_write(data);

	// Máquinas
	data = save_machines_write(data);
	
	// Contratos
	data = save_contracts_write(data);
	
	// Pecuaria
	data = save_livestock_write(data);

    save_core_write_file(data);

    if (_is_auto) {
	    ui_message("Autosave realizado no slot " + string(save_get_current_slot()) + ".", 2);
	}
	else {
	    ui_message("Jogo salvo no slot " + string(save_get_current_slot()) + ".", 2);
	}

    return true;
}
function load_game() {
    var file_name = save_get_file_name();

    show_debug_message("Tentando carregar slot " + string(save_get_current_slot()) + ": " + file_name);

    var data = save_core_read_file();

    if (!save_core_is_valid_data(data)) {
        show_debug_message("Dados de save invalidos ou inexistentes.");
        return false;
    }

    if (is_undefined(data)) {
        ui_message("Erro ao carregar save.", 2);
        show_debug_message("json_parse retornou undefined.");
        return false;
    }

    if (!instance_exists(obj_player)) {
        ui_message("Erro: player nao encontrado.", 2);
        return false;
    }

    if (!instance_exists(obj_time)) {
        ui_message("Erro: tempo nao encontrado.", 2);
        return false;
    }
	
	save_economy_read(data);
	save_reputation_read(data);

    // Player / inventario / hotbar
	save_player_read(data);
	save_inventory_read(data);

    // Tempo / calendario / clima / divida
	save_time_debt_read(data);
	day_overlay_apply_current_phase();

    // Mundo: plantações, baús e minérios
	save_world_read(data);
	
	/// Máquinas
	save_machines_read(data);
	
	// Contratos
	save_contracts_read(data);
	
	// Pecuaria
	save_livestock_read(data);

    ui_message("Jogo carregado.", 2);
    show_debug_message("Jogo carregado de: " + file_name);

    return true;
}
