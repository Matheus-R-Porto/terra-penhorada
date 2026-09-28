function feeder_get_nearby(_player) {
    var feeder = instance_nearest(_player.x, _player.y, obj_machine_feeder_basic);

    if (feeder == noone) {
        return noone;
    }

    if (point_distance(_player.x, _player.y, feeder.x, feeder.y) <= INTERACT_RANGE) {
        return feeder;
    }

    return noone;
}

function feeder_get_feed_stored(_feeder) {
    if (_feeder == noone) {
        return 0;
    }

    if (!variable_instance_exists(_feeder.id, "feed_stored")) {
        _feeder.feed_stored = 0;
    }

    return _feeder.feed_stored;
}

function feeder_get_feed_capacity(_feeder) {
    if (_feeder == noone) {
        return 0;
    }

    if (!variable_instance_exists(_feeder.id, "feed_capacity")) {
        _feeder.feed_capacity = 20;
    }

    return _feeder.feed_capacity;
}

function feeder_add_feed_from_player(_player, _feeder) {
    if (_feeder == noone) {
        return false;
    }

    if (!variable_instance_exists(_feeder.id, "feed_stored")) {
        _feeder.feed_stored = 0;
    }

    if (!variable_instance_exists(_feeder.id, "feed_capacity")) {
        _feeder.feed_capacity = 20;
    }

    var free_space = _feeder.feed_capacity - _feeder.feed_stored;

    if (free_space <= 0) {
        ui_message("Alimentador ja esta cheio.", 1);
        return false;
    }

    var player_feed = player_count_item_anywhere(_player, "feed");

	if (player_feed <= 0) {
	    ui_message("Voce nao tem racao.", 1);
	    return false;
	}

	var move_amount = min(player_feed, free_space);

	player_remove_item_anywhere(_player, "feed", move_amount);
	_feeder.feed_stored += move_amount;

    ui_message(
        "Abasteceu alimentador com " +
        string(move_amount) +
        " racao.",
        2
    );

    show_debug_message(
        "Alimentador abastecido. Feed stored: " +
        string(_feeder.feed_stored) +
        "/" +
        string(_feeder.feed_capacity)
    );

    return true;
}

function feeders_process_next_day() {
    var total_fed = 0;
    var total_feed_used = 0;

    for (var f = 0; f < instance_number(obj_machine_feeder_basic); f++) {
        var feeder = instance_find(obj_machine_feeder_basic, f);

        if (!variable_instance_exists(feeder.id, "feed_stored")) {
            feeder.feed_stored = 0;
        }

        if (!variable_instance_exists(feeder.id, "feed_capacity")) {
            feeder.feed_capacity = 20;
        }

        if (!variable_instance_exists(feeder.id, "range")) {
            feeder.range = 96;
        }

        if (feeder.feed_stored <= 0) {
            continue;
        }

        for (var c = 0; c < instance_number(obj_chicken); c++) {
            var chicken = instance_find(obj_chicken, c);

            if (feeder.feed_stored <= 0) {
                break;
            }

            if (point_distance(feeder.x, feeder.y, chicken.x, chicken.y) > feeder.range) {
                continue;
            }

            if (!variable_instance_exists(chicken.id, "fed")) {
                chicken.fed = false;
            }

            if (chicken.fed) {
                continue;
            }

            chicken.fed = true;
            feeder.feed_stored -= 1;

            total_fed += 1;
            total_feed_used += 1;
        }
    }

    if (total_fed > 0) {
        ui_message(
            "Alimentador alimentou " +
            string(total_fed) +
            " galinha(s).",
            2
        );
    }

    show_debug_message(
        "Alimentadores processados. Galinhas alimentadas: " +
        string(total_fed) +
        " | Racao usada: " +
        string(total_feed_used)
    );
}