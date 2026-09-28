function save_time_debt_write(_data) {
    if (!instance_exists(obj_time)) {
        return _data;
    }

    // Tempo / calendário
    _data.year = obj_time.year;
    _data.month = obj_time.month;
    _data.day = obj_time.day;
    _data.day_of_month = obj_time.day_of_month;

    _data.time_phase = obj_time.time_phase;
    _data.phase_name = obj_time.phase_name;

    if (variable_instance_exists(obj_time.id, "weather_today")) {
        _data.weather_today = obj_time.weather_today;
    }
    else {
        _data.weather_today = "clear";
    }

    // Dívida
    _data.debt_total = obj_time.debt_total;
    _data.debt_payment_amount = obj_time.debt_payment_amount;
    _data.debt_overdue_amount = obj_time.debt_overdue_amount;
    _data.debt_interest_rate = obj_time.debt_interest_rate;
    _data.debt_is_overdue = obj_time.debt_is_overdue;
    _data.debt_missed_payments = obj_time.debt_missed_payments;
    _data.debt_last_event_text = obj_time.debt_last_event_text;

    return _data;
}

function save_time_debt_read(_data) {
    if (!instance_exists(obj_time)) {
        ui_message("Erro: tempo nao encontrado.", 2);
        return false;
    }

    // Tempo / calendário
    if (variable_struct_exists(_data, "year")) {
        obj_time.year = _data.year;
    }

    if (variable_struct_exists(_data, "month")) {
        obj_time.month = _data.month;
    }

    if (variable_struct_exists(_data, "day")) {
        obj_time.day = _data.day;
    }

    if (variable_struct_exists(_data, "day_of_month")) {
        obj_time.day_of_month = _data.day_of_month;
    }

    if (variable_struct_exists(_data, "time_phase")) {
        obj_time.time_phase = _data.time_phase;
    }

    if (variable_struct_exists(_data, "phase_name")) {
        obj_time.phase_name = _data.phase_name;
    }

    if (variable_struct_exists(_data, "weather_today")) {
        obj_time.weather_today = _data.weather_today;
    }
    else {
        obj_time.weather_today = "clear";
    }

    // Dívida
    if (variable_struct_exists(_data, "debt_total")) {
        obj_time.debt_total = _data.debt_total;
    }

    if (variable_struct_exists(_data, "debt_payment_amount")) {
        obj_time.debt_payment_amount = _data.debt_payment_amount;
    }

    if (variable_struct_exists(_data, "debt_overdue_amount")) {
        obj_time.debt_overdue_amount = _data.debt_overdue_amount;
    }

    if (variable_struct_exists(_data, "debt_interest_rate")) {
        obj_time.debt_interest_rate = _data.debt_interest_rate;
    }

    if (variable_struct_exists(_data, "debt_is_overdue")) {
        obj_time.debt_is_overdue = _data.debt_is_overdue;
    }

    if (variable_struct_exists(_data, "debt_missed_payments")) {
        obj_time.debt_missed_payments = _data.debt_missed_payments;
    }

    if (variable_struct_exists(_data, "debt_last_event_text")) {
        obj_time.debt_last_event_text = _data.debt_last_event_text;
    }

    return true;
}