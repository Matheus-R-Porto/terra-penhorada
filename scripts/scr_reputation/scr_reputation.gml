function reputation_init() {
    if (!variable_global_exists("npc_reputation")) {
        global.npc_reputation = {};
    }

    if (!is_struct(global.npc_reputation)) {
        global.npc_reputation = {};
    }

    if (!variable_struct_exists(global.npc_reputation, "Marta")) {
        variable_struct_set(global.npc_reputation, "Marta", 0);
    }

    if (!variable_struct_exists(global.npc_reputation, "Dario")) {
        variable_struct_set(global.npc_reputation, "Dario", 0);
    }
}

function reputation_get(_npc_name) {
    reputation_init();

    if (!variable_struct_exists(global.npc_reputation, _npc_name)) {
        variable_struct_set(global.npc_reputation, _npc_name, 0);
    }

    return variable_struct_get(global.npc_reputation, _npc_name);
}

function reputation_set(_npc_name, _value) {
    reputation_init();

    var value = clamp(floor(_value), -5, 5);

    variable_struct_set(global.npc_reputation, _npc_name, value);

    return value;
}

function reputation_add(_npc_name, _amount) {
    var current = reputation_get(_npc_name);
    var next_value = current + floor(_amount);

    return reputation_set(_npc_name, next_value);
}

function reputation_get_tier(_npc_name) {
    var rep = reputation_get(_npc_name);

    if (rep <= -3) {
        return "ruim";
    }

    if (rep >= 3) {
        return "boa";
    }

    return "neutra";
}

function reputation_get_label(_npc_name) {
    var rep = reputation_get(_npc_name);
    var tier = reputation_get_tier(_npc_name);

    return "Reputacao com " + _npc_name + ": " + string(rep) + " (" + tier + ")";
}
	
function reputation_daily_init() {
    if (!variable_global_exists("npc_talked_today")) {
        global.npc_talked_today = {};
    }

    if (!is_struct(global.npc_talked_today)) {
        global.npc_talked_today = {};
    }

    if (!variable_struct_exists(global.npc_talked_today, "Marta")) {
        variable_struct_set(global.npc_talked_today, "Marta", false);
    }

    if (!variable_struct_exists(global.npc_talked_today, "Dario")) {
        variable_struct_set(global.npc_talked_today, "Dario", false);
    }
}

function reputation_has_talked_today(_npc_name) {
    reputation_daily_init();

    if (!variable_struct_exists(global.npc_talked_today, _npc_name)) {
        variable_struct_set(global.npc_talked_today, _npc_name, false);
    }

    return variable_struct_get(global.npc_talked_today, _npc_name);
}

function reputation_mark_talked_today(_npc_name) {
    reputation_daily_init();

    variable_struct_set(global.npc_talked_today, _npc_name, true);
}

function reputation_clear_talked_today() {
    global.npc_talked_today = {
        Marta: false,
        Dario: false
    };
}

function reputation_process_next_day() {
    reputation_clear_talked_today();

    show_debug_message("Conversas diarias de NPCs resetadas.");
}