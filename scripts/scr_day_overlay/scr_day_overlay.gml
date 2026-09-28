function day_overlay_get_color_for_phase(_phase) {
    switch (_phase) {
        case 0:
            // Manha
            return make_color_rgb(255, 245, 220);

        case 1:
            // Tarde
            return make_color_rgb(255, 210, 140);

        case 2:
            // Noite
            return make_color_rgb(20, 35, 80);
    }

    return make_color_rgb(255, 245, 220);
}

function day_overlay_get_alpha_for_phase(_phase) {
    switch (_phase) {
        case 0:
            return 0.04;

        case 1:
            return 0.10;

        case 2:
            return 0.28;
    }

    return 0.04;
}

function day_overlay_update() {
    if (!instance_exists(obj_time)) {
        return;
    }

    obj_time.day_overlay_target_color = day_overlay_get_color_for_phase(obj_time.time_phase);
    obj_time.day_overlay_target_alpha = day_overlay_get_alpha_for_phase(obj_time.time_phase);

    // Velocidade da transição visual.
    // Menor = mais suave/lenta.
    var t = 0.015;

    obj_time.day_overlay_color = merge_color(
        obj_time.day_overlay_color,
        obj_time.day_overlay_target_color,
        t
    );

    obj_time.day_overlay_alpha = lerp(
        obj_time.day_overlay_alpha,
        obj_time.day_overlay_target_alpha,
        t
    );
}

function day_overlay_draw() {
    if (!instance_exists(obj_time)) {
        return;
    }

    if (!view_enabled) {
        return;
    }

    day_overlay_update();

    var cam = view_camera[0];

    var cam_x = camera_get_view_x(cam);
    var cam_y = camera_get_view_y(cam);
    var cam_w = camera_get_view_width(cam);
    var cam_h = camera_get_view_height(cam);

    var overlay_alpha = obj_time.day_overlay_alpha;

    if (overlay_alpha <= 0) {
        return;
    }

    draw_set_alpha(overlay_alpha);
    draw_set_color(obj_time.day_overlay_color);

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
	
function day_overlay_apply_current_phase() {
    if (!instance_exists(obj_time)) {
        return;
    }

    var target_color = day_overlay_get_color_for_phase(obj_time.time_phase);
    var target_alpha = day_overlay_get_alpha_for_phase(obj_time.time_phase);

    obj_time.day_overlay_color = target_color;
    obj_time.day_overlay_target_color = target_color;

    obj_time.day_overlay_alpha = target_alpha;
    obj_time.day_overlay_target_alpha = target_alpha;

    show_debug_message(
        "Overlay aplicado imediatamente. Periodo: " +
        string(obj_time.time_phase) +
        " / " +
        obj_time.phase_name
    );
}