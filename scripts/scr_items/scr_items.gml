function item_get_name(_item_id) {
    switch (_item_id) {
        case "money": return "Dinheiro";

        case "tomato_seed": return "Semente de tomate";
        case "corn_seed": return "Semente de milho";

        case "tomato": return "Tomate";
        case "corn": return "Milho";

        case "egg": return "Ovo";
        case "feed": return "Racao";

        case "ore": return "Minerio";
		case "coal": return "Carvao";
        case "bar": return "Barra";

        case "sprinkler_item": return "Irrigador";
        case "feeder_item": return "Alimentador";
        case "chest_item": return "Bau";

        default: return "Item desconhecido";
    }
}

function item_get_stack_limit(_item_id) {
    switch (_item_id) {
        case "money": return 0;

        case "sprinkler_item": return 10;
        case "feeder_item": return 10;
        case "chest_item": return 10;

        default: return 99;
    }
}

function item_get_weight(_item_id) {
    switch (_item_id) {
        case "money": return 0;

        case "tomato_seed": return 0.05;
        case "corn_seed": return 0.05;

        case "tomato": return 0.3;
        case "corn": return 0.5;

        case "egg": return 0.2;
        case "feed": return 0.2;

		case "coal": return 1;
        case "ore": return 1.0;
        case "bar": return 1.5;

        case "sprinkler_item": return 8.0;
        case "feeder_item": return 10.0;
        case "chest_item": return 5.0;

        default: return 1.0;
    }
}

function item_get_sell_price(_item_id) {
    switch (_item_id) {
        case "tomato": return 8;
        case "corn": return 12;
        case "egg": return 10;
		case "coal": return 3;
        case "ore": return 5;
        case "bar": return 18;

        default: return 0;
    }
}

function item_is_money(_item_id) {
    return _item_id == "money";
}

function item_get_buy_price(_item_id) {
    switch (_item_id) {
		case "coal": return 8;
        case "tomato_seed": return 4;
        case "corn_seed": return 6;
    }

    return 0;
}
	
function item_is_placeable(_item_id) {
    return _item_id == "sprinkler_item"
        || _item_id == "feeder_item"
        || _item_id == "chest_item";
}

function item_get_place_object(_item_id) {
    switch (_item_id) {
        case "sprinkler_item": return obj_machine_sprinkler_basic;
        case "feeder_item": return obj_machine_feeder_basic;
        case "chest_item": return obj_storage_chest;
    }

    return noone;
}



