function seed_shop_get_nearby() {
    var shop = instance_nearest(obj_player.x, obj_player.y, obj_shop_seed);

    if (shop == noone) {
        return noone;
    }

    if (point_distance(obj_player.x, obj_player.y, shop.x, shop.y) <= INTERACT_RANGE) {
        return shop;
    }

    return noone;
}

function seed_shop_get_item_id(_index) {
    switch (_index) {
        case 0: return "tomato_seed";
        case 1: return "corn_seed";
    }

    return "";
}

function seed_shop_get_item_count() {
    return 2;
}

function seed_shop_buy_selected(_player) {
    var item_id = seed_shop_get_item_id(_player.seed_shop_selected);

    if (item_id == "") {
        ui_message("Item invalido.", 1);
        return false;
    }

    var quantity = _player.seed_shop_quantity;
    var price = item_get_buy_price(item_id);
    var total_cost = price * quantity;

    if (quantity <= 0) {
        ui_message("Quantidade invalida.", 1);
        return false;
    }

    if (!money_can_spend(total_cost)) {
        ui_message("Dinheiro insuficiente.", 2);
        return false;
    }

    if (!player_add_item_to_inventory(_player, item_id, quantity)) {
        ui_message("Inventario cheio ou pesado demais.", 2);
        return false;
    }

    money_spend(total_cost);

    ui_message("Comprou " + string(quantity) + " " + item_get_name(item_id) + ".", 2);

    show_debug_message(
        "Compra feita: " +
        item_get_name(item_id) +
        " x" +
        string(quantity) +
        " custo $" +
        string(total_cost)
    );

    return true;
}