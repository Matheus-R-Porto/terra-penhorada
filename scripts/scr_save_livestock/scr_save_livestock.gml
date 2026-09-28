function save_chickens_array() {
    var chickens = [];

    for (var i = 0; i < instance_number(obj_chicken); i++) {
        var chicken = instance_find(obj_chicken, i);

        var _fed = false;
        var _days_without_feed = 0;
        var _hungry_limit = 2;
        var _home_x = chicken.x;
        var _home_y = chicken.y;

        if (variable_instance_exists(chicken.id, "fed")) {
            _fed = chicken.fed;
        }

        if (variable_instance_exists(chicken.id, "days_without_feed")) {
            _days_without_feed = chicken.days_without_feed;
        }

        if (variable_instance_exists(chicken.id, "hungry_limit")) {
            _hungry_limit = chicken.hungry_limit;
        }

        if (variable_instance_exists(chicken.id, "home_x")) {
            _home_x = chicken.home_x;
        }

        if (variable_instance_exists(chicken.id, "home_y")) {
            _home_y = chicken.home_y;
        }

        array_push(chickens, {
            object_type: "chicken",
            x: chicken.x,
            y: chicken.y,
            home_x: _home_x,
            home_y: _home_y,
            fed: _fed,
            days_without_feed: _days_without_feed,
            hungry_limit: _hungry_limit
        });
    }

    return chickens;
}

function load_chickens_array(_saved_chickens) {
    with (obj_chicken) {
        instance_destroy();
    }

    if (is_undefined(_saved_chickens)) {
        return;
    }

    for (var i = 0; i < array_length(_saved_chickens); i++) {
        var saved_chicken = _saved_chickens[i];

        var chicken = instance_create_layer(
            saved_chicken.x,
            saved_chicken.y,
            "Instances",
            obj_chicken
        );

        if (variable_struct_exists(saved_chicken, "home_x")) {
            chicken.home_x = saved_chicken.home_x;
        }
        else {
            chicken.home_x = chicken.x;
        }

        if (variable_struct_exists(saved_chicken, "home_y")) {
            chicken.home_y = saved_chicken.home_y;
        }
        else {
            chicken.home_y = chicken.y;
        }

        if (variable_struct_exists(saved_chicken, "fed")) {
            chicken.fed = saved_chicken.fed;
        }
        else {
            chicken.fed = false;
        }

        if (variable_struct_exists(saved_chicken, "days_without_feed")) {
            chicken.days_without_feed = saved_chicken.days_without_feed;
        }
        else {
            chicken.days_without_feed = 0;
        }

        if (variable_struct_exists(saved_chicken, "hungry_limit")) {
            chicken.hungry_limit = saved_chicken.hungry_limit;
        }
        else {
            chicken.hungry_limit = 2;
        }

        chicken.move_target_x = chicken.x;
        chicken.move_target_y = chicken.y;
        chicken.move_timer = irandom_range(60, 180);
        chicken.is_moving = false;
    }
}

function save_egg_drops_array() {
    var egg_drops = [];

    for (var i = 0; i < instance_number(obj_egg_drop); i++) {
        var egg_drop = instance_find(obj_egg_drop, i);

        var _item_id = "egg";
        var _amount = 1;

        if (variable_instance_exists(egg_drop.id, "item_id")) {
            _item_id = egg_drop.item_id;
        }

        if (variable_instance_exists(egg_drop.id, "amount")) {
            _amount = egg_drop.amount;
        }

        array_push(egg_drops, {
            x: egg_drop.x,
            y: egg_drop.y,
            item_id: _item_id,
            amount: _amount
        });
    }

    return egg_drops;
}

function load_egg_drops_array(_saved_egg_drops) {
    with (obj_egg_drop) {
        instance_destroy();
    }

    if (is_undefined(_saved_egg_drops)) {
        return;
    }

    for (var i = 0; i < array_length(_saved_egg_drops); i++) {
        var saved_egg = _saved_egg_drops[i];

        var egg_drop = instance_create_layer(
            saved_egg.x,
            saved_egg.y,
            "Instances",
            obj_egg_drop
        );

        if (variable_struct_exists(saved_egg, "item_id")) {
            egg_drop.item_id = saved_egg.item_id;
        }
        else {
            egg_drop.item_id = "egg";
        }

        if (variable_struct_exists(saved_egg, "amount")) {
            egg_drop.amount = saved_egg.amount;
        }
        else {
            egg_drop.amount = 1;
        }
    }
}

function save_livestock_write(_data) {
    _data.chickens = save_chickens_array();
    _data.egg_drops = save_egg_drops_array();

    return _data;
}

function save_livestock_read(_data) {
    if (variable_struct_exists(_data, "chickens")) {
        load_chickens_array(_data.chickens);
    }

    if (variable_struct_exists(_data, "egg_drops")) {
        load_egg_drops_array(_data.egg_drops);
    }

    return true;
}