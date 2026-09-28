function ui_any_panel_open() {
    if (!instance_exists(obj_player)) {
        return false;
    }

    return obj_player.sell_panel_open
	    || obj_player.seed_shop_open
	    || obj_player.chest_panel_open
	    || obj_player.furnace_panel_open
	    || obj_player.workbench_panel_open
	    || obj_player.inventory_panel_open
	    || obj_player.contract_panel_open
	    || obj_player.npc_panel_open
		|| obj_player.chicken_panel_open
	    || obj_player.debug_panel_open;
}

function player_update_sell_panel() {
    if (!sell_panel_open) {
        return;
    }

    if (keyboard_check_pressed(vk_escape)) {
        sell_panel_open = false;
        ui_message("Caixa de venda fechada.", 1);
        return;
    }

    var sellable_count = sell_count_sellable_slots(id);

    if (sellable_count > 0) {
        if (keyboard_check_pressed(ord("W"))) {
            sell_panel_selected -= 1;
        }

        if (keyboard_check_pressed(ord("S"))) {
            sell_panel_selected += 1;
        }

        sell_panel_selected = clamp(sell_panel_selected, 0, sellable_count - 1);
    }
    else {
        sell_panel_selected = 0;
    }

    // Vende 1 unidade do item selecionado.
    if (keyboard_check_pressed(vk_enter)) {
        sell_selected_one(id);
        return;
    }

    // Vende o stack inteiro selecionado.
    if (keyboard_check_pressed(vk_space)) {
        sell_selected_stack(id);
        return;
    }

    // Vende tudo.
    if (keyboard_check_pressed(ord("T"))) {
        sell_inventory_all(id);
        return;
    }
}
	
function player_update_seed_shop_panel() {
    if (!seed_shop_open) {
        return;
    }

    if (keyboard_check_pressed(vk_escape)) {
        seed_shop_open = false;
        ui_message("Loja fechada.", 1);
        return;
    }

    // Escolher item
    if (keyboard_check_pressed(ord("W"))) {
        seed_shop_selected -= 1;
    }

    if (keyboard_check_pressed(ord("S"))) {
        seed_shop_selected += 1;
    }

    seed_shop_selected = clamp(seed_shop_selected, 0, seed_shop_get_item_count() - 1);

    var selected_item = seed_shop_get_item_id(seed_shop_selected);
    var price = item_get_buy_price(selected_item);

    var money = money_get();
    var max_can_buy = floor(money / price);
    max_can_buy = max(max_can_buy, 0);

    // Alterar quantidade
    if (keyboard_check_pressed(ord("A"))) {
        seed_shop_quantity -= 1;
    }

    if (keyboard_check_pressed(ord("D"))) {
        seed_shop_quantity += 1;
    }

    seed_shop_quantity = clamp(seed_shop_quantity, 1, max(1, max_can_buy));

    // Comprar
    if (keyboard_check_pressed(vk_enter)) {
        seed_shop_buy_selected(id);
    }
}
	
function player_update_chest_panel() {
    if (!chest_panel_open) {
        return;
    }

    if (current_chest == noone || !instance_exists(current_chest)) {
        chest_panel_open = false;
        current_chest = noone;
        ui_message("Bau indisponivel.", 1);
        return;
    }

    if (keyboard_check_pressed(vk_escape)) {
        chest_panel_open = false;
        current_chest = noone;
        ui_message("Bau fechado.", 1);
        return;
    }

    // Alternar lado
    if (keyboard_check_pressed(vk_tab)) {
        if (chest_panel_side == 0) {
            chest_panel_side = 1;
        }
        else {
            chest_panel_side = 0;
        }
    }
	
	if (mouse_check_button_pressed(mb_left)) {
        var layout = ui_chest_get_layout();

        var mx = device_mouse_x_to_gui(0);
        var my = device_mouse_y_to_gui(0);

        var inv_index = ui_get_slot_at_grid(
            inventory_slots,
            mx,
            my,
            layout.inv_x,
            layout.grid_y,
            5,
            layout.slot_w,
            layout.slot_h,
            layout.gap
        );

        var chest_index = ui_get_slot_at_grid(
            current_chest.storage_slots,
            mx,
            my,
            layout.chest_x,
            layout.grid_y,
            5,
            layout.slot_w,
            layout.slot_h,
            layout.gap
        );

        var ctrl_down = keyboard_check(vk_control);

        if (inv_index >= 0) {
            if (ctrl_down && !ui_cursor_has_item(id)) {
                ui_transfer_stack_to_slots(id, inventory_slots, inv_index, current_chest.storage_slots, false);
            }
            else if (!ui_cursor_has_item(id)) {
                ui_cursor_pick_from_slot(id, inventory_slots, inv_index);
            }
            else {
                ui_cursor_place_in_slot(id, inventory_slots, inv_index, true);
            }

            return;
        }

        if (chest_index >= 0) {
            if (ctrl_down && !ui_cursor_has_item(id)) {
                ui_transfer_stack_to_slots(id, current_chest.storage_slots, chest_index, inventory_slots, true);
            }
            else if (!ui_cursor_has_item(id)) {
                ui_cursor_pick_from_slot(id, current_chest.storage_slots, chest_index);
            }
            else {
                ui_cursor_place_in_slot(id, current_chest.storage_slots, chest_index, false);
            }

            return;
        }
    }

    // Navegar
    if (keyboard_check_pressed(ord("W"))) {
        if (chest_panel_side == 0) {
            chest_inventory_index -= 1;
        }
        else {
            chest_storage_index -= 1;
        }
    }

    if (keyboard_check_pressed(ord("S"))) {
        if (chest_panel_side == 0) {
            chest_inventory_index += 1;
        }
        else {
            chest_storage_index += 1;
        }
    }

    var inv_count = storage_count_filled_slots(inventory_slots);
    var chest_count = storage_count_filled_slots(current_chest.storage_slots);

    chest_inventory_index = clamp(chest_inventory_index, 0, max(inv_count - 1, 0));
    chest_storage_index = clamp(chest_storage_index, 0, max(chest_count - 1, 0));

    // Mover item
    if (keyboard_check_pressed(vk_enter)) {
        if (chest_panel_side == 0) {
            // inventario -> bau
            storage_move_one_item(
			    obj_player.inventory_slots,
			    obj_player.current_chest.storage_slots,
			    obj_player.chest_inventory_index,
			    999999,
			    false
			);
        }
        else {
            // bau -> inventario
            storage_move_one_item(
			    obj_player.current_chest.storage_slots,
			    obj_player.inventory_slots,
			    obj_player.chest_storage_index,
			    obj_player.carry_weight_max,
			    true
			);
        }
    }
}
	
function player_update_furnace_panel() {
    if (!furnace_panel_open) {
        return;
    }

    if (current_furnace == noone || !instance_exists(current_furnace)) {
        furnace_panel_open = false;
        current_furnace = noone;
        ui_message("Fornalha indisponivel.", 1);
        return;
    }

    if (keyboard_check_pressed(vk_escape)) {
        furnace_panel_open = false;
        current_furnace = noone;
        ui_message("Fornalha fechada.", 1);
        return;
    }

    if (keyboard_check_pressed(vk_enter)) {
        furnace_process_basic_bar(id);
    }
}
	
function player_update_workbench_panel() {
    if (!workbench_panel_open) {
        return;
    }

    if (current_workbench == noone || !instance_exists(current_workbench)) {
        workbench_panel_open = false;
        current_workbench = noone;
        ui_message("Bancada indisponivel.", 1);
        return;
    }

    if (keyboard_check_pressed(vk_escape)) {
        workbench_panel_open = false;
        current_workbench = noone;
        ui_message("Bancada fechada.", 1);
        return;
    }

    if (keyboard_check_pressed(ord("W"))) {
        workbench_selected_recipe -= 1;
    }

    if (keyboard_check_pressed(ord("S"))) {
        workbench_selected_recipe += 1;
    }

    workbench_selected_recipe = clamp(
        workbench_selected_recipe,
        0,
        craft_get_recipe_count() - 1
    );

    if (keyboard_check_pressed(vk_enter)) {
        craft_make_recipe(id, workbench_selected_recipe);
    }
}

function player_update_inventory_panel() {
    if (!inventory_panel_open) {
        return;
    }
	if (mouse_check_button_pressed(mb_left)) {
    var layout = ui_inventory_get_layout();

    var mx = device_mouse_x_to_gui(0);
    var my = device_mouse_y_to_gui(0);

    var inv_index = ui_get_slot_at_grid(
        inventory_slots,
        mx,
        my,
        layout.grid_x,
        layout.inventory_y,
        5,
        layout.slot_w,
        layout.slot_h,
        layout.gap
    );

    var hotbar_index = ui_get_slot_at_grid(
        hotbar_slots,
        mx,
        my,
        layout.grid_x,
        layout.hotbar_y,
        5,
        layout.slot_w,
        layout.slot_h,
        layout.gap
    );

    var ctrl_down = keyboard_check(vk_control);

    if (inv_index >= 0) {
        if (ctrl_down && !ui_cursor_has_item(id)) {
            ui_transfer_stack_to_slots(id, inventory_slots, inv_index, hotbar_slots, true);
        }
        else if (!ui_cursor_has_item(id)) {
            ui_cursor_pick_from_slot(id, inventory_slots, inv_index);
        }
        else {
            ui_cursor_place_in_slot(id, inventory_slots, inv_index, true);
        }

        return;
    }

    if (hotbar_index >= 0) {
        if (ctrl_down && !ui_cursor_has_item(id)) {
            ui_transfer_stack_to_slots(id, hotbar_slots, hotbar_index, inventory_slots, true);
        }
        else if (!ui_cursor_has_item(id)) {
            ui_cursor_pick_from_slot(id, hotbar_slots, hotbar_index);
        }
        else {
            ui_cursor_place_in_slot(id, hotbar_slots, hotbar_index, true);
        }

        return;
    }
}

    if (keyboard_check_pressed(vk_escape)) {
	    if (ui_cursor_has_item(id)) {
	        ui_message("Coloque o item antes de fechar.", 1);
	        return;
	    }

	    inventory_panel_open = false;
	    ui_message("Inventario fechado.", 1);
	    return;
	}

    // Alternar lado
    if (keyboard_check_pressed(vk_tab)) {
        if (inventory_panel_side == 0) {
            inventory_panel_side = 1;
        }
        else {
            inventory_panel_side = 0;
        }
    }

    // Navegar
    if (keyboard_check_pressed(ord("W"))) {
        if (inventory_panel_side == 0) {
            inventory_panel_inventory_index -= 1;
        }
        else {
            inventory_panel_hotbar_index -= 1;
        }
    }

    if (keyboard_check_pressed(ord("S"))) {
        if (inventory_panel_side == 0) {
            inventory_panel_inventory_index += 1;
        }
        else {
            inventory_panel_hotbar_index += 1;
        }
    }

    var inv_count = storage_count_filled_slots(inventory_slots);
    var hotbar_count = storage_count_filled_slots(hotbar_slots);

    inventory_panel_inventory_index = clamp(inventory_panel_inventory_index, 0, max(inv_count - 1, 0));
    inventory_panel_hotbar_index = clamp(inventory_panel_hotbar_index, 0, max(hotbar_count - 1, 0));

    // Mover 1 item
    if (keyboard_check_pressed(vk_enter)) {
        if (inventory_panel_side == 0) {
            // inventario -> hotbar
            storage_move_one_item(
			    obj_player.inventory_slots,
			    obj_player.hotbar_slots,
			    obj_player.inventory_panel_inventory_index,
			    999999,
			    false
			);
        }
        else {
            // hotbar -> inventario
            storage_move_one_item(
			    obj_player.hotbar_slots,
			    obj_player.inventory_slots,
			    obj_player.inventory_panel_hotbar_index,
			    999999,
			    false
			);
        }
    }
}
	
function player_update_debug_panel() {
    if (!debug_panel_open) {
        return;
    }

    if (keyboard_check_pressed(vk_escape)) {
        debug_panel_open = false;
        ui_message("Debug fechado.", 1);
        return;
    }

    // Trocar categoria
    if (keyboard_check_pressed(ord("Q"))) {
        debug_category -= 1;
        debug_selected = 0;
    }

    if (keyboard_check_pressed(ord("E"))) {
        debug_category += 1;
        debug_selected = 0;
    }

    debug_category = clamp(debug_category, 0, debug_get_category_count() - 1);

    // Navegar opções
    if (keyboard_check_pressed(ord("W"))) {
        debug_selected -= 1;
    }

    if (keyboard_check_pressed(ord("S"))) {
        debug_selected += 1;
    }

    debug_selected = clamp(debug_selected, 0, debug_get_option_count(debug_category) - 1);

    // Quantidade
    if (keyboard_check_pressed(ord("A"))) {
        debug_amount -= 1;
    }

    if (keyboard_check_pressed(ord("D"))) {
        debug_amount += 1;
    }

    if (keyboard_check_pressed(vk_shift)) {
        if (keyboard_check_pressed(ord("A"))) {
            debug_amount -= 9;
        }

        if (keyboard_check_pressed(ord("D"))) {
            debug_amount += 9;
        }
    }

    debug_amount = clamp(debug_amount, 1, 9999);

    // Executar
    if (keyboard_check_pressed(vk_enter)) {
        debug_execute_option(id);
    }
}