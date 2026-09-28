function hotbar_get_selected_slot(_player) {
    if (_player.hotbar_selected < 0) {
        return ["", 0];
    }

    if (_player.hotbar_selected >= _player.hotbar_size) {
        return ["", 0];
    }

    return _player.hotbar_slots[_player.hotbar_selected];
}

function hotbar_get_selected_item(_player) {
    var slot = hotbar_get_selected_slot(_player);
    return slot[0];
}

function hotbar_get_selected_amount(_player) {
    var slot = hotbar_get_selected_slot(_player);
    return slot[1];
}

function hotbar_has_selected_item(_player) {
    var slot = hotbar_get_selected_slot(_player);

    return slot[0] != "" && slot[1] > 0;
}

function hotbar_update_selection(_player) {
    // Teclas 1 a 9
    for (var i = 0; i < 9; i++) {
        var key_code = ord(string(i + 1));

        if (keyboard_check_pressed(key_code)) {
            if (_player.hotbar_selected == i) {
                _player.hotbar_selected = -1;
            }
            else {
                _player.hotbar_selected = i;
            }
        }
    }

    // Tecla 0 = slot 10
    if (keyboard_check_pressed(ord("0"))) {
        if (_player.hotbar_selected == 9) {
            _player.hotbar_selected = -1;
        }
        else {
            _player.hotbar_selected = 9;
        }
    }
}

function hotbar_add_item(_player, _item_id, _amount) {
    return inventory_add(
        _player.hotbar_slots,
        _item_id,
        _amount,
        _player.carry_weight_max
    );
}

function hotbar_remove_item(_player, _item_id, _amount) {
    return inventory_remove(_player.hotbar_slots, _item_id, _amount);
}

function hotbar_count(_player, _item_id) {
    return inventory_count(_player.hotbar_slots, _item_id);
}

function player_slots_weight(_slots) {
    var total = 0;

    for (var i = 0; i < array_length(_slots); i++) {
        var slot = _slots[i];
        var item_id = slot[0];
        var amount = slot[1];

        if (item_id != "" && amount > 0) {
            total += item_get_weight(item_id) * amount;
        }
    }

    return total;
}

function player_total_weight(_player) {
    if (_player == noone) {
        return 0;
    }

    var total = 0;

    total += player_slots_weight(_player.inventory_slots);
    total += player_slots_weight(_player.hotbar_slots);

    return total;
}

function player_can_add_to_inventory_or_hotbar(_player, _item_id, _amount) {
    var added_weight = item_get_weight(_item_id) * _amount;
    var current_weight = player_total_weight(_player);

    return current_weight + added_weight <= _player.carry_weight_max;
}