function workbench_get_nearby() {
    var bench = instance_nearest(obj_player.x, obj_player.y, obj_station_workbench);

    if (bench == noone) {
        return noone;
    }

    if (point_distance(obj_player.x, obj_player.y, bench.x, bench.y) <= INTERACT_RANGE) {
        return bench;
    }

    return noone;
}

function craft_get_recipe_count() {
    return 3;
}

function craft_get_recipe_name(_index) {
    switch (_index) {
        case 0: return "Irrigador basico";
        case 1: return "Alimentador basico";
        case 2: return "Bau";
    }

    return "Receita desconhecida";
}

function craft_get_recipe_output_item(_index) {
    switch (_index) {
        case 0: return "sprinkler_item";
        case 1: return "feeder_item";
        case 2: return "chest_item";
    }

    return "";
}

function craft_get_recipe_output_amount(_index) {
    switch (_index) {
        case 0: return 1;
        case 1: return 1;
        case 2: return 1;
    }

    return 0;
}

function craft_get_recipe_description(_index) {
    switch (_index) {
        case 0: return "Custa: 2 barras";
        case 1: return "Custa: 2 barras + 5 milho";
        case 2: return "Custa: 1 barra";
    }

    return "";
}

function craft_can_make_recipe(_player, _index) {
    var output_item = craft_get_recipe_output_item(_index);
    var output_amount = craft_get_recipe_output_amount(_index);

    if (output_item == "" || output_amount <= 0) {
        ui_message("Receita invalida.", 1);
        return false;
    }

    if (!player_can_add_item(_player, output_item, output_amount)) {
        ui_message("Inventario cheio ou pesado demais.", 2);
        return false;
    }

    switch (_index) {
        case 0:
            if (!player_has_item_anywhere(_player, "bar", 2)) {
                ui_message("Precisa de 2 barras.", 1);
                return false;
            }

            return true;

        case 1:
            if (!player_has_item_anywhere(_player, "bar", 2)) {
                ui_message("Precisa de 2 barras.", 1);
                return false;
            }

            if (!player_has_item_anywhere(_player, "corn", 5)) {
                ui_message("Precisa de 5 milho.", 1);
                return false;
            }

            return true;

        case 2:
            if (!player_has_item_anywhere(_player, "bar", 1)) {
                ui_message("Precisa de 1 barra.", 1);
                return false;
            }

            return true;
    }

    ui_message("Receita invalida.", 1);
    return false;
}

function craft_make_recipe(_player, _index) {
    if (!craft_can_make_recipe(_player, _index)) {
        return false;
    }

    var output_item = craft_get_recipe_output_item(_index);
    var output_amount = craft_get_recipe_output_amount(_index);

    switch (_index) {
        case 0:
            player_remove_item_anywhere(_player, "bar", 2);

            if (!player_add_item_to_inventory(_player, output_item, output_amount)) {
                player_add_item_to_inventory(_player, "bar", 2);

                ui_message("Falha ao fabricar irrigador.", 2);
                show_debug_message("Craft falhou: rollback de 2 barras.");
                return false;
            }

            ui_message("Fabricou irrigador.", 2);
            show_debug_message("Craft: 2 barras -> 1 sprinkler_item.");
            return true;

        case 1:
            player_remove_item_anywhere(_player, "bar", 2);
            player_remove_item_anywhere(_player, "corn", 5);

            if (!player_add_item_to_inventory(_player, output_item, output_amount)) {
                player_add_item_to_inventory(_player, "bar", 2);
                player_add_item_to_inventory(_player, "corn", 5);

                ui_message("Falha ao fabricar alimentador.", 2);
                show_debug_message("Craft falhou: rollback de 2 barras + 5 milho.");
                return false;
            }

            ui_message("Fabricou alimentador.", 2);
            show_debug_message("Craft: 2 barras + 5 milho -> 1 feeder_item.");
            return true;

        case 2:
            player_remove_item_anywhere(_player, "bar", 1);

            if (!player_add_item_to_inventory(_player, output_item, output_amount)) {
                player_add_item_to_inventory(_player, "bar", 1);

                ui_message("Falha ao fabricar bau.", 2);
                show_debug_message("Craft falhou: rollback de 1 barra.");
                return false;
            }

            ui_message("Fabricou bau.", 2);
            show_debug_message("Craft: 1 barra -> 1 chest_item.");
            return true;
    }

    return false;
}