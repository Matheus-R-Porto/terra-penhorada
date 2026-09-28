function save_contracts_data() {
    var result = {
        contracts: [],
        next_contract_id: 0,
        last_failed_contract_owner: "",
        last_failed_contract_days_ago: -1
    };

    var controller = contract_get_controller();

    if (controller == noone) {
        return result;
    }

    if (variable_instance_exists(controller.id, "next_contract_id")) {
        result.next_contract_id = controller.next_contract_id;
    }

    if (variable_instance_exists(controller.id, "last_failed_contract_owner")) {
        result.last_failed_contract_owner = controller.last_failed_contract_owner;
    }

    if (variable_instance_exists(controller.id, "last_failed_contract_days_ago")) {
        result.last_failed_contract_days_ago = controller.last_failed_contract_days_ago;
    }

    if (!variable_instance_exists(controller.id, "contracts")) {
        controller.contracts = [];
    }

    for (var i = 0; i < array_length(controller.contracts); i++) {
        var c = controller.contracts[i];

        array_push(result.contracts, {
            id: c.id,
            owner: c.owner,
            type: c.type,
            required_item: c.required_item,
            required_amount: c.required_amount,
            reward_money: c.reward_money,
            days_left: c.days_left,
            duration: c.duration,
            active: c.active,
            delivered_today: c.delivered_today,
            failed: c.failed
        });
    }

    return result;
}

function load_contracts_data(_saved_contract_data) {
    var controller = contract_get_controller();

    if (controller == noone) {
        show_debug_message("Load contracts: controlador nao encontrado.");
        return;
    }

    controller.contracts = [];
    controller.next_contract_id = 0;
    controller.last_failed_contract_owner = "";
    controller.last_failed_contract_days_ago = -1;

    if (is_undefined(_saved_contract_data)) {
        return;
    }

    if (variable_struct_exists(_saved_contract_data, "next_contract_id")) {
        controller.next_contract_id = _saved_contract_data.next_contract_id;
    }

    if (variable_struct_exists(_saved_contract_data, "last_failed_contract_owner")) {
        controller.last_failed_contract_owner = _saved_contract_data.last_failed_contract_owner;
    }

    if (variable_struct_exists(_saved_contract_data, "last_failed_contract_days_ago")) {
        controller.last_failed_contract_days_ago = _saved_contract_data.last_failed_contract_days_ago;
    }

    if (!variable_struct_exists(_saved_contract_data, "contracts")) {
        return;
    }

    var saved_contracts = _saved_contract_data.contracts;

    for (var i = 0; i < array_length(saved_contracts); i++) {
        var saved_c = saved_contracts[i];

        var c = {
            id: 0,
            owner: "",
            type: "Geral",
            required_item: "tomato",
            required_amount: 1,
            reward_money: 1,
            days_left: 1,
            duration: 3,
            active: false,
            delivered_today: false,
            failed: false
        };

        if (variable_struct_exists(saved_c, "id")) {
            c.id = saved_c.id;
        }

        if (variable_struct_exists(saved_c, "owner")) {
            c.owner = saved_c.owner;
        }

        if (variable_struct_exists(saved_c, "type")) {
            c.type = saved_c.type;
        }

        if (variable_struct_exists(saved_c, "required_item")) {
            c.required_item = saved_c.required_item;
        }

        if (variable_struct_exists(saved_c, "required_amount")) {
            c.required_amount = saved_c.required_amount;
        }

        if (variable_struct_exists(saved_c, "reward_money")) {
            c.reward_money = saved_c.reward_money;
        }

        if (variable_struct_exists(saved_c, "days_left")) {
            c.days_left = saved_c.days_left;
        }

        if (variable_struct_exists(saved_c, "duration")) {
            c.duration = saved_c.duration;
        }

        if (variable_struct_exists(saved_c, "active")) {
            c.active = saved_c.active;
        }

        if (variable_struct_exists(saved_c, "delivered_today")) {
            c.delivered_today = saved_c.delivered_today;
        }

        if (variable_struct_exists(saved_c, "failed")) {
            c.failed = saved_c.failed;
        }

        array_push(controller.contracts, c);
    }

    show_debug_message("Contratos carregados: " + string(array_length(controller.contracts)));
}

function save_contracts_write(_data) {
    _data.contracts_data = save_contracts_data();

    return _data;
}

function save_contracts_read(_data) {
    if (variable_struct_exists(_data, "contracts_data")) {
        load_contracts_data(_data.contracts_data);
    }
    else {
        load_contracts_data(undefined);
    }

    return true;
}