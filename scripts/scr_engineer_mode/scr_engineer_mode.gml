function engineer_toggle() {
    engineer_mode = !engineer_mode;

    if (engineer_mode) {
        ui_message("Modo engenheiro ligado.", 1);
    }
    else {
        ui_message("Modo engenheiro desligado.", 1);
    }
}

function engineer_draw_grid() {
    if (!view_enabled) {
        return;
    }

    var cam = view_camera[0];

    var cam_x = camera_get_view_x(cam);
    var cam_y = camera_get_view_y(cam);
    var cam_w = camera_get_view_width(cam);
    var cam_h = camera_get_view_height(cam);

    var start_x = floor(cam_x / GRID_SIZE) * GRID_SIZE;
    var start_y = floor(cam_y / GRID_SIZE) * GRID_SIZE;

    draw_set_alpha(0.28);
	draw_set_color(make_color_rgb(35, 35, 35));
    
	for (var gx = start_x; gx <= cam_x + cam_w + GRID_SIZE; gx += GRID_SIZE) {
        draw_line(gx, cam_y, gx, cam_y + cam_h);
    }

    for (var gy = start_y; gy <= cam_y + cam_h + GRID_SIZE; gy += GRID_SIZE) {
        draw_line(cam_x, gy, cam_x + cam_w, gy);
    }

    draw_set_alpha(1);
    draw_set_color(c_black);
}

function engineer_draw_sprinklers() {
    power_recalculate();

    for (var i = 0; i < instance_number(obj_machine_sprinkler_basic); i++) {
        var sprinkler = instance_find(obj_machine_sprinkler_basic, i);

        var r = 64;

        if (variable_instance_exists(sprinkler.id, "range")) {
            r = sprinkler.range;
        }

        var required = 0;

        if (variable_instance_exists(sprinkler.id, "power_required")) {
            required = sprinkler.power_required;
        }

        draw_set_alpha(0.22);

        if (global.power_is_stable && global.power_production > 0) {
            draw_set_color(c_aqua);
        }
        else {
            draw_set_color(c_red);
        }

        draw_circle(sprinkler.x, sprinkler.y, r, false);

        draw_set_alpha(1);

        if (global.power_is_stable && global.power_production > 0) {
            draw_set_color(c_lime);
            draw_text(sprinkler.x - 28, sprinkler.y - 50, "Irrigador");
            draw_text(sprinkler.x - 22, sprinkler.y - 34, "Ligado");
        }
        else {
            draw_set_color(c_red);
            draw_text(sprinkler.x - 28, sprinkler.y - 50, "Irrigador");
            draw_text(sprinkler.x - 38, sprinkler.y - 34, "Sem energia");
        }

        draw_set_color(c_white);
        draw_text(sprinkler.x - 22, sprinkler.y - 18, "R:" + string(r));
        draw_text(sprinkler.x - 22, sprinkler.y - 2, "E:" + string(required));

        draw_set_alpha(1);
        draw_set_color(c_black);
    }
}

function engineer_draw_feeders() {
    for (var i = 0; i < instance_number(obj_machine_feeder_basic); i++) {
        var feeder = instance_find(obj_machine_feeder_basic, i);

        var r = 96;

        if (variable_instance_exists(feeder.id, "range")) {
            r = feeder.range;
        }

        draw_set_alpha(0.22);
        draw_set_color(c_yellow);
        draw_circle(feeder.x, feeder.y, r, false);

        draw_set_alpha(1);
        draw_set_color(c_black);
        draw_text(feeder.x - 34, feeder.y - 42, "Alimentador");
        draw_text(feeder.x - 22, feeder.y - 26, "R:" + string(r));
    }
}

function engineer_draw_world_overlay() {
    if (!instance_exists(obj_player)) {
        return;
    }

    if (!obj_player.engineer_mode) {
        return;
    }

    power_recalculate();

    engineer_draw_screen_tint();
    engineer_draw_grid();

    engineer_draw_power_summary();

    engineer_draw_generators();
    engineer_draw_sprinklers();
    engineer_draw_feeders();
}
	
function engineer_draw_screen_tint() {
    if (!view_enabled) {
        return;
    }

    var cam = view_camera[0];

    var cam_x = camera_get_view_x(cam);
    var cam_y = camera_get_view_y(cam);
    var cam_w = camera_get_view_width(cam);
    var cam_h = camera_get_view_height(cam);

    draw_set_alpha(0.16);
	draw_set_color(make_color_rgb(16, 30, 70));

    draw_rectangle(
        cam_x,
        cam_y,
        cam_x + cam_w,
        cam_y + cam_h,
        false
    );

    draw_set_alpha(1);
    draw_set_color(c_black);
}

function engineer_draw_power_summary() {
    if (!view_enabled) {
        return;
    }

    power_recalculate();

    var cam = view_camera[0];

    var cam_x = camera_get_view_x(cam);
    var cam_y = camera_get_view_y(cam);

    var panel_x = cam_x + 24;
    var panel_y = cam_y + 24;
    var panel_w = 300;
    var panel_h = 92;

    draw_set_alpha(0.78);
    draw_set_color(make_color_rgb(12, 18, 28));
    draw_rectangle(panel_x, panel_y, panel_x + panel_w, panel_y + panel_h, false);

    draw_set_alpha(1);
    draw_set_color(c_white);

    draw_text(panel_x + 14, panel_y + 12, "ENERGIA DA FAZENDA");

    draw_text(
        panel_x + 14,
        panel_y + 36,
        "Producao: " +
        string(global.power_production) +
        " | Consumo: " +
        string(global.power_consumption)
    );

    var status_text = power_get_status_text();

    if (global.power_is_stable) {
        draw_set_color(c_lime);
    }
    else {
        draw_set_color(c_red);
    }

    draw_text(panel_x + 14, panel_y + 60, "Status: " + status_text);

    draw_set_alpha(1);
    draw_set_color(c_black);
}
	
function engineer_draw_generators() {
    for (var i = 0; i < instance_number(obj_machine_generator_basic); i++) {
        var gen = instance_find(obj_machine_generator_basic, i);

        if (!variable_instance_exists(gen.id, "coal_stored")) {
            gen.coal_stored = 0;
        }

        if (!variable_instance_exists(gen.id, "coal_capacity")) {
            gen.coal_capacity = 10;
        }

        if (!variable_instance_exists(gen.id, "power_output")) {
            gen.power_output = 4;
        }

        draw_set_alpha(0.24);
        draw_set_color(make_color_rgb(255, 180, 60));
        draw_circle(gen.x, gen.y, 72, false);

        draw_set_alpha(1);

        if (gen.coal_stored > 0) {
            draw_set_color(c_lime);
            draw_text(gen.x - 34, gen.y - 54, "Gerador");
            draw_text(gen.x - 42, gen.y - 38, "ON +" + string(gen.power_output));
        }
        else {
            draw_set_color(c_red);
            draw_text(gen.x - 34, gen.y - 54, "Gerador");
            draw_text(gen.x - 42, gen.y - 38, "SEM CARVAO");
        }

        draw_set_color(c_white);
        draw_text(
            gen.x - 42,
            gen.y - 22,
            "C: " +
            string(gen.coal_stored) +
            "/" +
            string(gen.coal_capacity)
        );

        draw_set_alpha(1);
        draw_set_color(c_black);
    }
}