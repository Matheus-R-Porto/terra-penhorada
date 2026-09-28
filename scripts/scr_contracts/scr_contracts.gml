function contract_get_controller() {
    if (!instance_exists(obj_contract_controller)) {
        return noone;
    }

    return instance_find(obj_contract_controller, 0);
}

function contract_get_owner_type(_owner) {
    if (_owner == "Marta") {
        return "Agricola";
    }

    if (_owner == "Dario") {
        return "Mineracao";
    }

    return "Geral";
}

function contract_count_player_item(_player, _item_id) {
    if (_player == noone) {
        return 0;
    }

    var total = 0;

    total += inventory_count(_player.inventory_slots, _item_id);
    total += inventory_count(_player.hotbar_slots, _item_id);

    return total;
}

function contract_remove_player_item(_player, _item_id, _amount) {
    if (_player == noone) {
        return false;
    }

    if (contract_count_player_item(_player, _item_id) < _amount) {
        return false;
    }

    var remaining = _amount;

    var inv_amount = inventory_count(_player.inventory_slots, _item_id);
    var remove_from_inventory = min(inv_amount, remaining);

    if (remove_from_inventory > 0) {
        inventory_remove(_player.inventory_slots, _item_id, remove_from_inventory);
        remaining -= remove_from_inventory;
    }

    if (remaining > 0) {
        inventory_remove(_player.hotbar_slots, _item_id, remaining);
        remaining = 0;
    }

    return true;
}

function contract_find_active_index(_owner) {
    var controller = contract_get_controller();

    if (controller == noone) {
        return -1;
    }

    for (var i = 0; i < array_length(controller.contracts); i++) {
        var c = controller.contracts[i];

        if (c.owner == _owner && c.active) {
            return i;
        }
    }

    return -1;
}

function contract_owner_delivered_today(_owner) {
    var controller = contract_get_controller();

    if (controller == noone) {
        return false;
    }

    for (var i = 0; i < array_length(controller.contracts); i++) {
        var c = controller.contracts[i];

        if (c.owner == _owner && c.delivered_today) {
            return true;
        }
    }

    return false;
}

function contract_generate_for_owner(_owner) {
    var controller = contract_get_controller();

    if (controller == noone) {
        return undefined;
    }

    var item = "";
    var amount = 0;
    var reward = 0;
    var contract_type = contract_get_owner_type(_owner);

    if (_owner == "Marta") {
        var roll_marta = irandom(2);

        if (roll_marta == 0) {
            item = "tomato";
            amount = 2;
            reward = 15;
        }
        else if (roll_marta == 1) {
            item = "corn";
            amount = 2;
            reward = 20;
        }
        else {
            item = "egg";
            amount = 2;
            reward = 18;
        }
    }
    else if (_owner == "Dario") {
        var roll_dario = irandom(1);

        if (roll_dario == 0) {
            item = "ore";
            amount = 2;
            reward = 12;
        }
        else {
            item = "bar";
            amount = 1;
            reward = 18;
        }
    }
    else {
        item = "tomato";
        amount = 1;
        reward = 5;
    }

    var new_contract = {
        id: controller.next_contract_id,
        owner: _owner,
        type: contract_type,
        required_item: item,
        required_amount: amount,
        reward_money: reward,
        days_left: 3,
        duration: 3,
        active: true,
        delivered_today: false,
        failed: false
    };

    controller.next_contract_id += 1;

    return new_contract;
}

function contract_get_reward(_contract) {
    var reward = _contract.reward_money;

    // Futuro:
    // aqui entra modificador por relacao com NPC.
    // Por enquanto, na refatoracao, mantem simples.

    reward = max(reward, 1);

    return reward;
}

function contract_handle_for_owner(_owner) {
    var controller = contract_get_controller();

    if (controller == noone) {
        ui_message("Nenhum controlador de contrato.", 2);
        return false;
    }

    if (!instance_exists(obj_player)) {
        ui_message("Player nao encontrado.", 2);
        return false;
    }

    var player = obj_player;

    if (contract_owner_delivered_today(_owner)) {
        ui_message("Contrato de " + _owner + " ja entregue hoje.", 2);
        return false;
    }

    var active_index = contract_find_active_index(_owner);

    // Se nao tem contrato ativo desse NPC, cria um novo
    if (active_index == -1) {
        var new_contract = contract_generate_for_owner(_owner);

        if (is_undefined(new_contract)) {
            ui_message("Nao foi possivel criar contrato.", 2);
            return false;
        }

        array_push(controller.contracts, new_contract);

        ui_message(
            "Contrato de " +
            _owner +
            ": " +
            string(new_contract.required_amount) +
            " " +
            item_get_name(new_contract.required_item) +
            " em " +
            string(new_contract.days_left) +
            " dias. Recompensa: $" +
            string(contract_get_reward(new_contract)),
            4
        );

        show_debug_message("Contrato criado para " + _owner);

        return true;
    }

    // Se ja tem contrato ativo, tenta entregar
    var c = controller.contracts[active_index];

    var item_count = contract_count_player_item(player, c.required_item);
    var reward = contract_get_reward(c);

    if (item_count >= c.required_amount) {
        contract_remove_player_item(player, c.required_item, c.required_amount);

        money_add(reward);
		reputation_add(_owner, 2);

        c.active = false;
        c.delivered_today = true;
        c.days_left = 0;

        controller.contracts[active_index] = c;

        ui_message("Contrato de " + _owner + " entregue! +$" + string(reward) + " | Rep +2", 2);
        show_debug_message("Contrato entregue para " + _owner + ". Recompensa: $" + string(reward));

        return true;
    }
    else {
        var missing = c.required_amount - item_count;

        ui_message(
            "Contrato de " +
            _owner +
            ": faltam " +
            string(missing) +
            " " +
            item_get_name(c.required_item) +
            ". Prazo: " +
            string(c.days_left) +
            " dias.",
            3
        );

        show_debug_message("Contrato incompleto de " + _owner);

        return false;
    }
}

function contract_process_next_day() {
    var controller = contract_get_controller();

    if (controller == noone) {
        return;
    }

    var new_contracts = [];

    for (var i = 0; i < array_length(controller.contracts); i++) {
        var c = controller.contracts[i];

        // Contrato entregue hoje some no dia seguinte
        if (c.delivered_today) {
            show_debug_message("Contrato entregue removido no novo dia: " + c.owner);
            continue;
        }

        if (c.active) {
            c.days_left -= 1;

            if (c.days_left <= 0) {
                c.active = false;
                c.failed = true;
                c.days_left = 0;

				reputation_add(c.owner, -1);

                controller.last_failed_contract_owner = c.owner;
                controller.last_failed_contract_days_ago = 0;

                ui_message("Contrato falhou: " + c.owner + ".", 3);
                show_debug_message("Contrato falhou: " + c.owner);

                continue;
            }

            array_push(new_contracts, c);
        }
    }

    controller.contracts = new_contracts;

    contract_process_gossip_next_day();

    show_debug_message("Contratos processados para o novo dia.");
}

function contract_process_gossip_next_day() {
    var controller = contract_get_controller();

    if (controller == noone) {
        return;
    }

    if (controller.last_failed_contract_owner == "") {
        return;
    }

    if (controller.last_failed_contract_days_ago < 0) {
        return;
    }

    controller.last_failed_contract_days_ago += 1;

    if (controller.last_failed_contract_days_ago > 3) {
        controller.last_failed_contract_owner = "";
        controller.last_failed_contract_days_ago = -1;

        show_debug_message("Fofoca de contrato falhado expirou.");
    }
}
function contract_panel_get_owner_count() {
    return 2;
}

function contract_panel_get_owner(_index) {
    switch (_index) {
        case 0: return "Marta";
        case 1: return "Dario";
    }

    return "";
}

function contract_get_active_for_owner(_owner) {
    var controller = contract_get_controller();

    if (controller == noone) {
        return undefined;
    }

    var active_index = contract_find_active_index(_owner);

    if (active_index < 0) {
        return undefined;
    }

    return controller.contracts[active_index];
}

function contract_get_status_text_for_owner(_owner) {
    if (contract_owner_delivered_today(_owner)) {
        return "Entregue hoje";
    }

    var c = contract_get_active_for_owner(_owner);

    if (!is_undefined(c)) {
        return "Ativo";
    }

    return "Disponivel";
}

function contract_panel_count_active_contracts() {
    var controller = contract_get_controller();

    if (controller == noone) {
        return 0;
    }

    var count = 0;

    for (var i = 0; i < array_length(controller.contracts); i++) {
        var c = controller.contracts[i];

        if (c.active) {
            count += 1;
        }
    }

    return count;
}

function contract_panel_get_nth_active_contract(_visible_index) {
    var controller = contract_get_controller();

    if (controller == noone) {
        return undefined;
    }

    var count = 0;

    for (var i = 0; i < array_length(controller.contracts); i++) {
        var c = controller.contracts[i];

        if (c.active) {
            if (count == _visible_index) {
                return c;
            }

            count += 1;
        }
    }

    return undefined;
}

function player_update_contract_panel() {
    if (!contract_panel_open) {
        return;
    }

    if (keyboard_check_pressed(vk_escape) || keyboard_check_pressed(ord("C"))) {
        contract_panel_open = false;
        ui_message("Contratos fechado.", 1);
        return;
    }

    var active_count = contract_panel_count_active_contracts();

    if (active_count > 0) {
        if (keyboard_check_pressed(ord("W"))) {
            contract_panel_selected -= 1;
        }

        if (keyboard_check_pressed(ord("S"))) {
            contract_panel_selected += 1;
        }

        contract_panel_selected = clamp(contract_panel_selected, 0, active_count - 1);
    }
    else {
        contract_panel_selected = 0;
    }
}