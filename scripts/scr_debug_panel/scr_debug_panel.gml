function debug_get_category_count() {
    return 4;
}

function debug_get_category_name(_category) {
    switch (_category) {
        case 0: return "Itens";
        case 1: return "Divida";
        case 2: return "Tempo";
        case 3: return "Clima";
    }

    return "Desconhecido";
}

function debug_get_option_count(_category) {
    switch (_category) {
        case 0: return 13; // Itens
        case 1: return 5;  // Divida
        case 2: return 4;  // Tempo
        case 3: return 2;  // Clima
    }

    return 0;
}

function debug_get_option_name(_category, _index) {
    switch (_category) {
        // =====================
        // ITENS
        // =====================
        case 0:
            switch (_index) {
                case 0: return "Adicionar dinheiro";
                case 1: return "Adicionar semente de tomate";
                case 2: return "Adicionar semente de milho";
                case 3: return "Adicionar tomate";
                case 4: return "Adicionar milho";
                case 5: return "Adicionar ovo";
                case 6: return "Adicionar racao";
                case 7: return "Adicionar minerio";
                case 8: return "Adicionar barra";
                case 9: return "Adicionar irrigador";
                case 10: return "Adicionar alimentador";
                case 11: return "Adicionar bau";
                case 12: return "Limpar inventario";
            }
            break;

        // =====================
        // DIVIDA
        // =====================
        case 1:
            switch (_index) {
                case 0: return "Forcar cobranca";
                case 1: return "Atrasar divida";
                case 2: return "Pagar divida se possivel";
                case 3: return "Quitar divida";
                case 4: return "Resetar divida";
            }
            break;

        // =====================
        // TEMPO
        // =====================
        case 2:
            switch (_index) {
                case 0: return "Passar 1 dia";
                case 1: return "Passar varios dias";
                case 2: return "Avancar periodo";
                case 3: return "Voltar para manha";
            }
            break;

        // =====================
        // CLIMA
        // =====================
        case 3:
            switch (_index) {
                case 0: return "Forcar clima limpo";
                case 1: return "Forcar chuva";
            }
            break;
    }

    return "Opcao desconhecida";
}

function debug_option_uses_amount(_category, _index) {
    if (_category == 0) {
        return _index != 12; // limpar inventario não usa quantidade
    }

    if (_category == 1) {
        return _index == 1; // atrasar dívida por quantidade
    }

    if (_category == 2) {
        return _index == 1; // passar vários dias
    }

    return false;
}

function debug_get_item_from_option(_index) {
    switch (_index) {
        case 0: return "money";
        case 1: return "tomato_seed";
        case 2: return "corn_seed";
        case 3: return "tomato";
        case 4: return "corn";
        case 5: return "egg";
        case 6: return "feed";
		case 7: return "coal";
        case 8: return "ore";
        case 9: return "bar";
        case 10: return "sprinkler_item";
        case 12: return "feeder_item";
        case 13: return "chest_item";
    }

    return "";
}

function debug_clear_inventory(_player) {
    _player.inventory_slots = inventory_create(_player.inventory_size);
    ui_message("Inventario limpo.", 1);
}

function debug_add_selected_item(_player, _index, _amount) {
    var item_id = debug_get_item_from_option(_index);

    if (item_id == "") {
        ui_message("Item invalido.", 1);
        return false;
    }

    // Dinheiro nao e mais item.
    // A opcao "Adicionar dinheiro" continua no debug,
    // mas agora mexe em global.money.
    if (item_id == "money") {
        money_add(_amount);
        ui_message("Debug: +$" + string(_amount) + ".", 1);
        show_debug_message("Debug adicionou dinheiro fora do inventario: $" + string(_amount));
        return true;
    }

    if (inventory_add(_player.inventory_slots, item_id, _amount, _player.carry_weight_max)) {
        ui_message("Debug: +" + string(_amount) + " " + item_get_name(item_id) + ".", 1);
        return true;
    }

    ui_message("Inventario cheio ou pesado demais.", 2);
    return false;
}

function debug_reset_debt() {
    if (!instance_exists(obj_time)) {
        return;
    }

    obj_time.debt_total = 500;
    obj_time.debt_payment_amount = 100;
    obj_time.debt_overdue_amount = 0;
    obj_time.debt_interest_rate = 0.10;
    obj_time.debt_is_overdue = false;
    obj_time.debt_missed_payments = 0;
    obj_time.debt_last_event_text = "Divida resetada via debug.";

    ui_message("Divida resetada.", 1);
}

function debug_delay_debt(_amount) {
    if (!instance_exists(obj_time)) {
        return;
    }

    obj_time.debt_overdue_amount += _amount;
    obj_time.debt_is_overdue = true;
    obj_time.debt_missed_payments += 1;
    obj_time.debt_last_event_text = "Atraso manual via debug: $" + string(_amount) + ".";

    ui_message("Debug: divida atrasada em $" + string(_amount) + ".", 2);
}

function debug_pay_debt_if_possible() {
    debt_process_monthly_payment();
}

function debug_clear_debt() {
    if (!instance_exists(obj_time)) {
        return;
    }

    obj_time.debt_total = 0;
    obj_time.debt_overdue_amount = 0;
    obj_time.debt_is_overdue = false;
    obj_time.debt_missed_payments = 0;
    obj_time.debt_last_event_text = "Divida quitada via debug.";

    ui_message("Debug: divida quitada.", 2);
}

function debug_advance_time_phase() {
    if (!instance_exists(obj_time)) {
        return;
    }

    obj_time.time_phase += 1;

    if (obj_time.time_phase > 2) {
        obj_time.time_phase = 0;
        time_advance_day();
        return;
    }

    if (obj_time.time_phase == 0) {
        obj_time.phase_name = "Manha";
    }
    else if (obj_time.time_phase == 1) {
        obj_time.phase_name = "Tarde";
    }
    else if (obj_time.time_phase == 2) {
        obj_time.phase_name = "Noite";
    }

    ui_message("Periodo: " + obj_time.phase_name + ".", 1);
}

function debug_set_morning() {
    if (!instance_exists(obj_time)) {
        return;
    }

    obj_time.time_phase = 0;
    obj_time.phase_name = "Manha";

    ui_message("Periodo voltou para manha.", 1);
}

function debug_set_weather(_weather) {
    if (!instance_exists(obj_time)) {
        return;
    }

    obj_time.weather_today = _weather;

    if (_weather == "rain") {
        ui_message("Clima forcado: chuva.", 1);
    }
    else {
        ui_message("Clima forcado: limpo.", 1);
    }
}

function debug_execute_option(_player) {
    var category = _player.debug_category;
    var index = _player.debug_selected;
    var amount = _player.debug_amount;

    switch (category) {
        // =====================
        // ITENS
        // =====================
        case 0:
            if (index == 12) {
                debug_clear_inventory(_player);
            }
            else {
                debug_add_selected_item(_player, index, amount);
            }
            return;

        // =====================
        // DIVIDA
        // =====================
        case 1:
            switch (index) {
                case 0:
                    debt_process_monthly_payment();
                    return;

                case 1:
                    debug_delay_debt(amount);
                    return;

                case 2:
                    debug_pay_debt_if_possible();
                    return;

                case 3:
                    debug_clear_debt();
                    return;

                case 4:
                    debug_reset_debt();
                    return;
            }
            return;

        // =====================
        // TEMPO
        // =====================
        case 2:
            switch (index) {
                case 0:
                    time_advance_day();
                    return;

                case 1:
                    for (var i = 0; i < amount; i++) {
                        time_advance_day();
                    }
                    return;

                case 2:
                    debug_advance_time_phase();
                    return;

                case 3:
                    debug_set_morning();
                    return;
            }
            return;

        // =====================
        // CLIMA
        // =====================
        case 3:
            switch (index) {
                case 0:
                    debug_set_weather("clear");
                    return;

                case 1:
                    debug_set_weather("rain");
                    return;
            }
            return;
    }
}