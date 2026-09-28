function ui_draw_panel_frame(_panel_x, _panel_y, _panel_w, _panel_h, _title, _help_text) {
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    // Fundo principal
    draw_set_alpha(0.96);
    draw_set_color(make_color_rgb(238, 238, 232));
    draw_rectangle(_panel_x, _panel_y, _panel_x + _panel_w, _panel_y + _panel_h, false);

    draw_set_alpha(1);

    // Borda externa
    draw_set_color(make_color_rgb(25, 25, 25));
    draw_rectangle(_panel_x, _panel_y, _panel_x + _panel_w, _panel_y + _panel_h, true);

    // Barra de titulo
    draw_set_color(make_color_rgb(215, 215, 205));
    draw_rectangle(_panel_x + 1, _panel_y + 1, _panel_x + _panel_w - 1, _panel_y + 62, false);

    draw_set_color(make_color_rgb(25, 25, 25));
    draw_rectangle(_panel_x + 1, _panel_y + 1, _panel_x + _panel_w - 1, _panel_y + 62, true);

    // Titulo
    draw_set_color(c_black);
    draw_text(_panel_x + 20, _panel_y + 14, _title);

    // Ajuda/comandos
    if (_help_text != "") {
        draw_set_color(make_color_rgb(90, 90, 90));
        draw_text(_panel_x + 20, _panel_y + 39, _help_text);
    }

    draw_set_alpha(1);
    draw_set_color(c_black);
}

function ui_count_empty_slots(_slots) {
    return array_length(_slots) - storage_count_filled_slots(_slots);
}

function ui_draw_slot_list(_slots, _draw_x, _draw_y, _selected_visible_index, _max_lines) {
    var visible_index = 0;
    var line_count = 0;
    var found = false;

    for (var i = 0; i < array_length(_slots); i++) {
        var slot = _slots[i];

        if (slot[0] != "" && slot[1] > 0) {
            found = true;

            if (line_count >= _max_lines) {
                draw_text(_draw_x, _draw_y + (line_count * 22), "...");
                return;
            }

            var prefix = "  ";

            if (_selected_visible_index == visible_index) {
                prefix = "> ";
            }

            draw_text(
                _draw_x,
                _draw_y + (line_count * 22),
                prefix + item_get_name(slot[0]) + " x" + string(slot[1])
            );

            visible_index += 1;
            line_count += 1;
        }
    }

    if (!found) {
        draw_text(_draw_x, _draw_y, "Vazio.");
    }
}

function ui_draw_hud() {
    if (!instance_exists(obj_player)) {
        return;
    }

    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_black);

    // =====================
    // TOPO ESQUERDO - TITULO / AJUDA
    // =====================
    draw_text(20, 16, "Terra Penhorada - P2");
    draw_text(20, 36, "WASD mover | E interagir | I inventario | C contratos | Z debug");

    if (obj_player.engineer_mode) {
        draw_set_color(c_blue);
        draw_text(20, 58, "MODO ENGENHEIRO");
        draw_set_color(c_black);
    }

    // =====================
    // TOPO DIREITO - TEMPO / DIVIDA
    // =====================
    if (instance_exists(obj_time)) {
        var info_x = gui_w - 300;
        var info_y = 16;

        var weather_name = "Limpo";

        if (variable_instance_exists(obj_time.id, "weather_today")) {
            if (obj_time.weather_today == "rain") {
                weather_name = "Chuva";
            }
        }

        draw_text(info_x, info_y, "Ano " + string(obj_time.year) + " | Mes " + string(obj_time.month) + " | Dia " + string(obj_time.day_of_month));
        info_y += 20;

        draw_text(info_x, info_y, "Periodo: " + obj_time.phase_name + " | Clima: " + weather_name);
        info_y += 20;

        draw_text(info_x, info_y, "Divida: $" + string(obj_time.debt_total));
        info_y += 20;

        var next_payment = min(obj_time.debt_payment_amount, obj_time.debt_total);
        draw_text(info_x, info_y, "Parcela: $" + string(next_payment));
        info_y += 20;

        if (obj_time.debt_overdue_amount > 0) {
            draw_text(info_x, info_y, "Atrasado: $" + string(obj_time.debt_overdue_amount));
            info_y += 20;
        }

        if (obj_time.debt_is_overdue) {
            draw_set_color(c_red);
            draw_text(info_x, info_y, "Status: inadimplente");
            draw_set_color(c_black);
        }
        else {
            draw_text(info_x, info_y, "Status: em dia");
        }
    }

    // =====================
    // BAIXO ESQUERDO - STATUS DO PLAYER
    // =====================
    var status_x = 20;
    var status_y = gui_h - 175;

    var money = money_get();
    var weight = player_total_weight(obj_player);

    draw_text(status_x, status_y, "Dinheiro: $" + string(money));
    status_y += 20;

    var energy_text = "Energia: " + string(obj_player.energy) + "/" + string(obj_player.max_energy);

    if (obj_player.energy <= -50) {
        energy_text += " (exausto)";
    }
    else if (obj_player.energy <= 0) {
        energy_text += " (sem energia)";
    }

    draw_text(status_x, status_y, energy_text);
    status_y += 20;

    draw_text(status_x, status_y, "Peso: " + string_format(weight, 1, 1) + "/" + string(obj_player.carry_weight_max));
    status_y += 20;

    var selected_item = hotbar_get_selected_item(obj_player);

    if (selected_item != "") {
        draw_text(status_x, status_y, "Selecionado: " + item_get_name(selected_item));
    }
    else {
        draw_text(status_x, status_y, "Selecionado: nenhum");
    }

    status_y += 20;

    if (obj_player.engineer_mode) {
        draw_text(status_x, status_y, "Engenheiro: ON");
    }
    else {
        draw_text(status_x, status_y, "Engenheiro: OFF");
    }

    status_y += 20;

    draw_text(status_x, status_y, "X: " + string(round(obj_player.x)) + " Y: " + string(round(obj_player.y)));

    ui_draw_hotbar();

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_set_color(c_black);
}
	
function ui_draw_option_line(_x, _y, _text, _selected) {
    if (_selected) {
        draw_set_color(c_yellow);
        draw_text(_x, _y, "> " + _text);
        draw_set_color(c_black);
    }
    else {
        draw_text(_x + 18, _y, _text);
    }
}

function ui_draw_hotbar() {
    if (!instance_exists(obj_player)) {
        return;
    }

    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();

    var slot_size = 42;
    var slot_gap = 4;
    var total_w = (slot_size * obj_player.hotbar_size) + (slot_gap * (obj_player.hotbar_size - 1));

    var start_x = (gui_w - total_w) / 2;
    var start_y = gui_h - 60;

    for (var i = 0; i < obj_player.hotbar_size; i++) {
        var sx = start_x + i * (slot_size + slot_gap);
        var sy = start_y;

        if (obj_player.hotbar_selected == i) {
            draw_set_color(c_yellow);
            draw_rectangle(sx - 2, sy - 2, sx + slot_size + 2, sy + slot_size + 2, false);
        }

        draw_set_color(c_white);
        draw_rectangle(sx, sy, sx + slot_size, sy + slot_size, false);

        draw_set_color(c_black);
        draw_rectangle(sx, sy, sx + slot_size, sy + slot_size, true);

        var label = "";

        if (i < 9) {
            label = string(i + 1);
        }
        else {
            label = "0";
        }

        draw_text(sx + 4, sy + 3, label);

        var slot = obj_player.hotbar_slots[i];

        if (slot[0] != "" && slot[1] > 0) {
            draw_text(sx + 4, sy + 18, item_get_name(slot[0]));
            draw_text(sx + 24, sy + 30, string(slot[1]));
        }
    }

    draw_set_color(c_black);
}

function ui_draw_sell_panel() {
    if (!instance_exists(obj_player)) {
        return;
    }

    if (!obj_player.sell_panel_open) {
        return;
    }

    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();

    var panel_w = 620;
    var panel_h = 390;

    var panel_x = (gui_w - panel_w) / 2;
    var panel_y = (gui_h - panel_h) / 2;

    ui_draw_panel_frame(
        panel_x,
        panel_y,
        panel_w,
        panel_h,
        "Caixa de venda",
        "W/S escolhe | Enter vende 1 | Espaco stack | T tudo | Esc fecha"
    );

    draw_set_color(c_black);

    draw_text(panel_x + 30, panel_y + 85, "Itens vendaveis na mochila:");

    var draw_y = panel_y + 120;
    var visible_index = 0;
    var found = false;
    var shown = 0;

    for (var i = 0; i < array_length(obj_player.inventory_slots); i++) {
        var slot = obj_player.inventory_slots[i];
        var item_id = slot[0];
        var amount = slot[1];

        if (item_id != "" && amount > 0 && sell_item_is_sellable(item_id)) {
            found = true;

            if (shown >= 8) {
                draw_text(panel_x + 45, draw_y, "...");
                break;
            }

            var price = item_get_sell_price(item_id);
            var value = price * amount;

            var line =
                item_get_name(item_id) +
                " x" +
                string(amount) +
                " | $" +
                string(price) +
                " cada | stack $" +
                string(value);

            ui_draw_option_line(
                panel_x + 45,
                draw_y,
                line,
                obj_player.sell_panel_selected == visible_index
            );

            draw_y += 24;
            visible_index += 1;
            shown += 1;
        }
    }

    if (!found) {
        draw_text(panel_x + 45, draw_y, "Nenhum item vendavel.");
    }

    var total = sell_panel_get_preview_total(obj_player);

    draw_set_color(make_color_rgb(40, 90, 40));
    draw_text(panel_x + 30, panel_y + panel_h - 62, "Total de tudo: $" + string(total));

    var selected_real = sell_get_selected_real_index(obj_player);

    if (selected_real >= 0) {
        var selected_slot = obj_player.inventory_slots[selected_real];
        var selected_item = selected_slot[0];
        var selected_amount = selected_slot[1];
        var selected_price = item_get_sell_price(selected_item);

        draw_text(
            panel_x + 30,
            panel_y + panel_h - 38,
            "Selecionado: " +
            item_get_name(selected_item) +
            " | 1 unid: $" +
            string(selected_price) +
            " | stack: $" +
            string(selected_price * selected_amount)
        );
    }

    draw_set_color(c_black);
}
	
function ui_draw_seed_shop_panel() {
    if (!instance_exists(obj_player)) {
        return;
    }

    if (!obj_player.seed_shop_open) {
        return;
    }

    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();

    var panel_w = 560;
    var panel_h = 360;

    var panel_x = (gui_w - panel_w) / 2;
    var panel_y = (gui_h - panel_h) / 2;

    ui_draw_panel_frame(
        panel_x,
        panel_y,
        panel_w,
        panel_h,
        "Loja de sementes",
        "W/S escolhe | A/D quantidade | Enter compra | Esc fecha"
    );

    draw_set_color(c_black);

    var money = money_get();

    draw_text(panel_x + 30, panel_y + 82, "Dinheiro: $" + string(money));

    var list_y = panel_y + 125;

    for (var i = 0; i < seed_shop_get_item_count(); i++) {
        var item_id = seed_shop_get_item_id(i);
        var price = item_get_buy_price(item_id);

        var line = item_get_name(item_id) + " - $" + string(price);

        ui_draw_option_line(
            panel_x + 45,
            list_y,
            line,
            obj_player.seed_shop_selected == i
        );

        list_y += 30;
    }

    var selected_item = seed_shop_get_item_id(obj_player.seed_shop_selected);
    var selected_price = item_get_buy_price(selected_item);
    var total_cost = selected_price * obj_player.seed_shop_quantity;

    draw_set_color(make_color_rgb(35, 35, 35));

    draw_text(panel_x + 30, panel_y + 230, "Selecionado: " + item_get_name(selected_item));
    draw_text(panel_x + 30, panel_y + 255, "Quantidade: " + string(obj_player.seed_shop_quantity));
    draw_text(panel_x + 30, panel_y + 280, "Total: $" + string(total_cost));

    if (money < total_cost) {
        draw_set_color(c_red);
        draw_text(panel_x + 30, panel_y + 310, "Dinheiro insuficiente.");
    }
    else {
        draw_set_color(make_color_rgb(40, 90, 40));
        draw_text(panel_x + 30, panel_y + 310, "Compra disponivel.");
    }

    draw_set_color(c_black);
}
	
function ui_draw_chest_panel() {
    if (!instance_exists(obj_player)) {
        return;
    }

    if (!obj_player.chest_panel_open) {
        return;
    }

    if (obj_player.current_chest == noone || !instance_exists(obj_player.current_chest)) {
        return;
    }

    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();

    var panel_w = 920;
    var panel_h = 520;

    var panel_x = (gui_w - panel_w) / 2;
    var panel_y = (gui_h - panel_h) / 2;

    ui_draw_panel_frame(
        panel_x,
        panel_y,
        panel_w,
        panel_h,
        "Bau",
        "Tab alterna | W/S escolhe item | Enter move | Esc fecha"
    );

    draw_set_color(c_black);

    var current_weight = player_total_weight(obj_player);
    var max_weight = obj_player.carry_weight_max;

    draw_text(
        panel_x + 30,
        panel_y + 70,
        "Peso carregado: " + string(current_weight) + " / " + string(max_weight)
    );

    var slot_w = 72;
    var slot_h = 38;
    var gap = 8;

    var inv_x = panel_x + 30;
    var chest_x = panel_x + 500;
    var grid_y = panel_y + 125;

    draw_text(inv_x, grid_y - 28, "Mochila");
    draw_text(chest_x, grid_y - 28, "Bau");

    var inv_selected_real = -1;
    var chest_selected_real = -1;

    var side = 0;

    if (variable_instance_exists(obj_player.id, "chest_panel_side")) {
        side = obj_player.chest_panel_side;
    }

    if (side == 0) {
        inv_selected_real = storage_find_nth_filled_slot(
            obj_player.inventory_slots,
            obj_player.chest_inventory_index
        );
    }
    else {
        chest_selected_real = storage_find_nth_filled_slot(
            obj_player.current_chest.storage_slots,
            obj_player.chest_storage_index
        );
    }

    // Mochila: 5 colunas
    ui_draw_slot_grid(
        obj_player.inventory_slots,
        inv_x,
        grid_y,
        5,
        slot_w,
        slot_h,
        gap,
        inv_selected_real
    );

    // Bau: 5 colunas
    ui_draw_slot_grid(
        obj_player.current_chest.storage_slots,
        chest_x,
        grid_y,
        5,
        slot_w,
        slot_h,
        gap,
        chest_selected_real
    );

    var footer_y = panel_y + panel_h - 72;

    draw_set_color(c_black);

    if (side == 0) {
        draw_text(panel_x + 30, footer_y, "Selecionando: Mochila");
        draw_text(panel_x + 30, footer_y + 24, "Enter move 1 item da mochila para o bau.");
    }
    else {
        draw_text(panel_x + 30, footer_y, "Selecionando: Bau");
        draw_text(panel_x + 30, footer_y + 24, "Enter move 1 item do bau para a mochila.");
    }
}

function ui_draw_furnace_panel() {
    if (!instance_exists(obj_player)) {
        return;
    }

    if (!obj_player.furnace_panel_open) {
        return;
    }

    if (obj_player.current_furnace == noone || !instance_exists(obj_player.current_furnace)) {
        return;
    }

    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();

    var panel_w = 560;
    var panel_h = 320;

    var panel_x = (gui_w - panel_w) / 2;
    var panel_y = (gui_h - panel_h) / 2;

    ui_draw_panel_frame(
        panel_x,
        panel_y,
        panel_w,
        panel_h,
        "Fornalha simples",
        "Enter funde | Esc fecha"
    );

    var ore_count = player_count_item_anywhere(obj_player, "ore");
    var coal_count = player_count_item_anywhere(obj_player, "coal");
    var bar_count = player_count_item_anywhere(obj_player, "bar");

    draw_text(panel_x + 30, panel_y + 85, "Receita atual:");
    draw_text(panel_x + 55, panel_y + 115, "2 Minerios + 1 Carvao -> 1 Barra");

    draw_text(panel_x + 30, panel_y + 160, "Recursos carregados:");
    draw_text(panel_x + 55, panel_y + 190, "Minerio: " + string(ore_count));
    draw_text(panel_x + 55, panel_y + 215, "Carvao: " + string(coal_count));
    draw_text(panel_x + 55, panel_y + 240, "Barras: " + string(bar_count));

    if (ore_count >= 2 && coal_count >= 1) {
        draw_set_color(c_green);
        draw_text(panel_x + 30, panel_y + 275, "Pronto para fundir 1 barra.");
        draw_set_color(c_black);
    }
    else {
        draw_set_color(c_red);

        if (ore_count < 2 && coal_count < 1) {
            draw_text(panel_x + 30, panel_y + 275, "Minerio e carvao insuficientes.");
        }
        else if (ore_count < 2) {
            draw_text(panel_x + 30, panel_y + 275, "Minerio insuficiente.");
        }
        else {
            draw_text(panel_x + 30, panel_y + 275, "Carvao insuficiente.");
        }

        draw_set_color(c_black);
    }
}

function ui_draw_workbench_panel() {
    if (!instance_exists(obj_player)) {
        return;
    }

    if (!obj_player.workbench_panel_open) {
        return;
    }

    if (obj_player.current_workbench == noone || !instance_exists(obj_player.current_workbench)) {
        return;
    }

    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();

    var panel_w = 600;
    var panel_h = 380;

    var panel_x = (gui_w - panel_w) / 2;
    var panel_y = (gui_h - panel_h) / 2;

    ui_draw_panel_frame(
        panel_x,
        panel_y,
        panel_w,
        panel_h,
        "Bancada simples",
        "W/S escolhe | Enter fabrica | Esc fecha"
    );

    draw_set_color(c_black);

    draw_text(panel_x + 30, panel_y + 85, "Receitas:");

    var list_y = panel_y + 120;

    for (var i = 0; i < craft_get_recipe_count(); i++) {
        ui_draw_option_line(
            panel_x + 45,
            list_y,
            craft_get_recipe_name(i),
            obj_player.workbench_selected_recipe == i
        );

        list_y += 30;
    }

    var selected = obj_player.workbench_selected_recipe;
    var output_item = craft_get_recipe_output_item(selected);
    var output_amount = craft_get_recipe_output_amount(selected);

    draw_text(panel_x + 30, panel_y + 230, "Receita:");
    draw_text(panel_x + 55, panel_y + 255, craft_get_recipe_description(selected));

    draw_text(
        panel_x + 30,
        panel_y + 295,
        "Resultado: " + item_get_name(output_item) + " x" + string(output_amount)
    );

    draw_text(
        panel_x + 30,
        panel_y + 325,
        "Barras: " + string(player_count_item_anywhere(obj_player, "bar")) +
        " | Milho: " + string(player_count_item_anywhere(obj_player, "corn"))
    );
}

function ui_draw_item_slot(_x, _y, _w, _h, _slot, _selected) {
    var border_col = make_color_rgb(70, 70, 70);
    var fill_col = make_color_rgb(215, 215, 215);
    var text_col = c_black;

    if (_selected) {
        border_col = c_yellow;
        fill_col = make_color_rgb(235, 235, 180);
    }

    // Borda externa
    draw_set_color(border_col);
    draw_rectangle(_x, _y, _x + _w, _y + _h, true);

    // Fundo interno claro
    draw_set_color(fill_col);
    draw_rectangle(_x + 1, _y + 1, _x + _w - 1, _y + _h - 1, false);

    var item_id = _slot[0];
    var amount = _slot[1];

    if (item_id != "" && amount > 0) {
        draw_set_color(text_col);

        var item_name = item_get_name(item_id);
        var short_name = string_copy(item_name, 1, 8);

        draw_text(_x + 4, _y + 6, short_name);
        draw_text(_x + 4, _y + _h - 18, "x" + string(amount));
    }

    draw_set_color(c_black);
}

function ui_draw_slot_grid(_slots, _x, _y, _cols, _slot_w, _slot_h, _gap, _selected_real_index) {
    for (var i = 0; i < array_length(_slots); i++) {
        var col = i mod _cols;
        var row = floor(i / _cols);

        var sx = _x + col * (_slot_w + _gap);
        var sy = _y + row * (_slot_h + _gap);

        var selected = (i == _selected_real_index);

        ui_draw_item_slot(sx, sy, _slot_w, _slot_h, _slots[i], selected);
    }
}

function ui_draw_inventory_panel() {
    if (!instance_exists(obj_player)) {
        return;
    }

    if (!obj_player.inventory_panel_open) {
        return;
    }

    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();

    var panel_w = 560;
    var panel_h = 610;

    var panel_x = (gui_w - panel_w) / 2;
    var panel_y = (gui_h - panel_h) / 2;

    ui_draw_panel_frame(
        panel_x,
        panel_y,
        panel_w,
        panel_h,
        "Inventario",
        "Tab alterna | W/S escolhe item | Enter move | Esc fecha"
    );

    var current_weight = player_total_weight(obj_player);
    var max_weight = obj_player.carry_weight_max;

    draw_set_color(c_black);

    draw_text(
        panel_x + 30,
        panel_y + 70,
        "Peso carregado: " + string(current_weight) + " / " + string(max_weight)
    );

    var slot_w = 76;
    var slot_h = 38;
    var gap = 8;

    var grid_x = panel_x + 30;
    var inventory_y = panel_y + 120;

    draw_text(grid_x, inventory_y - 28, "Mochila");

    var inv_selected_real = -1;
    var hotbar_selected_real = -1;

    if (obj_player.inventory_panel_side == 0) {
        inv_selected_real = storage_find_nth_filled_slot(
            obj_player.inventory_slots,
            obj_player.inventory_panel_inventory_index
        );
    }
    else {
        hotbar_selected_real = storage_find_nth_filled_slot(
            obj_player.hotbar_slots,
            obj_player.inventory_panel_hotbar_index
        );
    }

    // Mochila: 5 colunas x 6 linhas
    ui_draw_slot_grid(
        obj_player.inventory_slots,
        grid_x,
        inventory_y,
        5,
        slot_w,
        slot_h,
        gap,
        inv_selected_real
    );

    var inventory_rows = 6;
    var inventory_grid_h = inventory_rows * slot_h + (inventory_rows - 1) * gap;

    var hotbar_y = inventory_y + inventory_grid_h + 48;

    draw_set_color(c_black);
    draw_text(grid_x, hotbar_y - 28, "Hotbar");

    // Hotbar: 5 colunas x 2 linhas
    ui_draw_slot_grid(
        obj_player.hotbar_slots,
        grid_x,
        hotbar_y,
        5,
        slot_w,
        slot_h,
        gap,
        hotbar_selected_real
    );

    var footer_y = panel_y + panel_h - 70;

    draw_set_color(c_black);

    if (obj_player.inventory_panel_side == 0) {
        draw_text(grid_x, footer_y, "Selecionando: Mochila");
    }
    else {
        draw_text(grid_x, footer_y, "Selecionando: Hotbar");
    }

    draw_text(
        grid_x,
        footer_y + 24,
        "Enter move 1 item entre Mochila e Hotbar."
    );
}

function ui_draw_debug_panel() {
    if (!instance_exists(obj_player)) {
        return;
    }

    if (!obj_player.debug_panel_open) {
        return;
    }

    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();

    var panel_w = 780;
    var panel_h = 500;

    var panel_x = (gui_w - panel_w) / 2;
    var panel_y = (gui_h - panel_h) / 2;

    draw_set_color(c_white);
    draw_rectangle(panel_x, panel_y, panel_x + panel_w, panel_y + panel_h, false);

    draw_set_color(c_black);
    draw_rectangle(panel_x, panel_y, panel_x + panel_w, panel_y + panel_h, true);

    draw_text(panel_x + 20, panel_y + 20, "Painel de Debug");
    draw_text(panel_x + 20, panel_y + 45, "Q/E categoria | W/S opcao | A/D quantidade | Shift+A/D +/-10 | Enter executa | Esc fecha");

    // Categorias
    var cat_y = panel_y + 85;

    draw_text(panel_x + 20, cat_y, "Categoria:");

    for (var c = 0; c < debug_get_category_count(); c++) {
        var cat_text = debug_get_category_name(c);

        if (obj_player.debug_category == c) {
            cat_text = "> " + cat_text;
        }
        else {
            cat_text = "  " + cat_text;
        }

        draw_text(panel_x + 40, cat_y + 25 + (c * 22), cat_text);
    }

    // Opções
    var option_x = panel_x + 250;
    var option_y = panel_y + 85;

    draw_text(option_x, option_y, "Opcoes:");

    var option_count = debug_get_option_count(obj_player.debug_category);

    for (var i = 0; i < option_count; i++) {
        var option_text = debug_get_option_name(obj_player.debug_category, i);

        if (obj_player.debug_selected == i) {
            option_text = "> " + option_text;
        }
        else {
            option_text = "  " + option_text;
        }

        draw_text(option_x + 20, option_y + 25 + (i * 22), option_text);
    }

    // Detalhes
    var detail_x = panel_x + 20;
    var detail_y = panel_y + 405;

    draw_text(detail_x, detail_y, "Selecionado: " + debug_get_option_name(obj_player.debug_category, obj_player.debug_selected));

    if (debug_option_uses_amount(obj_player.debug_category, obj_player.debug_selected)) {
        draw_text(detail_x, detail_y + 25, "Quantidade: " + string(obj_player.debug_amount));
    }
    else {
        draw_text(detail_x, detail_y + 25, "Quantidade: nao usada nesta opcao");
    }

    // Estado rápido
    if (instance_exists(obj_time)) {
        draw_text(
            panel_x + 470,
            detail_y,
            "Dia " + string(obj_time.day) +
            " | Mes " + string(obj_time.month) +
            " | " + obj_time.phase_name
        );

        var weather_name = "Limpo";

        if (variable_instance_exists(obj_time.id, "weather_today")) {
            if (obj_time.weather_today == "rain") {
                weather_name = "Chuva";
            }
        }

        draw_text(panel_x + 470, detail_y + 25, "Clima: " + weather_name);
        draw_text(panel_x + 470, detail_y + 50, "Divida: $" + string(obj_time.debt_total) + " | Atraso: $" + string(obj_time.debt_overdue_amount));
		draw_text(panel_x + 470, detail_y + 75, "Dinheiro: $" + string(money_get()));
   }
}
	
function ui_draw_contract_panel() {
    if (!instance_exists(obj_player)) {
        return;
    }

    if (!obj_player.contract_panel_open) {
        return;
    }

    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();

    var panel_w = 680;
    var panel_h = 430;

    var panel_x = (gui_w - panel_w) / 2;
    var panel_y = (gui_h - panel_h) / 2;

    ui_draw_panel_frame(
        panel_x,
        panel_y,
        panel_w,
        panel_h,
        "Contratos",
        "W/S escolhe | C/Esc fecha"
    );

    draw_set_color(c_black);

    var active_count = contract_panel_count_active_contracts();

    if (active_count <= 0) {
        draw_text(panel_x + 30, panel_y + 95, "Nenhum contrato ativo.");
        draw_text(panel_x + 30, panel_y + 125, "Fale com NPCs da cidade para aceitar contratos.");
        draw_text(panel_x + 30, panel_y + 155, "Contratos aceitos aparecerao aqui com prazo e detalhes.");
        return;
    }

    draw_text(panel_x + 30, panel_y + 82, "Contratos ativos:");

    var list_y = panel_y + 120;

    for (var i = 0; i < active_count; i++) {
        var c_list = contract_panel_get_nth_active_contract(i);

        if (!is_undefined(c_list)) {
            var line =
                c_list.owner +
                " - " +
                string(c_list.required_amount) +
                " " +
                item_get_name(c_list.required_item) +
                " - " +
                string(c_list.days_left) +
                " dia(s)";

            ui_draw_option_line(
                panel_x + 45,
                list_y,
                line,
                obj_player.contract_panel_selected == i
            );

            list_y += 30;
        }
    }

    obj_player.contract_panel_selected = clamp(obj_player.contract_panel_selected, 0, active_count - 1);

    var c = contract_panel_get_nth_active_contract(obj_player.contract_panel_selected);

    if (is_undefined(c)) {
        return;
    }

    var reward = contract_get_reward(c);
    var item_name = item_get_name(c.required_item);
    var player_amount = contract_count_player_item(obj_player, c.required_item);

    draw_set_color(c_black);

    draw_text(panel_x + 30, panel_y + 245, "Detalhes:");
    draw_text(panel_x + 55, panel_y + 275, "Solicitante: " + c.owner);
    draw_text(panel_x + 55, panel_y + 300, "Tipo: " + c.type);

    draw_text(
        panel_x + 55,
        panel_y + 325,
        "Pedido: " +
        string(c.required_amount) +
        " " +
        item_name +
        " | Voce tem: " +
        string(player_amount)
    );

    draw_text(panel_x + 55, panel_y + 350, "Prazo: " + string(c.days_left) + " dia(s)");
    draw_text(panel_x + 55, panel_y + 375, "Recompensa: $" + string(reward) + " | Rep +2");

    if (player_amount >= c.required_amount) {
        draw_set_color(make_color_rgb(40, 90, 40));
        draw_text(panel_x + 55, panel_y + 400, "Itens suficientes. Entregue falando com " + c.owner + ".");
    }
    else {
        var missing = c.required_amount - player_amount;

        draw_set_color(c_red);
        draw_text(
            panel_x + 55,
            panel_y + 400,
            "Faltam " + string(missing) + " " + item_name + "."
        );
    }

    draw_set_color(c_black);
}
	
function ui_draw_npc_panel() {
    if (!instance_exists(obj_player)) {
        return;
    }

    if (!obj_player.npc_panel_open) {
        return;
    }

    if (obj_player.current_npc == noone || !instance_exists(obj_player.current_npc)) {
        return;
    }

    var npc_name = npc_get_name(obj_player.current_npc);

    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();

    var panel_w = 520;
    var panel_h = 260;

    var panel_x = (gui_w - panel_w) / 2;
    var panel_y = (gui_h - panel_h) / 2;

    ui_draw_panel_frame(
        panel_x,
        panel_y,
        panel_w,
        panel_h,
        npc_name,
        "W/S escolhe | Enter confirma | Esc fecha"
    );

    draw_text(panel_x + 30, panel_y + 80, reputation_get_label(npc_name));

    var option_y = panel_y + 125;

    var options = [
        "Conversar",
        "Contrato",
        "Fechar"
    ];

    for (var i = 0; i < array_length(options); i++) {
        if (obj_player.npc_panel_selected == i) {
            draw_set_color(c_yellow);
            draw_text(panel_x + 45, option_y + i * 32, "> " + options[i]);
            draw_set_color(c_black);
        }
        else {
            draw_text(panel_x + 60, option_y + i * 32, options[i]);
        }
    }
}

function ui_draw_chicken_panel() {
    if (!instance_exists(obj_player)) {
        return;
    }

    if (!obj_player.chicken_panel_open) {
        return;
    }

    if (obj_player.current_chicken == noone || !instance_exists(obj_player.current_chicken)) {
        return;
    }

    var chicken = obj_player.current_chicken;

    if (!variable_instance_exists(chicken.id, "fed")) {
        chicken.fed = false;
    }

    if (!variable_instance_exists(chicken.id, "days_without_feed")) {
        chicken.days_without_feed = 0;
    }

    if (!variable_instance_exists(chicken.id, "hungry_limit")) {
        chicken.hungry_limit = 2;
    }

    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();

    var panel_w = 520;
    var panel_h = 300;

    var panel_x = (gui_w - panel_w) / 2;
    var panel_y = (gui_h - panel_h) / 2;

    ui_draw_panel_frame(
        panel_x,
        panel_y,
        panel_w,
        panel_h,
        "Galinha",
        "W/S escolhe | Enter confirma | Esc fecha"
    );

    draw_text(panel_x + 30, panel_y + 80, "Estado: " + chicken_get_state_text(chicken));
    draw_text(panel_x + 30, panel_y + 110, "Alimentada hoje: " + chicken_get_fed_text(chicken));
    draw_text(panel_x + 30, panel_y + 140, "Dias sem comida: " + string(chicken.days_without_feed));
    draw_text(panel_x + 30, panel_y + 170, "Producao: se alimentada, produz ovo ao dormir.");

    var options = [
        "Alimentar",
        "Fechar"
    ];

    var option_y = panel_y + 220;

    for (var i = 0; i < array_length(options); i++) {
        if (obj_player.chicken_panel_selected == i) {
            draw_set_color(c_yellow);
            draw_text(panel_x + 45, option_y + i * 32, "> " + options[i]);
            draw_set_color(c_black);
        }
        else {
            draw_text(panel_x + 60, option_y + i * 32, options[i]);
        }
    }
}