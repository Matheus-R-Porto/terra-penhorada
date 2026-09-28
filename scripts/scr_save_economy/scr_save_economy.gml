function save_economy_write(_data) {
    _data.money = money_get();

    return _data;
}

function save_economy_read(_data) {
    if (variable_struct_exists(_data, "money")) {
        money_set(_data.money);
    }
    else {
        // Save antigo: dinheiro ainda estava como item.
        // Comeca em 0 e depois a migracao do inventario converte "money" antigo.
        money_set(0);
    }

    return true;
}