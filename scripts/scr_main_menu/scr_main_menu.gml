function menu_init() {
    global.game_state = "menu";

    global.menu_selected = 0;
    global.menu_option_count = 4;

    global.slot_selected = 0;
    global.slot_option_count = 3;
    global.slot_mode = "continue";

    global.current_save_slot = 1;

    global.controls_from_menu = true;

    global.intro_page = 0;
    global.intro_page_count = 4;

    show_debug_message("Menu inicial iniciado.");
}

function menu_is_blocking_gameplay() {
    if (!variable_global_exists("game_state")) {
        return false;
    }

    return (
        global.game_state == "menu"
        || global.game_state == "slot_select"
        || global.game_state == "intro"
        || global.game_state == "controls"
    );
}

function menu_close_player_panels() {
    if (!instance_exists(obj_player)) {
        return;
    }

    obj_player.inventory_panel_open = false;
    obj_player.chest_panel_open = false;
    obj_player.furnace_panel_open = false;
    obj_player.workbench_panel_open = false;
    obj_player.seed_shop_open = false;
    obj_player.sell_panel_open = false;
    obj_player.debug_panel_open = false;
    obj_player.contract_panel_open = false;

    obj_player.interaction_prompt = "";
    obj_player.action_prompt = "";
}

function menu_start_new_game() {
    menu_close_player_panels();

    global.slot_mode = "new";
    global.slot_selected = 0;
    global.game_state = "slot_select";

    show_debug_message("Novo jogo selecionado. Escolhendo slot.");
}

function menu_continue_game() {
    menu_close_player_panels();

    global.slot_mode = "continue";
    global.slot_selected = 0;
    global.game_state = "slot_select";

    show_debug_message("Continuar jogo selecionado. Escolhendo slot.");
}

function menu_select_save_slot() {
    var selected_slot = global.slot_selected + 1;

    save_set_current_slot(selected_slot);

    if (global.slot_mode == "new") {
		money_set(100);
		
        global.intro_page = 0;
        global.game_state = "intro";

        ui_message("Novo jogo no slot " + string(selected_slot) + ".", 2);
        show_debug_message("Novo jogo iniciado no slot " + string(selected_slot));

        return;
    }

    if (global.slot_mode == "continue") {
        if (load_game()) {
            global.game_state = "playing";

            ui_message("Slot " + string(selected_slot) + " carregado.", 2);
            show_debug_message("Slot " + string(selected_slot) + " carregado pelo menu.");
        }
        else {
            global.game_state = "slot_select";

            ui_message("Slot " + string(selected_slot) + " vazio.", 2);
            show_debug_message("Slot " + string(selected_slot) + " vazio.");
        }

        return;
    }
}

function menu_update_slot_select() {
    if (keyboard_check_pressed(vk_escape)) {
        global.game_state = "menu";
        return;
    }

    if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))) {
        global.slot_selected += 1;

        if (global.slot_selected >= global.slot_option_count) {
            global.slot_selected = 0;
        }
    }

    if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"))) {
        global.slot_selected -= 1;

        if (global.slot_selected < 0) {
            global.slot_selected = global.slot_option_count - 1;
        }
    }

    if (keyboard_check_pressed(vk_enter)
    || keyboard_check_pressed(vk_space)
    || keyboard_check_pressed(ord("E"))) {
        menu_select_save_slot();
    }
}

function menu_select_option() {
    if (global.menu_selected == 0) {
        menu_start_new_game();
        return;
    }

    if (global.menu_selected == 1) {
        menu_continue_game();
        return;
    }

    if (global.menu_selected == 2) {
        global.game_state = "controls";
        global.controls_from_menu = true;
        return;
    }

    if (global.menu_selected == 3) {
        game_end();
        return;
    }
}

function menu_update_main() {
    if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))) {
        global.menu_selected += 1;

        if (global.menu_selected >= global.menu_option_count) {
            global.menu_selected = 0;
        }
    }

    if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"))) {
        global.menu_selected -= 1;

        if (global.menu_selected < 0) {
            global.menu_selected = global.menu_option_count - 1;
        }
    }

    if (keyboard_check_pressed(vk_enter)
    || keyboard_check_pressed(vk_space)
    || keyboard_check_pressed(ord("E"))) {
        menu_select_option();
    }
}

function menu_update_intro() {
    if (keyboard_check_pressed(vk_escape)) {
        global.game_state = "playing";
        ui_message("Intro pulada.", 1);
        return;
    }

    if (keyboard_check_pressed(vk_enter)
    || keyboard_check_pressed(vk_space)
    || keyboard_check_pressed(ord("E"))) {
        global.intro_page += 1;

        if (global.intro_page >= global.intro_page_count) {
            global.game_state = "playing";
            ui_message("Novo jogo iniciado.", 2);
        }
    }
}

function menu_update_controls() {
    if (keyboard_check_pressed(vk_escape)
    || keyboard_check_pressed(vk_enter)
    || keyboard_check_pressed(vk_space)
    || keyboard_check_pressed(ord("E"))) {
        global.game_state = "menu";
    }
}

function menu_update() {
    if (!variable_global_exists("game_state")) {
        menu_init();
    }

    if (global.game_state == "menu") {
        menu_update_main();
        return;
    }
	
	if (global.game_state == "slot_select") {
	    menu_update_slot_select();
	    return;
	}

    if (global.game_state == "intro") {
        menu_update_intro();
        return;
    }

    if (global.game_state == "controls") {
        menu_update_controls();
        return;
    }
}

function menu_draw_background() {
    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();

    draw_set_alpha(1);
    draw_set_color(make_color_rgb(18, 20, 24));
    draw_rectangle(0, 0, gui_w, gui_h, false);

    draw_set_color(make_color_rgb(35, 42, 48));
    draw_rectangle(70, 70, gui_w - 70, gui_h - 70, false);

    draw_set_color(c_white);
}

function menu_draw_main() {
    menu_draw_background();

    var gui_w = display_get_gui_width();
    var start_x = gui_w / 2;
    var start_y = 225;

    draw_set_halign(fa_center);
    draw_set_valign(fa_top);

    draw_set_color(c_white);
    draw_text(start_x, 100, "TERRA PENHORADA");
    draw_text(start_x, 135, "Prototipo 2");

    var options = [
        "Novo jogo",
        "Continuar jogo",
        "Controles",
        "Sair"
    ];

    for (var i = 0; i < array_length(options); i++) {
        var label = options[i];

        if (i == global.menu_selected) {
            draw_set_color(c_yellow);
            draw_text(start_x, start_y + (i * 42), "> " + label + " <");
        }
        else {
            draw_set_color(c_white);
            draw_text(start_x, start_y + (i * 42), label);
        }
    }

    draw_set_color(c_ltgray);
    draw_text(start_x, 620, "W/S ou setas para navegar | Enter/Espaco/E para confirmar");

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}

function menu_get_intro_text(_page) {
    if (_page == 0) {
        return "Seu pai desapareceu deixando uma terra fertil, uma casa cansada e uma divida grande demais para caber numa conversa educada.";
    }

    if (_page == 1) {
        return "A cidade conhece seu sobrenome. Alguns sentem pena. Outros fazem contas.";
    }

    if (_page == 2) {
        return "Plante, venda, aceite contratos, minera, improvise maquinas e pague o que dizem que voce deve.";
    }

    if (_page == 3) {
        return "A pergunta nao e apenas se voce vai quitar a divida. A pergunta e quem voce vai virar para conseguir.";
    }

    return "";
}

function menu_draw_intro() {
    menu_draw_background();

    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();

    var text_w = 680;
    var text_x = (gui_w - text_w) / 2;
    var text_y = 230;

    draw_set_valign(fa_top);

    // Título
    draw_set_halign(fa_center);
    draw_set_color(c_white);
    draw_text(gui_w / 2, 115, "INTRODUCAO");

    // Texto centralizado como bloco
    var intro_text = menu_get_intro_text(global.intro_page);

    draw_set_halign(fa_left);
    draw_set_color(c_ltgray);
    draw_text_ext(text_x, text_y, intro_text, 30, text_w);

    // Página
    draw_set_halign(fa_center);
    draw_set_color(c_white);

    draw_text(
        gui_w / 2,
        gui_h - 130,
        "Pagina " + string(global.intro_page + 1) + "/" + string(global.intro_page_count)
    );

    draw_set_color(c_ltgray);
    draw_text(gui_w / 2, gui_h - 88, "Enter / Espaco / E avanca | Esc pula");

    // Reset
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}

function menu_draw_controls() {
    menu_draw_background();

    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();

    var panel_w = 620;
    var panel_x = (gui_w - panel_w) / 2;

    var title_y = 115;
    var list_start_y = 185;
    var row_h = 34;

    var key_x = panel_x + 120;
    var desc_x = panel_x + 310;

    draw_set_valign(fa_top);

    // Título
    draw_set_halign(fa_center);
    draw_set_color(c_white);
    draw_text(gui_w / 2, title_y, "CONTROLES");

    // Lista
    draw_set_halign(fa_left);
    draw_set_color(c_ltgray);

    var row_y = list_start_y;

    draw_text(key_x, row_y, "WASD");
    draw_text(desc_x, row_y, "Mover");
    row_y += row_h;

    draw_text(key_x, row_y, "E");
    draw_text(desc_x, row_y, "Interagir");
    row_y += row_h;

    draw_text(key_x, row_y, "R");
    draw_text(desc_x, row_y, "Regar plantacao");
    row_y += row_h;

    draw_text(key_x, row_y, "X");
    draw_text(desc_x, row_y, "Minerar");
    row_y += row_h;

    draw_text(key_x, row_y, "I");
    draw_text(desc_x, row_y, "Inventario");
    row_y += row_h;

    draw_text(key_x, row_y, "C");
    draw_text(desc_x, row_y, "Contratos");
    row_y += row_h;

    draw_text(key_x, row_y, "Z");
    draw_text(desc_x, row_y, "Debug");
    row_y += row_h;

    draw_text(key_x, row_y, "V");
    draw_text(desc_x, row_y, "Modo engenheiro");
    row_y += row_h;

    draw_text(key_x, row_y, "F5 / F9");
    draw_text(desc_x, row_y, "Salvar / carregar slot atual");
    row_y += row_h;

    draw_text(key_x, row_y, "1 a 0");
    draw_text(desc_x, row_y, "Selecionar hotbar");

    // Rodapé
    draw_set_halign(fa_center);
    draw_set_color(c_white);
    draw_text(gui_w / 2, gui_h - 82, "Enter / Espaco / E / Esc para voltar");

    // Reset
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}

function menu_draw_slot_select() {
    menu_draw_background();

    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();

    draw_set_halign(fa_center);
    draw_set_valign(fa_top);

    draw_set_color(c_white);

    var title = "ESCOLHA UM SLOT";

    if (global.slot_mode == "new") {
        title = "NOVO JOGO - ESCOLHA UM SLOT";
    }
    else if (global.slot_mode == "continue") {
        title = "CONTINUAR - ESCOLHA UM SLOT";
    }

    draw_text(gui_w / 2, 100, title);

    var start_y = 210;

    for (var i = 0; i < 3; i++) {
        var slot_number = i + 1;

        var status = "Vazio";

        if (save_slot_exists(slot_number)) {
            status = "Com save";
        }

        var label = "Slot " + string(slot_number) + " - " + status;

        if (i == global.slot_selected) {
            draw_set_color(c_yellow);
            draw_text(gui_w / 2, start_y + (i * 48), "> " + label + " <");
        }
        else {
            draw_set_color(c_white);
            draw_text(gui_w / 2, start_y + (i * 48), label);
        }
    }

    draw_set_color(c_ltgray);

    if (global.slot_mode == "new") {
        draw_text(gui_w / 2, gui_h - 125, "Aviso: ao salvar, este slot sera sobrescrito.");
    }

    draw_text(gui_w / 2, gui_h - 84, "W/S ou setas navega | Enter/Espaco/E confirma | Esc volta");

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_white);
}

function menu_draw() {
    if (!variable_global_exists("game_state")) {
        menu_init();
    }

    if (global.game_state == "menu") {
        menu_draw_main();
        return;
    }
	
	if (global.game_state == "slot_select") {
	    menu_draw_slot_select();
	    return;
	}

    if (global.game_state == "intro") {
        menu_draw_intro();
        return;
    }

    if (global.game_state == "controls") {
        menu_draw_controls();
        return;
    }
}