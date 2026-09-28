// =====================
// CAMERA SEGUINDO O PLAYER
// =====================

if (instance_exists(obj_player)) {
    var cam_x = obj_player.x - (CAMERA_WIDTH / 2);
    var cam_y = obj_player.y - (CAMERA_HEIGHT / 2);

    cam_x = clamp(cam_x, 0, room_width - CAMERA_WIDTH);
    cam_y = clamp(cam_y, 0, room_height - CAMERA_HEIGHT);

    camera_set_view_pos(game_camera, cam_x, cam_y);
}