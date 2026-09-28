function player_init() {
    base_move_speed = PLAYER_MOVE_SPEED;
	move_speed = base_move_speed;

    interaction_prompt = "";
    action_prompt = "";

    energy = 100;
    max_energy = 100;
	
	min_fatigue_energy = -100;
	slow_fatigue_energy = -50;

	fatigue_drain_timer = 0;
	fatigue_drain_frames = 60; // 60 = aproximadamente 1 energia por segundo

	is_fainting = false;
	faint_count = 0;

    carry_weight_max = 50;

    inventory_size = 30;
    inventory_slots = inventory_create(inventory_size);

    hotbar_size = 10;
    hotbar_slots = inventory_create(hotbar_size);
    hotbar_selected = -1;
	
	engineer_mode = false;
	
	ui_cursor_item = "";
	ui_cursor_amount = 0;
	
	sell_panel_selected = 0;
	sell_panel_open = false;
	
	contract_panel_selected = 0;
	contract_panel_open = false;
	
	npc_panel_open = false;
	current_npc = noone;
	npc_panel_selected = 0;
	
	chicken_panel_open = false;
	current_chicken = noone;
	chicken_panel_selected = 0;
	
	seed_shop_open = false;
	seed_shop_selected = 0;
	seed_shop_quantity = 1;
	
	chest_panel_open = false;
	current_chest = noone;
	chest_panel_side = 0; // 0 = inventario, 1 = bau
	chest_inventory_index = 0;
	chest_storage_index = 0;
	
	furnace_panel_open = false;
	current_furnace = noone;	
	
	workbench_panel_open = false;
	current_workbench = noone;
	workbench_selected_recipe = 0;
	
	inventory_panel_open = false;
	inventory_panel_side = 0; // 0 = inventario, 1 = hotbar
	inventory_panel_inventory_index = 0;
	inventory_panel_hotbar_index = 0;
	
	debug_panel_open = false;
	debug_category = 0;
	debug_selected = 0;
	debug_amount = 1;

    show_debug_message("Player iniciado com inventario.");
}