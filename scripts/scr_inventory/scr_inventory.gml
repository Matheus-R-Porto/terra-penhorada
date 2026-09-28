function inventory_create(_size) {
    var slots = [];

    for (var i = 0; i < _size; i++) {
        array_push(slots, ["", 0]);
    }

    return slots;
}

function inventory_count(_slots, _item_id) {
    var total = 0;

    for (var i = 0; i < array_length(_slots); i++) {
        var slot = _slots[i];

        if (slot[0] == _item_id) {
            total += slot[1];
        }
    }

    return total;
}

function inventory_has(_slots, _item_id, _amount) {
    return inventory_count(_slots, _item_id) >= _amount;
}

function inventory_current_weight(_slots) {
    var total_weight = 0;

    for (var i = 0; i < array_length(_slots); i++) {
        var slot = _slots[i];
        var item_id = slot[0];
        var amount = slot[1];

        if (item_id != "" && amount > 0) {
            total_weight += item_get_weight(item_id) * amount;
        }
    }

    return total_weight;
}

function inventory_can_add(_slots, _item_id, _amount, _max_weight) {
    if (_item_id == "" || _amount <= 0) {
        return false;
    }

    var added_weight = item_get_weight(_item_id) * _amount;
    var current_weight = inventory_current_weight(_slots);

    if (current_weight + added_weight > _max_weight) {
        return false;
    }

    var stack_limit = item_get_stack_limit(_item_id);
    var remaining = _amount;

    // Primeiro tenta completar pilhas existentes
    for (var i = 0; i < array_length(_slots); i++) {
        var slot = _slots[i];

        if (slot[0] == _item_id && slot[1] < stack_limit) {
            var free_space = stack_limit - slot[1];
            var move_amount = min(remaining, free_space);

            remaining -= move_amount;

            if (remaining <= 0) {
                return true;
            }
        }
    }

    // Depois procura slots vazios
    for (var j = 0; j < array_length(_slots); j++) {
        var empty_slot = _slots[j];

        if (empty_slot[0] == "" || empty_slot[1] <= 0) {
            remaining -= min(remaining, stack_limit);

            if (remaining <= 0) {
                return true;
            }
        }
    }

    return false;
}

function inventory_add(_slots, _item_id, _amount, _max_weight) {
    if (!inventory_can_add(_slots, _item_id, _amount, _max_weight)) {
        return false;
    }

    var stack_limit = item_get_stack_limit(_item_id);
    var remaining = _amount;

    // Completa pilhas existentes
    for (var i = 0; i < array_length(_slots); i++) {
        var slot = _slots[i];

        if (slot[0] == _item_id && slot[1] < stack_limit) {
            var free_space = stack_limit - slot[1];
            var move_amount = min(remaining, free_space);

            slot[1] += move_amount;
            _slots[i] = slot;

            remaining -= move_amount;

            if (remaining <= 0) {
                return true;
            }
        }
    }

    // Usa slots vazios
    for (var j = 0; j < array_length(_slots); j++) {
        var empty_slot = _slots[j];

        if (empty_slot[0] == "" || empty_slot[1] <= 0) {
            var add_amount = min(remaining, stack_limit);

            _slots[j] = [_item_id, add_amount];

            remaining -= add_amount;

            if (remaining <= 0) {
                return true;
            }
        }
    }

    return false;
}

function inventory_remove(_slots, _item_id, _amount) {
    if (!inventory_has(_slots, _item_id, _amount)) {
        return false;
    }

    var remaining = _amount;

    for (var i = 0; i < array_length(_slots); i++) {
        var slot = _slots[i];

        if (slot[0] == _item_id) {
            var remove_amount = min(remaining, slot[1]);

            slot[1] -= remove_amount;
            remaining -= remove_amount;

            if (slot[1] <= 0) {
                slot = ["", 0];
            }

            _slots[i] = slot;

            if (remaining <= 0) {
                return true;
            }
        }
    }

    return true;
}

function inventory_debug_print(_slots) {
    show_debug_message("===== INVENTARIO =====");

    for (var i = 0; i < array_length(_slots); i++) {
        var slot = _slots[i];

        if (slot[0] != "" && slot[1] > 0) {
            show_debug_message(
                string(i) +
                ": " +
                item_get_name(slot[0]) +
                " x" +
                string(slot[1])
            );
        }
    }
}
	
function player_count_item_anywhere(_player, _item_id) {
    if (_player == noone) {
        return 0;
    }

    var total = 0;

    total += inventory_count(_player.inventory_slots, _item_id);
    total += inventory_count(_player.hotbar_slots, _item_id);

    return total;
}

function player_has_item_anywhere(_player, _item_id, _amount) {
    return player_count_item_anywhere(_player, _item_id) >= _amount;
}

function player_remove_item_anywhere(_player, _item_id, _amount) {
    if (_player == noone) {
        return false;
    }

    if (!player_has_item_anywhere(_player, _item_id, _amount)) {
        return false;
    }

    var remaining = _amount;

    // Primeiro remove da mochila, porque ela e o estoque principal.
    var inv_amount = inventory_count(_player.inventory_slots, _item_id);
    var remove_from_inventory = min(inv_amount, remaining);

    if (remove_from_inventory > 0) {
        inventory_remove(_player.inventory_slots, _item_id, remove_from_inventory);
        remaining -= remove_from_inventory;
    }

    // Depois remove da hotbar, se ainda faltar.
    if (remaining > 0) {
        inventory_remove(_player.hotbar_slots, _item_id, remaining);
        remaining = 0;
    }

    return true;
}

function player_can_add_item(_player, _item_id, _amount) {
    if (_player == noone) {
        return false;
    }

    if (_item_id == "" || _amount <= 0) {
        return false;
    }

    var current_weight = player_total_weight(_player);
    var added_weight = item_get_weight(_item_id) * _amount;

    if (current_weight + added_weight > _player.carry_weight_max) {
        return false;
    }

    // Aqui usamos inventario como destino principal.
    // O 999999 evita que inventory_can_add recalcule peso so da mochila
    // e ignore a hotbar.
    return inventory_can_add(_player.inventory_slots, _item_id, _amount, 999999);
}

function player_add_item_to_inventory(_player, _item_id, _amount) {
    if (_player == noone) {
        return false;
    }

    if (!player_can_add_item(_player, _item_id, _amount)) {
        return false;
    }

    return inventory_add(_player.inventory_slots, _item_id, _amount, 999999);
}