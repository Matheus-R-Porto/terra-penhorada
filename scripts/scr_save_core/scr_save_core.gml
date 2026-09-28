function save_core_create_data() {
    var data = {};

    data.save_version = SAVE_VERSION;
    data.save_slot = save_get_current_slot();

    return data;
}

function save_core_write_file(_data) {
    var file_name = save_get_file_name();

    var json = json_stringify(_data);

    var file = file_text_open_write(file_name);
    file_text_write_string(file, json);
    file_text_close(file);

    show_debug_message("Jogo salvo em: " + file_name);

    return true;
}

function save_core_read_file() {
    var file_name = save_get_file_name();

    if (!file_exists(file_name)) {
        show_debug_message("Save nao encontrado: " + file_name);
        return undefined;
    }

    var file = file_text_open_read(file_name);
    var json = file_text_read_string(file);
    file_text_close(file);

    var data = json_parse(json);

    return data;
}

function save_core_is_valid_data(_data) {
    if (is_undefined(_data)) {
        return false;
    }

    if (!is_struct(_data)) {
        return false;
    }

    if (!variable_struct_exists(_data, "save_version")) {
        return false;
    }

    return true;
}