function livestock_get_chicken_nearby(_player) {
    var chicken = instance_nearest(_player.x, _player.y, obj_chicken);

    if (chicken == noone) {
        return noone;
    }

    if (point_distance(_player.x, _player.y, chicken.x, chicken.y) <= INTERACT_RANGE) {
        return chicken;
    }

    return noone;
}

function livestock_get_egg_drop_nearby(_player) {
    var egg = instance_nearest(_player.x, _player.y, obj_egg_drop);

    if (egg == noone) {
        return noone;
    }

    if (point_distance(_player.x, _player.y, egg.x, egg.y) <= INTERACT_RANGE) {
        return egg;
    }

    return noone;
}

function livestock_feed_chicken(_player, _chicken) {
    if (_chicken == noone) {
        return false;
    }

    if (!variable_instance_exists(_chicken.id, "days_without_feed")) {
        _chicken.days_without_feed = 0;
    }

    if (!variable_instance_exists(_chicken.id, "hungry_limit")) {
        _chicken.hungry_limit = 2;
    }

    if (!variable_instance_exists(_chicken.id, "fed")) {
        _chicken.fed = false;
    }

    if (_chicken.fed) {
        ui_message("Galinha ja foi alimentada hoje.", 1);
        return false;
    }

    if (!player_has_item_anywhere(_player, "feed", 1)) {
	    ui_message("Voce precisa de racao.", 1);
	    return false;
	}

	player_remove_item_anywhere(_player, "feed", 1);

    _chicken.fed = true;

    if (_chicken.days_without_feed >= _chicken.hungry_limit) {
        ui_message("Galinha faminta foi alimentada.", 2);
    }
    else {
        ui_message("Galinha alimentada.", 2);
    }

    show_debug_message("Galinha alimentada manualmente.");

    return true;
}

function livestock_collect_egg_drop(_player, _egg_drop) {
    if (_egg_drop == noone) {
        return false;
    }

    var item_id = "egg";
    var amount = 1;

    if (variable_instance_exists(_egg_drop.id, "item_id")) {
        item_id = _egg_drop.item_id;
    }

    if (variable_instance_exists(_egg_drop.id, "amount")) {
        amount = _egg_drop.amount;
    }

    if (!player_add_item_to_inventory(_player, item_id, amount)) {
        ui_message("Inventario cheio ou pesado demais.", 2);
        return false;
    }

    instance_destroy(_egg_drop);

    ui_message("Pegou " + string(amount) + " ovo.", 2);
    show_debug_message("Pegou ovo do chao.");

    return true;
}

function livestock_spawn_egg_near_chicken(_chicken) {
    var side = choose(-1, 1);

    var drop_x = _chicken.x + (side * 28);
    var drop_y = _chicken.y + irandom_range(-8, 8);

    instance_create_layer(drop_x, drop_y, "Instances", obj_egg_drop);

    show_debug_message("Ovo apareceu no chao perto da galinha.");
}

function livestock_process_next_day() {
    var eggs_created = 0;
    var hungry_count = 0;

    for (var i = 0; i < instance_number(obj_chicken); i++) {
        var chicken = instance_find(obj_chicken, i);

        if (!variable_instance_exists(chicken.id, "fed")) {
            chicken.fed = false;
        }

        if (!variable_instance_exists(chicken.id, "days_without_feed")) {
            chicken.days_without_feed = 0;
        }

        if (!variable_instance_exists(chicken.id, "hungry_limit")) {
            chicken.hungry_limit = 2;
        }

        if (chicken.fed) {
            chicken.fed = false;
            chicken.days_without_feed = 0;

            livestock_spawn_egg_near_chicken(chicken);

            eggs_created += 1;
        }
        else {
            chicken.days_without_feed += 1;

            if (chicken.days_without_feed >= chicken.hungry_limit) {
                hungry_count += 1;
            }
        }
    }

    if (eggs_created > 0) {
        ui_message("Galinhas produziram " + string(eggs_created) + " ovo(s).", 2);
    }
    else if (hungry_count > 0) {
        ui_message(string(hungry_count) + " galinha(s) estao famintas.", 2);
    }

    show_debug_message("Pecuaria processada. Ovos: " + string(eggs_created));
}

function chicken_open_panel(_player, _chicken) {
    if (_chicken == noone) {
        return false;
    }

    _player.current_chicken = _chicken;
    _player.chicken_panel_open = true;
    _player.chicken_panel_selected = 0;

    ui_message("Galinha selecionada.", 1);

    return true;
}

function chicken_get_state_text(_chicken) {
    if (_chicken == noone) {
        return "Indisponivel";
    }

    if (!variable_instance_exists(_chicken.id, "fed")) {
        _chicken.fed = false;
    }

    if (!variable_instance_exists(_chicken.id, "days_without_feed")) {
        _chicken.days_without_feed = 0;
    }

    if (!variable_instance_exists(_chicken.id, "hungry_limit")) {
        _chicken.hungry_limit = 2;
    }

    if (_chicken.fed) {
        return "Alimentada";
    }

    if (_chicken.days_without_feed >= _chicken.hungry_limit) {
        return "Faminta";
    }

    if (_chicken.days_without_feed > 0) {
        return "Com fome";
    }

    return "Bem";
}

function chicken_get_fed_text(_chicken) {
    if (_chicken == noone) {
        return "Nao";
    }

    if (!variable_instance_exists(_chicken.id, "fed")) {
        _chicken.fed = false;
    }

    if (_chicken.fed) {
        return "Sim";
    }

    return "Nao";
}

function player_update_chicken_panel() {
    if (!chicken_panel_open) {
        return;
    }

    if (current_chicken == noone || !instance_exists(current_chicken)) {
        chicken_panel_open = false;
        current_chicken = noone;
        ui_message("Galinha indisponivel.", 1);
        return;
    }

    if (keyboard_check_pressed(vk_escape)) {
        chicken_panel_open = false;
        current_chicken = noone;
        ui_message("Painel da galinha fechado.", 1);
        return;
    }

    if (keyboard_check_pressed(ord("W"))) {
        chicken_panel_selected -= 1;
    }

    if (keyboard_check_pressed(ord("S"))) {
        chicken_panel_selected += 1;
    }

    chicken_panel_selected = clamp(chicken_panel_selected, 0, 1);

    if (keyboard_check_pressed(vk_enter)) {
        switch (chicken_panel_selected) {
            case 0:
                livestock_feed_chicken(id, current_chicken);
                return;

            case 1:
                chicken_panel_open = false;
                current_chicken = noone;
                ui_message("Painel da galinha fechado.", 1);
                return;
        }
    }
}