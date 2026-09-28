function npc_contract_get_nearby(_player) {
    var nearest_npc = noone;
    var nearest_dist = 999999;

    var marta = instance_nearest(_player.x, _player.y, obj_npc_marta);

    if (marta != noone) {
        var dist_marta = point_distance(_player.x, _player.y, marta.x, marta.y);

        if (dist_marta <= INTERACT_RANGE && dist_marta < nearest_dist) {
            nearest_npc = marta;
            nearest_dist = dist_marta;
        }
    }

    var dario = instance_nearest(_player.x, _player.y, obj_npc_dario);

    if (dario != noone) {
        var dist_dario = point_distance(_player.x, _player.y, dario.x, dario.y);

        if (dist_dario <= INTERACT_RANGE && dist_dario < nearest_dist) {
            nearest_npc = dario;
            nearest_dist = dist_dario;
        }
    }

    return nearest_npc;
}

function npc_get_name(_npc) {
    if (_npc == noone) {
        return "";
    }

    if (variable_instance_exists(_npc.id, "npc_name")) {
        return _npc.npc_name;
    }

    return "NPC";
}

function npc_get_contract_owner(_npc) {
    if (_npc == noone) {
        return "";
    }

    if (variable_instance_exists(_npc.id, "contract_owner")) {
        return _npc.contract_owner;
    }

    return "";
}

function npc_interact_contract(_npc) {
    if (_npc == noone) {
        return false;
    }

    if (variable_instance_exists(_npc.id, "dialogue_line")) {
        ui_message(npc_get_name(_npc) + ": " + _npc.dialogue_line, 2);
    }

    var owner = npc_get_contract_owner(_npc);

    if (owner == "") {
        ui_message("Este NPC ainda nao tem contrato.", 2);
        return false;
    }

    contract_handle_for_owner(owner);

    return true;
}

function npc_open_panel(_player, _npc) {
    if (_npc == noone) {
        return false;
    }

    _player.current_npc = _npc;
    _player.npc_panel_open = true;
    _player.npc_panel_selected = 0;

    ui_message("Falando com " + npc_get_name(_npc) + ".", 1);

    return true;
}

function npc_get_talk_text(_npc_name) {
    var tier = reputation_get_tier(_npc_name);

    if (_npc_name == "Marta") {
        if (tier == "ruim") {
            return "Marta cruza os bracos. \"Contrato eu ate tenho. Confianca ja e outra conversa.\"";
        }

        if (tier == "boa") {
            return "Marta sorri de canto. \"Voce vem cumprindo o que promete. Isso ja e raro por aqui.\"";
        }

        return "Marta ajeita algumas anotacoes. \"Se veio por trabalho, talvez eu tenha algo.\"";
    }

    if (_npc_name == "Dario") {
        if (tier == "ruim") {
            return "Dario olha voce de cima a baixo. \"Minerio pesa. Palavra furada tambem.\"";
        }

        if (tier == "boa") {
            return "Dario assente com a cabeca. \"Voce entrega. Gosto disso. Poupa conversa.\"";
        }

        return "Dario limpa as maos na roupa. \"Tenho servico de minerio, se voce aguentar.\"";
    }

    return "Nada de especial por enquanto.";
}

function npc_talk(_npc_name) {
    var text = npc_get_talk_text(_npc_name);

    if (!reputation_has_talked_today(_npc_name)) {
        reputation_add(_npc_name, 1);
        reputation_mark_talked_today(_npc_name);

        ui_message(text + " | Rep +1", 4);

        show_debug_message("Conversa com " + _npc_name + " deu +1 reputacao.");
        show_debug_message(reputation_get_label(_npc_name));
    }
    else {
        ui_message(text + " | Ja conversaram hoje.", 4);

        show_debug_message("Conversa com " + _npc_name + " sem bonus: ja conversou hoje.");
    }
}

function player_update_npc_panel() {
    if (!npc_panel_open) {
        return;
    }

    if (current_npc == noone || !instance_exists(current_npc)) {
        npc_panel_open = false;
        current_npc = noone;
        ui_message("NPC indisponivel.", 1);
        return;
    }

    if (keyboard_check_pressed(vk_escape)) {
        npc_panel_open = false;
        current_npc = noone;
        ui_message("Conversa fechada.", 1);
        return;
    }

    if (keyboard_check_pressed(ord("W"))) {
        npc_panel_selected -= 1;
    }

    if (keyboard_check_pressed(ord("S"))) {
        npc_panel_selected += 1;
    }

    npc_panel_selected = clamp(npc_panel_selected, 0, 2);

    if (keyboard_check_pressed(vk_enter)) {
        var npc_name = npc_get_contract_owner(current_npc);

        if (npc_name == "") {
            npc_name = npc_get_name(current_npc);
        }

        switch (npc_panel_selected) {
            case 0:
                npc_talk(npc_name);
                return;

            case 1:
                npc_panel_open = false;
                contract_handle_for_owner(npc_name);
                return;

            case 2:
                npc_panel_open = false;
                current_npc = noone;
                ui_message("Conversa fechada.", 1);
                return;
        }
    }
}