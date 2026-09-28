function save_machines_array() {
    var machines = [];

    for (var i = 0; i < instance_number(obj_machine_sprinkler_basic); i++) {
        var sprinkler = instance_find(obj_machine_sprinkler_basic, i);

        array_push(machines, {
            object_type: "sprinkler_basic",
            x: sprinkler.x,
            y: sprinkler.y,
            area_id: sprinkler.area_id,
            range: sprinkler.range,
            power_required: sprinkler.power_required
        });
    }

    for (var j = 0; j < instance_number(obj_machine_feeder_basic); j++) {
        var feeder = instance_find(obj_machine_feeder_basic, j);

        array_push(machines, {
            object_type: "feeder_basic",
            x: feeder.x,
            y: feeder.y,
            area_id: feeder.area_id,
            range: feeder.range,
            feed_stored: feeder.feed_stored,
            feed_capacity: feeder.feed_capacity,
            egg_stored: feeder.egg_stored,
            egg_capacity: feeder.egg_capacity
        });
    }

    for (var g = 0; g < instance_number(obj_machine_generator_basic); g++) {
        var generator = instance_find(obj_machine_generator_basic, g);

        array_push(machines, {
            object_type: "generator_basic",
            x: generator.x,
            y: generator.y,
            area_id: generator.area_id,
            coal_stored: generator.coal_stored,
            coal_capacity: generator.coal_capacity,
            power_output: generator.power_output
        });
    }

    return machines;
}

function load_machines_array(_saved_machines) {
    with (obj_machine_sprinkler_basic) {
        instance_destroy();
    }

    with (obj_machine_feeder_basic) {
        instance_destroy();
    }

    with (obj_machine_generator_basic) {
        instance_destroy();
    }

    if (is_undefined(_saved_machines)) {
        power_recalculate();
        return;
    }

    for (var i = 0; i < array_length(_saved_machines); i++) {
        var saved_machine = _saved_machines[i];

        if (!variable_struct_exists(saved_machine, "object_type")) {
            continue;
        }

        var obj_to_create = noone;

        if (saved_machine.object_type == "sprinkler_basic") {
            obj_to_create = obj_machine_sprinkler_basic;
        }
        else if (saved_machine.object_type == "feeder_basic") {
            obj_to_create = obj_machine_feeder_basic;
        }
        else if (saved_machine.object_type == "generator_basic") {
            obj_to_create = obj_machine_generator_basic;
        }

        if (obj_to_create != noone) {
            var machine = instance_create_layer(
                saved_machine.x,
                saved_machine.y,
                "Instances",
                obj_to_create
            );

            if (variable_struct_exists(saved_machine, "area_id")) {
                machine.area_id = saved_machine.area_id;
            }
            else {
                machine.area_id = "farm";
            }

            if (variable_struct_exists(saved_machine, "range")) {
                machine.range = saved_machine.range;
            }

            if (saved_machine.object_type == "sprinkler_basic") {
                machine.machine_id = "sprinkler_basic";

                if (variable_struct_exists(saved_machine, "power_required")) {
                    machine.power_required = saved_machine.power_required;
                }
                else {
                    machine.power_required = 1;
                }
            }
            else if (saved_machine.object_type == "feeder_basic") {
                machine.machine_id = "feeder_basic";

                if (variable_struct_exists(saved_machine, "feed_stored")) {
                    machine.feed_stored = saved_machine.feed_stored;
                }

                if (variable_struct_exists(saved_machine, "feed_capacity")) {
                    machine.feed_capacity = saved_machine.feed_capacity;
                }

                if (variable_struct_exists(saved_machine, "egg_stored")) {
                    machine.egg_stored = saved_machine.egg_stored;
                }

                if (variable_struct_exists(saved_machine, "egg_capacity")) {
                    machine.egg_capacity = saved_machine.egg_capacity;
                }
            }
            else if (saved_machine.object_type == "generator_basic") {
                machine.machine_id = "generator_basic";

                if (variable_struct_exists(saved_machine, "coal_stored")) {
                    machine.coal_stored = saved_machine.coal_stored;
                }
                else {
                    machine.coal_stored = 0;
                }

                if (variable_struct_exists(saved_machine, "coal_capacity")) {
                    machine.coal_capacity = saved_machine.coal_capacity;
                }
                else {
                    machine.coal_capacity = 10;
                }

                if (variable_struct_exists(saved_machine, "power_output")) {
                    machine.power_output = saved_machine.power_output;
                }
                else {
                    machine.power_output = 4;
                }
            }
        }
    }

    power_recalculate();
}

function save_machines_write(_data) {
    _data.machines = save_machines_array();

    return _data;
}

function save_machines_read(_data) {
    if (variable_struct_exists(_data, "machines")) {
        load_machines_array(_data.machines);
    }
    else {
        power_recalculate();
    }

    return true;
}