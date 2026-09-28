if (menu_is_blocking_gameplay()) {
    menu_draw();
    ui_draw_messages();
    return;
}

ui_draw_hud();
ui_draw_inventory_panel();
ui_draw_chest_panel();
ui_draw_furnace_panel();
ui_draw_npc_panel();
ui_draw_workbench_panel();
ui_draw_seed_shop_panel();
ui_draw_sell_panel();
ui_draw_contract_panel();
ui_draw_chicken_panel();
ui_draw_debug_panel();
ui_draw_mouse_held_item();
ui_draw_messages();