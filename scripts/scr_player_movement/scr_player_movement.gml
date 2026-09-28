function player_update_movement() {
    var mx = 0;
    var my = 0;

    if (keyboard_check(ord("A"))) {
        mx -= 1;
    }

    if (keyboard_check(ord("D"))) {
        mx += 1;
    }

    if (keyboard_check(ord("W"))) {
        my -= 1;
    }

    if (keyboard_check(ord("S"))) {
        my += 1;
    }

    if (mx != 0 || my != 0) {
        var len = point_distance(0, 0, mx, my);

        mx /= len;
        my /= len;

        x += mx * move_speed;
        y += my * move_speed;
    }
}

function player_draw_prompts() {
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    draw_set_color(c_black);

    if (interaction_prompt != "") {
        draw_text(x, y - 36, interaction_prompt);
    }

    if (action_prompt != "") {
        draw_text(x, y - 20, action_prompt);
    }

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}