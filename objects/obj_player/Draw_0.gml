// =====================
// OVERLAY DE PERIODO DO DIA
// =====================

day_overlay_draw();

// =====================
// MODO ENGENHEIRO
// =====================

engineer_draw_world_overlay();

draw_self();

// =====================
// PREVIEW DE POSICIONAMENTO
// =====================

if (hotbar_has_selected_item(id)) {
    var selected_item = hotbar_get_selected_item(id);

    if (item_is_placeable(selected_item)) {
        var place_obj = item_get_place_object(selected_item);

        if (place_obj != noone) {
            var px = machine_get_place_x();
            var py = machine_get_place_y();

            var can_place = machine_can_place_at(id, selected_item, px, py, true);

            draw_set_alpha(0.5);

            if (can_place) {
                draw_set_color(c_white);
            }
            else {
                draw_set_color(c_red);
            }

            draw_sprite(object_get_sprite(place_obj), 0, px, py);

            draw_set_alpha(1);
            draw_set_color(c_black);
        }
    }
}

player_draw_prompts();

draw_set_alpha(1);
draw_set_color(c_black);