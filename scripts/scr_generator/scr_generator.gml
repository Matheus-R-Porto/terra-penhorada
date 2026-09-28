function generator_get_nearby(_player) {
    var gen = instance_nearest(_player.x, _player.y, obj_machine_generator_basic);

    if (gen == noone) {
        return noone;
    }

    if (point_distance(_player.x, _player.y, gen.x, gen.y) <= INTERACT_RANGE) {
        return gen;
    }

    return noone;
}

function generator_add_coal(_player, _generator) {
    if (_generator == noone) {
        return false;
    }

    if (!variable_instance_exists(_generator.id, "coal_stored")) {
        _generator.coal_stored = 0;
    }

    if (!variable_instance_exists(_generator.id, "coal_capacity")) {
        _generator.coal_capacity = 10;
    }

    if (_generator.coal_stored >= _generator.coal_capacity) {
        ui_message("Gerador ja esta cheio.", 2);
        return false;
    }

    if (!player_has_item_anywhere(_player, "coal", 1)) {
        ui_message("Voce precisa de carvao.", 2);
        return false;
    }

    player_remove_item_anywhere(_player, "coal", 1);
    _generator.coal_stored += 1;

    power_recalculate();

    ui_message("Abasteceu o gerador com 1 carvao.", 2);
    show_debug_message("Gerador abastecido. Carvao: " + string(_generator.coal_stored));

    return true;
}

function generator_get_status_text(_generator) {
    if (_generator == noone) {
        return "Gerador inexistente.";
    }

    if (!variable_instance_exists(_generator.id, "coal_stored")) {
        _generator.coal_stored = 0;
    }

    if (!variable_instance_exists(_generator.id, "coal_capacity")) {
        _generator.coal_capacity = 10;
    }

    if (!variable_instance_exists(_generator.id, "power_output")) {
        _generator.power_output = 4;
    }

    return "Carvao: " +
        string(_generator.coal_stored) +
        "/" +
        string(_generator.coal_capacity) +
        " | Producao: " +
        string(_generator.power_output);
}