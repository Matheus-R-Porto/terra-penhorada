function feed_maker_get_nearby() {
    var maker = instance_nearest(obj_player.x, obj_player.y, obj_station_feed_maker);

    if (maker == noone) {
        return noone;
    }

    if (point_distance(obj_player.x, obj_player.y, maker.x, maker.y) <= INTERACT_RANGE) {
        return maker;
    }

    return noone;
}

function feed_maker_use(_player, _maker) {
    if (_maker == noone) {
        return false;
    }

    if (!player_has_item_anywhere(_player, "corn", 1)) {
        ui_message("Voce precisa de milho para fazer racao.", 2);
        show_debug_message("Feed maker: sem milho.");
        return false;
    }

    // Confere se a racao cabe antes de consumir o milho.
    // Como o milho vai sair, isso ainda e conservador, mas seguro.
    if (!player_can_add_item(_player, "feed", 2)) {
	    ui_message("Sem espaco ou peso para fazer racao.", 2);
	    show_debug_message("Feed maker: falha por inventario cheio/peso.");
	    return false;
	}

    player_remove_item_anywhere(_player, "corn", 1);

    if (!player_add_item_to_inventory(_player, "feed", 2)) {
        // Rollback de seguranca, caso algo inesperado aconteca.
        player_add_item_to_inventory(_player, "corn", 1);

        ui_message("Falha ao criar racao.", 2);
        show_debug_message("Feed maker: rollback por falha inesperada.");
        return false;
    }

    ui_message("Transformou 1 milho em 2 racao.", 2);
    show_debug_message("Feed maker: -1 corn, +2 feed.");

    return true;
}