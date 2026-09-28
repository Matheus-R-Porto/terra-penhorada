function save_slot_array(_slots) {
    var result = [];

    for (var i = 0; i < array_length(_slots); i++) {
        var slot = _slots[i];

        array_push(result, {
            item_id: slot[0],
            amount: slot[1]
        });
    }

    return result;
}

function load_slot_array(_saved_slots, _size) {
    var slots = inventory_create(_size);

    if (is_undefined(_saved_slots)) {
        return slots;
    }

    var max_count = min(array_length(_saved_slots), _size);

    for (var i = 0; i < max_count; i++) {
        var saved_slot = _saved_slots[i];

        if (variable_struct_exists(saved_slot, "item_id")
        && variable_struct_exists(saved_slot, "amount")) {
            slots[i] = [saved_slot.item_id, saved_slot.amount];
        }
    }

    return slots;
}

function save_inventory_absorb_money_from_slots(_slots) {
    var absorbed = 0;

    for (var i = 0; i < array_length(_slots); i++) {
        var slot = _slots[i];

        if (slot[0] == "money" && slot[1] > 0) {
            absorbed += slot[1];

            _slots[i] = ["", 0];
        }
    }

    return absorbed;
}

function save_inventory_migrate_money_items(_player) {
    if (_player == noone) {
        return 0;
    }

    var absorbed = 0;

    absorbed += save_inventory_absorb_money_from_slots(_player.inventory_slots);
    absorbed += save_inventory_absorb_money_from_slots(_player.hotbar_slots);

    if (absorbed > 0) {
        money_add(absorbed);
        show_debug_message("Migracao: convertido money item para global.money: $" + string(absorbed));
    }

    return absorbed;
}

function save_inventory_write(_data) {
    if (!instance_exists(obj_player)) {
        return _data;
    }

    _data.inventory_size = obj_player.inventory_size;
    _data.inventory_slots = save_slot_array(obj_player.inventory_slots);

    _data.hotbar_size = obj_player.hotbar_size;
    _data.hotbar_slots = save_slot_array(obj_player.hotbar_slots);
    _data.hotbar_selected = obj_player.hotbar_selected;

    return _data;
}

function save_inventory_read(_data) {
    if (!instance_exists(obj_player)) {
        ui_message("Erro: player nao encontrado.", 2);
        return false;
    }

    if (variable_struct_exists(_data, "inventory_size")) {
        obj_player.inventory_size = _data.inventory_size;
    }

    if (variable_struct_exists(_data, "inventory_slots")) {
        obj_player.inventory_slots = load_slot_array(_data.inventory_slots, obj_player.inventory_size);
    }

    if (variable_struct_exists(_data, "hotbar_size")) {
        obj_player.hotbar_size = _data.hotbar_size;
    }

    if (variable_struct_exists(_data, "hotbar_slots")) {
        obj_player.hotbar_slots = load_slot_array(_data.hotbar_slots, obj_player.hotbar_size);
    }

    if (variable_struct_exists(_data, "hotbar_selected")) {
        obj_player.hotbar_selected = _data.hotbar_selected;
    }
    else {
        obj_player.hotbar_selected = -1;
    }
	
	save_inventory_migrate_money_items(obj_player);

    return true;
}