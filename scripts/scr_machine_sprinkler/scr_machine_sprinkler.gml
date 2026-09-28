function sprinkler_can_water_plot(_sprinkler, _plot) {
    if (_sprinkler == noone || _plot == noone) {
        return false;
    }

    if (!_plot.planted) {
        return false;
    }

    if (_plot.ready) {
        return false;
    }

    // Mantém compatível com áreas futuras
    if (variable_instance_exists(_sprinkler.id, "area_id")
    && variable_instance_exists(_plot.id, "area_id")) {
        if (_sprinkler.area_id != _plot.area_id) {
            return false;
        }
    }

    var sprinkler_range = 64;

    if (variable_instance_exists(_sprinkler.id, "range")) {
        sprinkler_range = _sprinkler.range;
    }

    return point_distance(_sprinkler.x, _sprinkler.y, _plot.x, _plot.y) <= sprinkler_range;
}

function sprinkler_water_nearby_plots(_sprinkler) {
    if (_sprinkler == noone) {
        return 0;
    }

    var watered_count = 0;

    for (var i = 0; i < instance_number(obj_crop_plot); i++) {
        var plot = instance_find(obj_crop_plot, i);

        if (sprinkler_can_water_plot(_sprinkler, plot)) {
            if (!plot.watered) {
                plot.watered = true;
                watered_count += 1;

                crop_update_sprite(plot);
            }
        }
    }

    return watered_count;
}

function sprinklers_process_next_day() {
    var sprinkler_count = instance_number(obj_machine_sprinkler_basic);

    if (sprinkler_count <= 0) {
        return;
    }

    power_recalculate();

    if (!global.power_is_stable) {
        ui_message("Irrigadores parados: energia insuficiente.", 2);

        show_debug_message(
            "Irrigadores parados por falta de energia. Producao: " +
            string(global.power_production) +
            " | Consumo: " +
            string(global.power_consumption)
        );

        return;
    }

    var total_watered = 0;

    for (var i = 0; i < sprinkler_count; i++) {
        var sprinkler = instance_find(obj_machine_sprinkler_basic, i);

        total_watered += sprinkler_water_nearby_plots(sprinkler);
    }

    show_debug_message(
        "Irrigadores processados com energia. Plantacoes regadas: " +
        string(total_watered)
    );
}