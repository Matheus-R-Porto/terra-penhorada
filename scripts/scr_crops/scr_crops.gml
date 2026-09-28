function crop_plot_init() {
    crop_id = "";
    crop_name = "";
    planted = false;
    watered = false;
    ready = false;

    growth_days = 0;
    growth_required = 0;

    harvest_item = "";
    harvest_amount = 1;

    area_id = "farm";

    crop_update_sprite(id);
}

function crop_get_from_seed(_seed_item) {
    switch (_seed_item) {
        case "tomato_seed":
            return {
                crop_id: "tomato",
                crop_name: "Tomate",
                growth_required: 3,
                harvest_item: "tomato",
                harvest_amount: 1
            };

        case "corn_seed":
            return {
                crop_id: "corn",
                crop_name: "Milho",
                growth_required: 4,
                harvest_item: "corn",
                harvest_amount: 1
            };
    }

    return undefined;
}

function crop_is_seed(_item_id) {
    return _item_id == "tomato_seed" || _item_id == "corn_seed";
}

function crop_plant(_plot, _seed_item) {
    if (_plot == noone) {
        return false;
    }

    if (_plot.planted) {
        ui_message("Ja tem algo plantado aqui.", 1);
        return false;
    }

    var crop_data = crop_get_from_seed(_seed_item);

    if (is_undefined(crop_data)) {
        ui_message("Item selecionado nao e semente.", 1);
        return false;
    }

    _plot.crop_id = crop_data.crop_id;
    _plot.crop_name = crop_data.crop_name;
    _plot.planted = true;
    _plot.watered = false;
    _plot.ready = false;

    _plot.growth_days = 0;
    _plot.growth_required = crop_data.growth_required;

    _plot.harvest_item = crop_data.harvest_item;
    _plot.harvest_amount = crop_data.harvest_amount;

    crop_update_sprite(_plot);

    ui_message("Plantou " + crop_data.crop_name + ".", 1);
    show_debug_message("Plantou: " + crop_data.crop_id);

    return true;
}

function crop_water(_plot) {
    if (_plot == noone) {
        return false;
    }

    if (!_plot.planted) {
        ui_message("Nao ha nada plantado aqui.", 1);
        return false;
    }

    if (_plot.ready) {
        ui_message("A plantacao ja esta pronta.", 1);
        return false;
    }

    if (_plot.watered) {
        ui_message("Ja foi regado hoje.", 1);
        return false;
    }

    _plot.watered = true;

    crop_update_sprite(_plot);

    ui_message("Plantacao regada.", 1);
    show_debug_message("Regou plantacao: " + string(_plot.crop_id));

    return true;
}

function crop_harvest(_plot, _player) {
    if (_plot == noone) {
        return false;
    }

    if (!_plot.planted || !_plot.ready) {
        ui_message("Nada pronto para colher.", 1);
        return false;
    }

    if (!player_add_item_to_inventory(_player, _plot.harvest_item, _plot.harvest_amount)) {
        ui_message("Inventario cheio ou pesado demais.", 2);
        return false;
    }

    ui_message("Colheu " + item_get_name(_plot.harvest_item) + ".", 1);

    _plot.crop_id = "";
    _plot.crop_name = "";
    _plot.planted = false;
    _plot.watered = false;
    _plot.ready = false;

    _plot.growth_days = 0;
    _plot.growth_required = 0;

    _plot.harvest_item = "";
    _plot.harvest_amount = 1;

    crop_update_sprite(_plot);

    return true;
}

function crops_process_next_day() {
    var processed = 0;

    for (var i = 0; i < instance_number(obj_crop_plot); i++) {
        var plot = instance_find(obj_crop_plot, i);

        if (plot.planted && !plot.ready) {
            if (plot.watered) {
                plot.growth_days += 1;
                processed += 1;

                if (plot.growth_days >= plot.growth_required) {
                    plot.ready = true;
                    plot.watered = false;
                }
                else {
                    plot.watered = false;
                }

                crop_update_sprite(plot);
            }
        }
        else if (plot.planted) {
            plot.watered = false;
            crop_update_sprite(plot);
        }
    }

    show_debug_message("Plantacoes processadas no novo dia: " + string(processed));
}

function crop_update_sprite(_plot) {
    if (_plot == noone) {
        return;
    }

    if (!_plot.planted) {
        _plot.sprite_index = spr_soil_empty;
        return;
    }

    if (_plot.crop_id == "tomato") {
        if (_plot.ready) {
            _plot.sprite_index = spr_tomatoes_soil_ready;
        }
        else if (_plot.watered) {
            _plot.sprite_index = spr_tomatoes_soil_watered;
        }
        else {
            _plot.sprite_index = spr_tomatoes_soil_planted;
        }

        return;
    }

    if (_plot.crop_id == "corn") {
        if (_plot.ready) {
            _plot.sprite_index = spr_corn_soil_ready;
        }
        else if (_plot.watered) {
            _plot.sprite_index = spr_corn_soil_watered;
        }
        else {
            _plot.sprite_index = spr_corn_soil_planted;
        }

        return;
    }

    _plot.sprite_index = spr_soil_empty;
}