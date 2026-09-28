// =====================
// CONFIGURACAO BASE DA JANELA / GUI
// =====================

display_set_gui_size(GUI_WIDTH, GUI_HEIGHT);

window_set_size(GUI_WIDTH, GUI_HEIGHT);
window_center();

// A application_surface fica no tamanho da janela/GUI.
if (surface_exists(application_surface)) {
    surface_resize(application_surface, GUI_WIDTH, GUI_HEIGHT);
}

// =====================
// CAMERA PRINCIPAL
// =====================

view_enabled = true;
view_visible[0] = true;

game_camera = camera_create_view(
    0,
    0,
    CAMERA_WIDTH,
    CAMERA_HEIGHT,
    0,
    noone,
    -1,
    -1,
    -1,
    -1
);

view_set_camera(0, game_camera);
view_set_xport(0, 0);
view_set_yport(0, 0);
view_set_wport(0, GUI_WIDTH);
view_set_hport(0, GUI_HEIGHT);

show_debug_message("obj_game iniciado.");

menu_init();