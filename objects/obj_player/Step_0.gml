if (menu_is_blocking_gameplay()) {
    interaction_prompt = "";
    action_prompt = "";
    exit;
}

if (player_update_fatigue(id)) {
    exit;
}
if (contract_panel_open) {
    interaction_prompt = "";
    action_prompt = "";
    player_update_contract_panel();
}
else if (npc_panel_open) {
    interaction_prompt = "";
    action_prompt = "";
    player_update_npc_panel();
}
else if (chicken_panel_open) {
    interaction_prompt = "";
    action_prompt = "";
    player_update_chicken_panel();
}
else if (debug_panel_open) {
    interaction_prompt = "";
    action_prompt = "";
    player_update_debug_panel();
}
else if (inventory_panel_open) {
    interaction_prompt = "";
    action_prompt = "";
    player_update_inventory_panel();
}
else if (chest_panel_open) {
    interaction_prompt = "";
    action_prompt = "";
    player_update_chest_panel();
}
else if (furnace_panel_open) {
    interaction_prompt = "";
    action_prompt = "";
    player_update_furnace_panel();
}
else if (workbench_panel_open) {
    interaction_prompt = "";
    action_prompt = "";
    player_update_workbench_panel();
}
else if (seed_shop_open) {
    interaction_prompt = "";
    action_prompt = "";
    player_update_seed_shop_panel();
}
else if (sell_panel_open) {
    interaction_prompt = "";
    action_prompt = "";
    player_update_sell_panel();
}
else {
    player_update_movement();

    hotbar_update_selection(id);

    player_update_interaction_prompt();

    // Abrir inventario
    if (keyboard_check_pressed(ord("I"))) {
        inventory_panel_open = true;
        inventory_panel_side = 0;
        inventory_panel_inventory_index = 0;
        inventory_panel_hotbar_index = 0;

        ui_message("Inventario aberto.", 1);
    }

    // Abrir painel de debug
    if (keyboard_check_pressed(ord("Z"))) {
        debug_panel_open = true;
        debug_category = 0;
        debug_selected = 0;
        debug_amount = 1;

        ui_message("Debug aberto.", 1);
    }
		
	// Abrir painel de contratos
	if (keyboard_check_pressed(ord("C"))) {
	    contract_panel_open = true;
	    contract_panel_selected = 0;
	    ui_message("Contratos aberto.", 1);
	}
		
	// Modo engenheiro
	if (keyboard_check_pressed(ord("V"))) {
	    engineer_toggle();
	}

    // Interacao contextual
    if (keyboard_check_pressed(ord("E"))) {
        player_interact();
    }

    // Regar plantacao
    if (keyboard_check_pressed(ord("R"))) {
        player_water_crop_plot_under_mouse();
    }

    // Minerar
    if (keyboard_check_pressed(ord("X"))) {
        player_mine_ore_under_mouse();
    }

    // Posicionar item da hotbar
    if (mouse_check_button_pressed(mb_left)) {
        machine_place_selected_hotbar_item(id);
    }

    // Debug/temporario: salvar
    if (keyboard_check_pressed(vk_f5)) {
        save_game();
    }

    // Debug/temporario: carregar
    if (keyboard_check_pressed(vk_f9)) {
        load_game();
    }

    // Aqui podem ficar temporariamente outras teclas antigas,
    // mas o ideal é ir removendo depois que o painel de debug funcionar.
}