function ui_cursor_has_item(_player) {
    return _player.ui_cursor_item != "" && _player.ui_cursor_amount > 0;
}

function ui_cursor_clear(_player) {
    _player.ui_cursor_item = "";
    _player.ui_cursor_amount = 0;
}

function ui_get_slot_at_grid(_slots, _mx, _my, _x, _y, _cols, _slot_w, _slot_h, _gap) {
    for (var i = 0; i < array_length(_slots); i++) {
        var col = i mod _cols;
        var row = floor(i / _cols);

        var sx = _x + col * (_slot_w + _gap);
        var sy = _y + row * (_slot_h + _gap);

        if (_mx >= sx && _mx <= sx + _slot_w && _my >= sy && _my <= sy + _slot_h) {
            return i;
        }
    }

    return -1;
}

function ui_cursor_pick_from_slot(_player, _slots, _index) {
    if (ui_cursor_has_item(_player)) {
        return false;
    }

    if (_index < 0 || _index >= array_length(_slots)) {
        return false;
    }

    var slot = _slots[_index];
    var item_id = slot[0];
    var amount = slot[1];

    if (item_id == "" || amount <= 0) {
        return false;
    }

    _player.ui_cursor_item = item_id;
    _player.ui_cursor_amount = amount;

    _slots[_index] = ["", 0];

    return true;
}

function ui_cursor_can_place_in_slot(_player, _slots, _index, _target_is_player_carried) {
    if (!ui_cursor_has_item(_player)) {
        return false;
    }

    if (_index < 0 || _index >= array_length(_slots)) {
        return false;
    }

    if (!_target_is_player_carried) {
        return true;
    }

    var target_slot = _slots[_index];
    var target_item = target_slot[0];
    var target_amount = target_slot[1];

    var current_weight = player_total_weight(_player);
    var held_weight = item_get_weight(_player.ui_cursor_item) * _player.ui_cursor_amount;
    var target_weight = 0;

    if (target_item != "" && target_amount > 0 && target_item != _player.ui_cursor_item) {
        target_weight = item_get_weight(target_item) * target_amount;
    }

    var final_weight = current_weight - target_weight + held_weight;

    return final_weight <= _player.carry_weight_max;
}

function ui_cursor_place_in_slot(_player, _slots, _index, _target_is_player_carried) {
    if (!ui_cursor_has_item(_player)) {
        return false;
    }

    if (_index < 0 || _index >= array_length(_slots)) {
        return false;
    }

    if (!ui_cursor_can_place_in_slot(_player, _slots, _index, _target_is_player_carried)) {
        ui_message("Peso demais para carregar.", 2);
        return false;
    }

    var held_item = _player.ui_cursor_item;
    var held_amount = _player.ui_cursor_amount;

    var slot = _slots[_index];
    var target_item = slot[0];
    var target_amount = slot[1];

    // Slot vazio: coloca tudo.
    if (target_item == "" || target_amount <= 0) {
        _slots[_index] = [held_item, held_amount];
        ui_cursor_clear(_player);
        return true;
    }

    // Mesmo item: junta stack.
    if (target_item == held_item) {
        _slots[_index] = [target_item, target_amount + held_amount];
        ui_cursor_clear(_player);
        return true;
    }

    // Item diferente: troca.
    _slots[_index] = [held_item, held_amount];

    _player.ui_cursor_item = target_item;
    _player.ui_cursor_amount = target_amount;

    return true;
}

function ui_transfer_stack_to_slots(_player, _from_slots, _from_index, _to_slots, _to_is_player_carried) {
    if (_from_index < 0 || _from_index >= array_length(_from_slots)) {
        return false;
    }

    var slot = _from_slots[_from_index];
    var item_id = slot[0];
    var amount = slot[1];

    if (item_id == "" || amount <= 0) {
        return false;
    }

    if (_to_is_player_carried) {
        if (!player_can_add_item(_player, item_id, amount)) {
            ui_message("Peso ou espaco insuficiente.", 2);
            return false;
        }
    }

    var max_weight = 999999;

    if (!inventory_add(_to_slots, item_id, amount, max_weight)) {
        ui_message("Sem espaco no destino.", 2);
        return false;
    }

    _from_slots[_from_index] = ["", 0];

    return true;
}

function ui_draw_mouse_held_item() {
    if (!instance_exists(obj_player)) {
        return;
    }

    if (!ui_cursor_has_item(obj_player)) {
        return;
    }

    var mx = device_mouse_x_to_gui(0);
    var my = device_mouse_y_to_gui(0);

    var box_w = 110;
    var box_h = 42;

    draw_set_alpha(0.92);
    draw_set_color(make_color_rgb(245, 245, 225));
    draw_rectangle(mx + 16, my + 16, mx + 16 + box_w, my + 16 + box_h, false);

    draw_set_alpha(1);
    draw_set_color(c_black);
    draw_rectangle(mx + 16, my + 16, mx + 16 + box_w, my + 16 + box_h, true);

    draw_text(
        mx + 22,
        my + 22,
        string_copy(item_get_name(obj_player.ui_cursor_item), 1, 10)
    );

    draw_text(
        mx + 22,
        my + 38,
        "x" + string(obj_player.ui_cursor_amount)
    );

    draw_set_color(c_black);
    draw_set_alpha(1);
}

function ui_inventory_get_layout() {
    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();

    var panel_w = 560;
    var panel_h = 610;

    var panel_x = (gui_w - panel_w) / 2;
    var panel_y = (gui_h - panel_h) / 2;

    var slot_w = 76;
    var slot_h = 38;
    var gap = 8;

    var grid_x = panel_x + 30;
    var inventory_y = panel_y + 120;

    var inventory_rows = 6;
    var inventory_grid_h = inventory_rows * slot_h + (inventory_rows - 1) * gap;

    var hotbar_y = inventory_y + inventory_grid_h + 48;

    return {
        panel_x: panel_x,
        panel_y: panel_y,
        panel_w: panel_w,
        panel_h: panel_h,
        slot_w: slot_w,
        slot_h: slot_h,
        gap: gap,
        grid_x: grid_x,
        inventory_y: inventory_y,
        hotbar_y: hotbar_y
    };
}

function ui_chest_get_layout() {
    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();

    var panel_w = 920;
    var panel_h = 520;

    var panel_x = (gui_w - panel_w) / 2;
    var panel_y = (gui_h - panel_h) / 2;

    var slot_w = 72;
    var slot_h = 38;
    var gap = 8;

    var inv_x = panel_x + 30;
    var chest_x = panel_x + 500;
    var grid_y = panel_y + 125;

    return {
        panel_x: panel_x,
        panel_y: panel_y,
        panel_w: panel_w,
        panel_h: panel_h,
        slot_w: slot_w,
        slot_h: slot_h,
        gap: gap,
        inv_x: inv_x,
        chest_x: chest_x,
        grid_y: grid_y
    };
}