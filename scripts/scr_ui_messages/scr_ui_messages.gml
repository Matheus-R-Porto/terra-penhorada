function ui_message(_text, _time_seconds = 2) {
    if (!instance_exists(obj_ui)) {
        show_debug_message(_text);
        return;
    }

    obj_ui.message_text = _text;
    obj_ui.message_timer = room_speed * _time_seconds;

    show_debug_message(_text);
}

function ui_update_messages() {
    if (message_timer > 0) {
        message_timer -= 1;
    }
}

function ui_draw_messages() {
    if (message_timer <= 0) {
        return;
    }

    if (message_text == "") {
        return;
    }

    var gui_w = display_get_gui_width();

    var msg_w = 360;
    var msg_h = 32;

    var msg_x = (gui_w - msg_w) / 2;
    var msg_y = 76;

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);

    // Fundo pequeno e discreto
    draw_set_alpha(0.82);
    draw_set_color(c_white);
    draw_rectangle(msg_x, msg_y, msg_x + msg_w, msg_y + msg_h, false);

    draw_set_alpha(1);
    draw_set_color(c_black);
    draw_rectangle(msg_x, msg_y, msg_x + msg_w, msg_y + msg_h, true);

    draw_set_color(c_black);
    draw_text_ext(
        msg_x + (msg_w / 2),
        msg_y + (msg_h / 2),
        message_text,
        16,
        msg_w - 24
    );

    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_black);
}