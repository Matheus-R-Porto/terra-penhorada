function power_init() {
    if (!variable_global_exists("power_production")) {
        global.power_production = 0;
    }

    if (!variable_global_exists("power_consumption")) {
        global.power_consumption = 0;
    }

    if (!variable_global_exists("power_is_stable")) {
        global.power_is_stable = true;
    }
}

function power_get_generator_output(_generator) {
    if (_generator == noone) {
        return 0;
    }

    if (!variable_instance_exists(_generator.id, "coal_stored")) {
        _generator.coal_stored = 0;
    }

    if (!variable_instance_exists(_generator.id, "power_output")) {
        _generator.power_output = 4;
    }

    if (_generator.coal_stored <= 0) {
        return 0;
    }

    return _generator.power_output;
}

function power_get_machine_consumption(_machine) {
    if (_machine == noone) {
        return 0;
    }

    if (!variable_instance_exists(_machine.id, "power_required")) {
        return 0;
    }

    if (_machine.power_required <= 0) {
        return 0;
    }

    return _machine.power_required;
}

function power_recalculate() {
    power_init();

    var production = 0;
    var consumption = 0;

    // Geradores
    for (var i = 0; i < instance_number(obj_machine_generator_basic); i++) {
        var gen = instance_find(obj_machine_generator_basic, i);
        production += power_get_generator_output(gen);
    }

    // Irrigadores
    for (var s = 0; s < instance_number(obj_machine_sprinkler_basic); s++) {
        var sprinkler = instance_find(obj_machine_sprinkler_basic, s);
        consumption += power_get_machine_consumption(sprinkler);
    }

    // Futuro: alimentador, moedor, esteiras etc.

    global.power_production = production;
    global.power_consumption = consumption;
    global.power_is_stable = production >= consumption;

    return global.power_is_stable;
}

function power_has_enough() {
    power_recalculate();
    return global.power_is_stable;
}

function power_get_status_text() {
    power_recalculate();

    if (global.power_production <= 0 && global.power_consumption > 0) {
        return "Sem energia";
    }

    if (!global.power_is_stable) {
        return "Energia insuficiente";
    }

    return "Energia estavel";
}

function power_process_next_day() {
    // Consome 1 carvao por gerador ativo ao dormir.
    for (var i = 0; i < instance_number(obj_machine_generator_basic); i++) {
        var gen = instance_find(obj_machine_generator_basic, i);

        if (!variable_instance_exists(gen.id, "coal_stored")) {
            gen.coal_stored = 0;
        }

        if (gen.coal_stored > 0) {
            gen.coal_stored -= 1;
            gen.coal_stored = max(gen.coal_stored, 0);

            show_debug_message("Gerador consumiu 1 carvao. Restante: " + string(gen.coal_stored));
        }
    }

    power_recalculate();
}