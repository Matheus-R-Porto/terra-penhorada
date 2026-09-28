function save_reputation_write(_data) {
    reputation_init();
    reputation_daily_init();

    _data.npc_reputation = {
        Marta: reputation_get("Marta"),
        Dario: reputation_get("Dario")
    };

    _data.npc_talked_today = {
        Marta: reputation_has_talked_today("Marta"),
        Dario: reputation_has_talked_today("Dario")
    };

    return _data;
}

function save_reputation_read(_data) {
    reputation_init();
    reputation_daily_init();

    if (variable_struct_exists(_data, "npc_reputation")) {
        var rep_data = _data.npc_reputation;

        if (variable_struct_exists(rep_data, "Marta")) {
            reputation_set("Marta", rep_data.Marta);
        }

        if (variable_struct_exists(rep_data, "Dario")) {
            reputation_set("Dario", rep_data.Dario);
        }
    }

    if (variable_struct_exists(_data, "npc_talked_today")) {
        var talked_data = _data.npc_talked_today;

        if (variable_struct_exists(talked_data, "Marta")) {
            variable_struct_set(global.npc_talked_today, "Marta", talked_data.Marta);
        }

        if (variable_struct_exists(talked_data, "Dario")) {
            variable_struct_set(global.npc_talked_today, "Dario", talked_data.Dario);
        }
    }

    return true;
}