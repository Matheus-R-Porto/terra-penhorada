function storage_get_nearby_chest() {
    var chest = instance_nearest(obj_player.x, obj_player.y, obj_storage_chest);

    if (chest == noone) {
        return noone;
    }

    if (point_distance(obj_player.x, obj_player.y, chest.x, chest.y) <= INTERACT_RANGE) {
        return chest;
    }

    return noone;
}

function storage_find_nth_filled_slot(_slots, _index) {
    var count = 0;

    for (var i = 0; i < array_length(_slots); i++) {
        var slot = _slots[i];

        if (slot[0] != "" && slot[1] > 0) {
            if (count == _index) {
                return i;
            }

            count += 1;
        }
    }

    return -1;
}

function storage_count_filled_slots(_slots) {
    var count = 0;

    for (var i = 0; i < array_length(_slots); i++) {
        var slot = _slots[i];

        if (slot[0] != "" && slot[1] > 0) {
            count += 1;
        }
    }

    return count;
}

function storage_move_one_item(_from_slots, _to_slots, _from_visible_index, _to_max_weight, _moving_to_player_inventory = false) {
    var real_index = storage_find_nth_filled_slot(_from_slots, _from_visible_index);

    if (real_index < 0) {
        ui_message("Nenhum item selecionado.", 1);
        return false;
    }

    var slot = _from_slots[real_index];
    var item_id = slot[0];

    if (item_id == "" || slot[1] <= 0) {
        ui_message("Slot vazio.", 1);
        return false;
    }

    if (_moving_to_player_inventory) {
        if (!player_add_item_to_inventory(obj_player, item_id, 1)) {
            ui_message("Sem espaco ou peso demais.", 1);
            return false;
        }
    }
    else {
        if (!inventory_add(_to_slots, item_id, 1, _to_max_weight)) {
            ui_message("Sem espaco.", 1);
            return false;
        }
    }

    inventory_remove(_from_slots, item_id, 1);

    ui_message("Moveu 1 " + item_get_name(item_id) + ".", 1);

    return true;
}