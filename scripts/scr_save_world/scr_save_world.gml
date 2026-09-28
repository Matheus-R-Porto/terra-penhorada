function save_crops_array() {
    var crops = [];

    for (var i = 0; i < instance_number(obj_crop_plot); i++) {
        var plot = instance_find(obj_crop_plot, i);

        array_push(crops, {
            x: plot.x,
            y: plot.y,
            crop_id: plot.crop_id,
            crop_name: plot.crop_name,
            planted: plot.planted,
            watered: plot.watered,
            ready: plot.ready,
            growth_days: plot.growth_days,
            growth_required: plot.growth_required,
            harvest_item: plot.harvest_item,
            harvest_amount: plot.harvest_amount,
            area_id: plot.area_id
        });
    }

    return crops;
}

function load_crops_array(_saved_crops) {
    if (is_undefined(_saved_crops)) {
        return;
    }

    // Como os solos já existem na room, vamos aplicar o estado salvo
    // nos plots mais próximos da posição salva.
    for (var i = 0; i < array_length(_saved_crops); i++) {
        var saved_crop = _saved_crops[i];

        var plot = instance_position(saved_crop.x, saved_crop.y, obj_crop_plot);

        if (plot == noone) {
            plot = instance_nearest(saved_crop.x, saved_crop.y, obj_crop_plot);
        }

        if (plot != noone) {
            plot.crop_id = saved_crop.crop_id;
            plot.crop_name = saved_crop.crop_name;
            plot.planted = saved_crop.planted;
            plot.watered = saved_crop.watered;
            plot.ready = saved_crop.ready;
            plot.growth_days = saved_crop.growth_days;
            plot.growth_required = saved_crop.growth_required;
            plot.harvest_item = saved_crop.harvest_item;
            plot.harvest_amount = saved_crop.harvest_amount;

            if (variable_struct_exists(saved_crop, "area_id")) {
                plot.area_id = saved_crop.area_id;
            }
            else {
                plot.area_id = "farm";
            }

            crop_update_sprite(plot);
        }
    }
}

function save_chests_array() {
    var chests = [];

    for (var i = 0; i < instance_number(obj_storage_chest); i++) {
        var chest = instance_find(obj_storage_chest, i);

        array_push(chests, {
            x: chest.x,
            y: chest.y,
            storage_size: chest.storage_size,
            storage_slots: save_slot_array(chest.storage_slots),
            area_id: chest.area_id
        });
    }

    return chests;
}

function load_chests_array(_saved_chests) {
    // Remove baús atuais e recria a partir do save.
    // Isso evita duplicação e garante que baús colocados/removidos reflitam o save.
    with (obj_storage_chest) {
        instance_destroy();
    }

    if (is_undefined(_saved_chests)) {
        return;
    }

    for (var i = 0; i < array_length(_saved_chests); i++) {
        var saved_chest = _saved_chests[i];

        var chest = instance_create_layer(
            saved_chest.x,
            saved_chest.y,
            "Instances",
            obj_storage_chest
        );

        if (variable_struct_exists(saved_chest, "storage_size")) {
            chest.storage_size = saved_chest.storage_size;
        }

        if (variable_struct_exists(saved_chest, "storage_slots")) {
            chest.storage_slots = load_slot_array(saved_chest.storage_slots, chest.storage_size);
        }

        if (variable_struct_exists(saved_chest, "area_id")) {
            chest.area_id = saved_chest.area_id;
        }
        else {
            chest.area_id = "farm";
        }
    }
}
	
function save_ores_array() {
    var ores = [];

    for (var i = 0; i < instance_number(obj_resource_ore); i++) {
        var ore = instance_find(obj_resource_ore, i);

        array_push(ores, {
            x: ore.x,
            y: ore.y,
            resource_id: ore.resource_id,
            area_id: ore.area_id,
            mined: ore.mined,
            respawn_days_left: ore.respawn_days_left,
            respawn_days_required: ore.respawn_days_required,
            energy_cost: ore.energy_cost,
            drop_item: ore.drop_item,
            drop_amount: ore.drop_amount
        });
    }

    return ores;
}

function load_ores_array(_saved_ores) {
    if (is_undefined(_saved_ores)) {
        return;
    }

    for (var i = 0; i < array_length(_saved_ores); i++) {
        var saved_ore = _saved_ores[i];

        var ore = instance_position(saved_ore.x, saved_ore.y, obj_resource_ore);

        if (ore == noone) {
            ore = instance_nearest(saved_ore.x, saved_ore.y, obj_resource_ore);
        }

        if (ore != noone) {
            if (variable_struct_exists(saved_ore, "resource_id")) {
                ore.resource_id = saved_ore.resource_id;
            }

            if (variable_struct_exists(saved_ore, "area_id")) {
                ore.area_id = saved_ore.area_id;
            }
            else {
                ore.area_id = "cave_01";
            }

            if (variable_struct_exists(saved_ore, "mined")) {
                ore.mined = saved_ore.mined;
            }

            if (variable_struct_exists(saved_ore, "respawn_days_left")) {
                ore.respawn_days_left = saved_ore.respawn_days_left;
            }

            if (variable_struct_exists(saved_ore, "respawn_days_required")) {
                ore.respawn_days_required = saved_ore.respawn_days_required;
            }

            if (variable_struct_exists(saved_ore, "energy_cost")) {
                ore.energy_cost = saved_ore.energy_cost;
            }

            if (variable_struct_exists(saved_ore, "drop_item")) {
                ore.drop_item = saved_ore.drop_item;
            }

            if (variable_struct_exists(saved_ore, "drop_amount")) {
                ore.drop_amount = saved_ore.drop_amount;
            }

            ore_update_sprite(ore);
        }
    }
}

function save_world_write(_data) {
    // Plantações
    _data.crops = save_crops_array();

    // Baús
    _data.chests = save_chests_array();

    // Minérios
    _data.ores = save_ores_array();

    return _data;
}

function save_world_read(_data) {
    // Plantações
    if (variable_struct_exists(_data, "crops")) {
        load_crops_array(_data.crops);
    }

    // Baús
    if (variable_struct_exists(_data, "chests")) {
        load_chests_array(_data.chests);
    }

    // Minérios
    if (variable_struct_exists(_data, "ores")) {
        load_ores_array(_data.ores);
    }

    return true;
}