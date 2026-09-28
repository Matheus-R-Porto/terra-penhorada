function furnace_get_nearby() {
    var furnace = instance_nearest(obj_player.x, obj_player.y, obj_station_furnace);

    if (furnace == noone) {
        return noone;
    }

    if (point_distance(obj_player.x, obj_player.y, furnace.x, furnace.y) <= INTERACT_RANGE) {
        return furnace;
    }

    return noone;
}

function furnace_can_process_basic_bar(_player) {
    if (!player_has_item_anywhere(_player, "ore", 2)) {
        ui_message("Precisa de 2 minerios.", 1);
        return false;
    }

    if (!player_has_item_anywhere(_player, "coal", 1)) {
        ui_message("Precisa de 1 carvao.", 1);
        return false;
    }

    return true;
}

function furnace_process_basic_bar(_player) {
    if (!furnace_can_process_basic_bar(_player)) {
        return false;
    }

    player_remove_item_anywhere(_player, "ore", 2);
    player_remove_item_anywhere(_player, "coal", 1);

    if (!player_add_item_to_inventory(_player, "bar", 1)) {
        // Rollback de seguranca.
        player_add_item_to_inventory(_player, "ore", 2);
        player_add_item_to_inventory(_player, "coal", 1);

        ui_message("Falha ao receber a barra.", 2);
        show_debug_message("Fundicao falhou. Rollback aplicado.");
        return false;
    }

    ui_message("Fundiu 1 barra.", 1);
    show_debug_message("Fundicao: 2 minerios + 1 carvao -> 1 barra.");

    return true;
}

function furnace_get_preview_text(_player) {
    var ore_count = player_count_item_anywhere(_player, "ore");
    var coal_count = player_count_item_anywhere(_player, "coal");
    var bar_count = player_count_item_anywhere(_player, "bar");

    return "Minerio: " + string(ore_count) +
        " | Carvao: " + string(coal_count) +
        " | Barras: " + string(bar_count);
}