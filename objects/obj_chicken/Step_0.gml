// =====================
// MOVIMENTO SIMPLES DA GALINHA
// =====================

// Protecao para instancias antigas
if (!variable_instance_exists(id, "home_x")) home_x = x;
if (!variable_instance_exists(id, "home_y")) home_y = y;

if (!variable_instance_exists(id, "move_target_x")) move_target_x = x;
if (!variable_instance_exists(id, "move_target_y")) move_target_y = y;

if (!variable_instance_exists(id, "move_timer")) move_timer = irandom_range(60, 180);
if (!variable_instance_exists(id, "move_speed")) move_speed = 0.45;
if (!variable_instance_exists(id, "move_radius")) move_radius = 48;
if (!variable_instance_exists(id, "is_moving")) is_moving = false;

// Se esta parada, conta tempo ate escolher novo destino
if (!is_moving) {
    move_timer -= 1;

    if (move_timer <= 0) {
        move_target_x = home_x + irandom_range(-move_radius, move_radius);
        move_target_y = home_y + irandom_range(-move_radius, move_radius);

        is_moving = true;
    }
}
else {
    var dist = point_distance(x, y, move_target_x, move_target_y);

    if (dist <= move_speed) {
        x = move_target_x;
        y = move_target_y;

        is_moving = false;
        move_timer = irandom_range(90, 240);
    }
    else {
        var dir = point_direction(x, y, move_target_x, move_target_y);

        x += lengthdir_x(move_speed, dir);
        y += lengthdir_y(move_speed, dir);
    }
}

// Segurança: se saiu muito da area, volta para perto de casa
if (point_distance(x, y, home_x, home_y) > move_radius + 32) {
    x = home_x;
    y = home_y;
    is_moving = false;
    move_timer = irandom_range(90, 180);
}