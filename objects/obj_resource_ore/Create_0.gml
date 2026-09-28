resource_id = "ore";
area_id = "cave_01";

mined = false;
respawn_days_left = 0;
respawn_days_required = 3;

if (!variable_instance_exists(id, "drop_item")) {
    drop_item = "ore";
}

if (!variable_instance_exists(id, "drop_amount")) {
    drop_amount = 1;
}

if (!variable_instance_exists(id, "energy_cost")) {
    energy_cost = 5;
}

ore_update_sprite(id);

depth = 5;

ore_update_sprite(id);