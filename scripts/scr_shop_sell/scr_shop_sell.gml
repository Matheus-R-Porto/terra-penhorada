function sell_box_get_nearby() {
    var box = instance_nearest(obj_player.x, obj_player.y, obj_shop_sell_box);

    if (box == noone) {
        return noone;
    }

    if (point_distance(obj_player.x, obj_player.y, box.x, box.y) <= INTERACT_RANGE) {
        return box;
    }

    return noone;
}

function sell_item_is_sellable(_item_id) {
    return item_get_sell_price(_item_id) > 0;
}

function sell_count_sellable_slots(_player) {
    var count = 0;

    for (var i = 0; i < array_length(_player.inventory_slots); i++) {
        var slot = _player.inventory_slots[i];
        var item_id = slot[0];
        var amount = slot[1];

        if (item_id != "" && amount > 0 && sell_item_is_sellable(item_id)) {
            count += 1;
        }
    }

    return count;
}

function sell_find_nth_sellable_slot(_player, _visible_index) {
    var count = 0;

    for (var i = 0; i < array_length(_player.inventory_slots); i++) {
        var slot = _player.inventory_slots[i];
        var item_id = slot[0];
        var amount = slot[1];

        if (item_id != "" && amount > 0 && sell_item_is_sellable(item_id)) {
            if (count == _visible_index) {
                return i;
            }

            count += 1;
        }
    }

    return -1;
}

function sell_get_selected_real_index(_player) {
    var sellable_count = sell_count_sellable_slots(_player);

    if (sellable_count <= 0) {
        _player.sell_panel_selected = 0;
        return -1;
    }

    _player.sell_panel_selected = clamp(_player.sell_panel_selected, 0, sellable_count - 1);

    return sell_find_nth_sellable_slot(_player, _player.sell_panel_selected);
}

function sell_inventory_all(_player) {
    var total_money = 0;

    for (var i = 0; i < array_length(_player.inventory_slots); i++) {
        var slot = _player.inventory_slots[i];
        var item_id = slot[0];
        var amount = slot[1];

        if (item_id != "" && amount > 0) {
            if (sell_item_is_sellable(item_id)) {
                var price = item_get_sell_price(item_id);
                var value = price * amount;

                total_money += value;

                _player.inventory_slots[i] = ["", 0];

                show_debug_message(
                    "Vendeu " +
                    item_get_name(item_id) +
                    " x" +
                    string(amount) +
                    " por $" +
                    string(value)
                );
            }
        }
    }

    if (total_money > 0) {
        money_add(total_money);
        ui_message("Venda concluida: +$" + string(total_money), 2);
    }
    else {
        ui_message("Nenhum item vendavel.", 1);
    }

    _player.sell_panel_selected = 0;

    return total_money;
}

function sell_selected_one(_player) {
    var real_index = sell_get_selected_real_index(_player);

    if (real_index < 0) {
        ui_message("Nenhum item vendavel selecionado.", 1);
        return false;
    }

    var slot = _player.inventory_slots[real_index];
    var item_id = slot[0];
    var amount = slot[1];

    if (item_id == "" || amount <= 0 || !sell_item_is_sellable(item_id)) {
        ui_message("Item invalido para venda.", 1);
        return false;
    }

    var price = item_get_sell_price(item_id);

    money_add(price);

    amount -= 1;

    if (amount <= 0) {
        _player.inventory_slots[real_index] = ["", 0];
    }
    else {
        _player.inventory_slots[real_index] = [item_id, amount];
    }

    ui_message("Vendeu 1 " + item_get_name(item_id) + " por $" + string(price) + ".", 2);

    var sellable_count = sell_count_sellable_slots(_player);

    if (sellable_count <= 0) {
        _player.sell_panel_selected = 0;
    }
    else {
        _player.sell_panel_selected = clamp(_player.sell_panel_selected, 0, sellable_count - 1);
    }

    return true;
}

function sell_selected_stack(_player) {
    var real_index = sell_get_selected_real_index(_player);

    if (real_index < 0) {
        ui_message("Nenhum item vendavel selecionado.", 1);
        return false;
    }

    var slot = _player.inventory_slots[real_index];
    var item_id = slot[0];
    var amount = slot[1];

    if (item_id == "" || amount <= 0 || !sell_item_is_sellable(item_id)) {
        ui_message("Item invalido para venda.", 1);
        return false;
    }

    var price = item_get_sell_price(item_id);
    var value = price * amount;

    money_add(value);

    _player.inventory_slots[real_index] = ["", 0];

    ui_message(
        "Vendeu " +
        item_get_name(item_id) +
        " x" +
        string(amount) +
        " por $" +
        string(value) +
        ".",
        2
    );

    var sellable_count = sell_count_sellable_slots(_player);

    if (sellable_count <= 0) {
        _player.sell_panel_selected = 0;
    }
    else {
        _player.sell_panel_selected = clamp(_player.sell_panel_selected, 0, sellable_count - 1);
    }

    return true;
}

function sell_panel_get_preview_total(_player) {
    var total_money = 0;

    for (var i = 0; i < array_length(_player.inventory_slots); i++) {
        var slot = _player.inventory_slots[i];
        var item_id = slot[0];
        var amount = slot[1];

        if (item_id != "" && amount > 0) {
            if (sell_item_is_sellable(item_id)) {
                total_money += item_get_sell_price(item_id) * amount;
            }
        }
    }

    return total_money;
}