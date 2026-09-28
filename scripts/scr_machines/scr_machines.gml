function machine_get_place_x() {
    return grid_snap_x(mouse_x);
}

function machine_get_place_y() {
    return grid_snap_y(mouse_y);
}

function machine_position_near_object(_px, _py, _obj, _range) {
    for (var i = 0; i < instance_number(_obj); i++) {
        var inst = instance_find(_obj, i);

        if (point_distance(_px, _py, inst.x, inst.y) < _range) {
            return true;
        }
    }

    return false;
}

function machine_can_place_at(_player, _item_id, _px, _py, _silent = false) {
    if (!item_is_placeable(_item_id)) {
        if (!_silent) {
            ui_message("Este item nao pode ser posicionado.", 1);
        }

        return false;
    }

    if (point_distance(_player.x, _player.y, _px, _py) > BUILD_RANGE) {
        if (!_silent) {
            ui_message("Muito longe para posicionar.", 1);
        }

        return false;
    }

    // Evita construir em cima do player
    if (point_distance(_player.x, _player.y, _px, _py) < 36) {
        if (!_silent) {
            ui_message("Muito perto de voce.", 1);
        }

        return false;
    }

    var block_range = 28;

    // Máquinas/estruturas
    if (machine_position_near_object(_px, _py, obj_machine_sprinkler_basic, block_range)
	|| machine_position_near_object(_px, _py, obj_machine_feeder_basic, block_range)
	|| machine_position_near_object(_px, _py, obj_storage_chest, block_range)
	|| machine_position_near_object(_px, _py, obj_station_workbench, block_range)
	|| machine_position_near_object(_px, _py, obj_station_furnace, block_range)
	|| machine_position_near_object(_px, _py, obj_station_feed_maker, block_range)
	|| machine_position_near_object(_px, _py, obj_bed, block_range)
	|| machine_position_near_object(_px, _py, obj_shop_seed, block_range)
	|| machine_position_near_object(_px, _py, obj_shop_sell_box, block_range)) {
        if (!_silent) {
            ui_message("Espaco ocupado.", 1);
        }

        return false;
    }

    // Solos
    if (machine_position_near_object(_px, _py, obj_crop_plot, block_range)) {
        if (!_silent) {
            ui_message("Nao pode construir sobre solo.", 1);
        }

        return false;
    }

    // Minério
    if (machine_position_near_object(_px, _py, obj_resource_ore, block_range)) {
        if (!_silent) {
            ui_message("Nao pode construir sobre minerio.", 1);
        }

        return false;
    }

    return true;
}

function machine_place_selected_hotbar_item(_player) {
    if (!hotbar_has_selected_item(_player)) {
        return false;
    }

    var selected_item = hotbar_get_selected_item(_player);

    if (!item_is_placeable(selected_item)) {
        return false;
    }

    var place_obj = item_get_place_object(selected_item);

    if (place_obj == noone) {
        ui_message("Objeto invalido.", 1);
        return false;
    }

    var px = machine_get_place_x();
    var py = machine_get_place_y();

    if (!machine_can_place_at(_player, selected_item, px, py, false)) {
        return false;
    }

    var inst = instance_create_layer(px, py, "Instances", place_obj);

    if (selected_item == "sprinkler_item") {
        inst.machine_id = "sprinkler_basic";
        inst.area_id = "farm";
        inst.range = 96;
    }
    else if (selected_item == "feeder_item") {
        inst.machine_id = "feeder_basic";
        inst.area_id = "farm";
        inst.feed_stored = 0;
        inst.feed_capacity = 20;
        inst.egg_stored = 0;
        inst.egg_capacity = 20;
        inst.range = 96;
    }
    else if (selected_item == "chest_item") {
        inst.storage_size = 20;
        inst.storage_slots = inventory_create(inst.storage_size);
        inst.area_id = "farm";
    }

    hotbar_remove_item(_player, selected_item, 1);

    ui_message("Objeto posicionado: " + item_get_name(selected_item) + ".", 1);

    show_debug_message(
        "Posicionou " +
        item_get_name(selected_item) +
        " em x:" +
        string(px) +
        " y:" +
        string(py)
    );

    return true;
}