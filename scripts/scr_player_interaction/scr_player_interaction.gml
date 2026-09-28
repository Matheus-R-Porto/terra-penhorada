function player_get_crop_plot_under_mouse() {
    return instance_position(mouse_x, mouse_y, obj_crop_plot);
}

function player_get_bed_nearby() {
    var bed = instance_nearest(x, y, obj_bed);

    if (bed == noone) {
        return noone;
    }

    if (point_distance(x, y, bed.x, bed.y) <= INTERACT_RANGE) {
        return bed;
    }

    return noone;
}
	
function player_sleep() {
    ui_message("Voce dormiu.", 2);

    // Recupera energia e remove fadiga
    energy = max_energy;

    if (variable_instance_exists(id, "fatigue_drain_timer")) {
        fatigue_drain_timer = 0;
    }

    if (variable_instance_exists(id, "base_move_speed")) {
        move_speed = base_move_speed;
    }
    else {
        move_speed = PLAYER_MOVE_SPEED;
    }

    // Avanca o dia e processa sistemas
    time_advance_day();

    // Autosave ao dormir.
    save_game(true);

    show_debug_message("Player dormiu. Energia restaurada. Autosave realizado.");
}

function player_use_crop_plot(_plot) {
    if (_plot == noone) {
        return false;
    }

    if (point_distance(x, y, _plot.x, _plot.y) > INTERACT_RANGE) {
        ui_message("Muito longe.", 1);
        return false;
    }

    // Se esta pronto, colher
    if (_plot.planted && _plot.ready) {
        return crop_harvest(_plot, id);
    }

    // Se esta plantado, mas nao pronto, nao rega com E
	if (_plot.planted && !_plot.ready) {
	    ui_message("Use R para regar.", 1);
	    return false;
	}

    // Se esta vazio, tentar plantar semente selecionada
    if (!_plot.planted) {
        var selected_item = hotbar_get_selected_item(id);

        if (selected_item == "") {
            ui_message("Selecione uma semente na hotbar.", 1);
            return false;
        }

        if (!crop_is_seed(selected_item)) {
            ui_message("O item selecionado nao pode ser plantado.", 1);
            return false;
        }

        if (!inventory_has(hotbar_slots, selected_item, 1)) {
            ui_message("Sem semente na hotbar.", 1);
            return false;
        }

        if (crop_plant(_plot, selected_item)) {
            inventory_remove(hotbar_slots, selected_item, 1);
            return true;
        }
    }

    return false;
}

function player_update_interaction_prompt() {
    interaction_prompt = "";

    // Prioridade 1: cama próxima
    var bed = player_get_bed_nearby();

    if (bed != noone) {
        interaction_prompt = "E Dormir";
        return;
    }

    // Prioridade 2: baú próximo
    var chest = storage_get_nearby_chest();

    if (chest != noone) {
        interaction_prompt = "E Abrir bau";
        return;
    }

    // Prioridade 3: fornalha próxima
    var furnace = furnace_get_nearby();

    if (furnace != noone) {
        interaction_prompt = "E Fundir";
        return;
    }
		
	// Prioridade 4: bancada próxima
	var workbench = workbench_get_nearby();

	if (workbench != noone) {
	    interaction_prompt = "E Fabricar";
	    return;
	}
	
	// Prioridade 4.5: maquina de racao próxima
    var feed_maker = feed_maker_get_nearby();

    if (feed_maker != noone) {
        interaction_prompt = "E Fazer racao";
        return;
    }

    // Prioridade 6: loja de sementes próxima
    var seed_shop = seed_shop_get_nearby();

    if (seed_shop != noone) {
        interaction_prompt = "E Comprar";
        return;
    }

    // Prioridade 7: caixa de venda próxima
    var sell_box = sell_box_get_nearby();

    if (sell_box != noone) {
        interaction_prompt = "E Vender";
        return;
    }
	
	// Prioridade 8: alimentador
    var feeder = feeder_get_nearby(id);

    if (feeder != noone) {
        var stored = feeder_get_feed_stored(feeder);
        var capacity = feeder_get_feed_capacity(feeder);

        if (stored >= capacity) {
            interaction_prompt = "Alimentador cheio (" + string(stored) + "/" + string(capacity) + ")";
        }
        else {
            interaction_prompt = "E Abastecer alimentador (" + string(stored) + "/" + string(capacity) + ")";
        }

        return;
    }
	
	// Prioridade 9: ovo no chao
    var egg_drop = livestock_get_egg_drop_nearby(id);

    if (egg_drop != noone) {
        interaction_prompt = "E Pegar ovo";
        return;
    }

    // Prioridade 10: galinha próxima
    var chicken = livestock_get_chicken_nearby(id);

    if (chicken != noone) {
        if (!variable_instance_exists(chicken.id, "fed")) {
            chicken.fed = false;
        }

        if (!variable_instance_exists(chicken.id, "days_without_feed")) {
            chicken.days_without_feed = 0;
        }

        if (!variable_instance_exists(chicken.id, "hungry_limit")) {
            chicken.hungry_limit = 2;
        }

        if (chicken.days_without_feed >= chicken.hungry_limit) {
            interaction_prompt = "E Alimentar galinha faminta";
        }
        else if (chicken.fed) {
            interaction_prompt = "Galinha alimentada";
        }
        else {
            interaction_prompt = "E Ver galinha";
        }

        return;
    }

    // Prioridade 11: solo sob o mouse
    var plot = player_get_crop_plot_under_mouse();

    if (plot != noone) {
        if (point_distance(x, y, plot.x, plot.y) <= INTERACT_RANGE) {
            if (plot.planted && plot.ready) {
                interaction_prompt = "E Colher";
            }
            else if (plot.planted) {
                if (plot.watered) {
                    interaction_prompt = "Regado";
                }
                else {
                    interaction_prompt = "R Regar";
                }
            }
            else {
                interaction_prompt = "E Plantar";
            }
        }
    }
}

function player_interact() {
    // Prioridade 1: cama
    var bed = player_get_bed_nearby();

    if (bed != noone) {
        player_sleep();
        return;
    }

    // Prioridade 2: baú
    var chest = storage_get_nearby_chest();

    if (chest != noone) {
        chest_panel_open = true;
        current_chest = chest;
        chest_panel_side = 0;
        chest_inventory_index = 0;
        chest_storage_index = 0;

        ui_message("Bau aberto.", 1);
        return;
    }

    // Prioridade 3: fornalha
    var furnace = furnace_get_nearby();

    if (furnace != noone) {
        furnace_panel_open = true;
        current_furnace = furnace;

        ui_message("Fornalha aberta.", 1);
        return;
    }
		
	// Prioridade 4: NPC
	var npc_contract = npc_contract_get_nearby(id);

	if (npc_contract != noone) {
	    npc_open_panel(id, npc_contract);
	    return;
	}
		
    // Prioridade 5: bancada
    var workbench = workbench_get_nearby();

    if (workbench != noone) {
        workbench_panel_open = true;
        current_workbench = workbench;
        workbench_selected_recipe = 0;

        ui_message("Bancada aberta.", 1);
        return;
    }
	
	// Prioridade 5.5: maquina de racao
    var feed_maker = feed_maker_get_nearby();

    if (feed_maker != noone) {
        feed_maker_use(id, feed_maker);
        return;
    }

    // Prioridade 6: loja de sementes
    var seed_shop = seed_shop_get_nearby();

    if (seed_shop != noone) {
        seed_shop_open = true;
        seed_shop_selected = 0;
        seed_shop_quantity = 1;

        ui_message("Loja aberta.", 1);
        return;
    }

    // Prioridade 7: caixa de venda
    var sell_box = sell_box_get_nearby();

    if (sell_box != noone) {
        sell_panel_open = true;
        ui_message("Painel de venda aberto.", 1);
        return;
    }
		
	// Prioridade 8: alimentador
    var feeder = feeder_get_nearby(id);

    if (feeder != noone) {
        feeder_add_feed_from_player(id, feeder);
        return;
    }
	
	// Prioridade 9: ovo no chao
    var egg_drop = livestock_get_egg_drop_nearby(id);

    if (egg_drop != noone) {
        livestock_collect_egg_drop(id, egg_drop);
        return;
    }

    // Prioridade 10: galinha
    var chicken = livestock_get_chicken_nearby(id);

	if (chicken != noone) {
	    chicken_open_panel(id, chicken);
	    return;
	}
		
	// Prioridade 10.5: NPC
	var npc_contract = npc_contract_get_nearby(id);

	if (npc_contract != noone) {
	    interaction_prompt = "E Falar com " + npc_get_name(npc_contract);
	    return;
	}

    // Prioridade 11: solo sob o mouse
    var plot = player_get_crop_plot_under_mouse();

    if (plot != noone) {
        player_use_crop_plot(plot);
        return;
    }
		
	// Prioridade 12: gerador
	var gen = generator_get_nearby(id);

	if (gen != noone) {
	    generator_add_coal(id, gen);
	    return true;
	}
}

function player_water_crop_plot_under_mouse() {
    var plot = player_get_crop_plot_under_mouse();

    if (plot == noone) {
        ui_message("Nenhum solo selecionado.", 1);
        return false;
    }

    if (point_distance(x, y, plot.x, plot.y) > INTERACT_RANGE) {
        ui_message("Muito longe.", 1);
        return false;
    }

    return crop_water(plot);
}