function money_init(_start_amount = 100) {
    if (!variable_global_exists("money")) {
        global.money = max(0, floor(_start_amount));
    }

    return global.money;
}

function money_get() {
    if (!variable_global_exists("money")) {
        money_init(100);
    }

    return global.money;
}

function money_set(_amount) {
    global.money = max(0, floor(_amount));

    return global.money;
}

function money_add(_amount) {
    var amount = floor(_amount);

    if (amount <= 0) {
        return money_get();
    }

    global.money = money_get() + amount;

    return global.money;
}

function money_can_spend(_amount) {
    var amount = floor(_amount);

    if (amount <= 0) {
        return true;
    }

    return money_get() >= amount;
}

function money_spend(_amount) {
    var amount = floor(_amount);

    if (amount <= 0) {
        return true;
    }

    if (!money_can_spend(amount)) {
        return false;
    }

    global.money = money_get() - amount;

    return true;
}