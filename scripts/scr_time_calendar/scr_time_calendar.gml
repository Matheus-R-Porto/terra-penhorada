function time_advance_day() {
    if (!instance_exists(obj_time)) {
        return;
    }

    obj_time.day += 1;
    obj_time.day_of_month += 1;

    var new_month_started = false;

    // Por enquanto mês simples de 30 dias.
    // Depois migramos para meses reais e estações.
    if (obj_time.day_of_month > 30) {
        obj_time.day_of_month = 1;
        obj_time.month += 1;
        new_month_started = true;
    }

    // Reset do período
    obj_time.time_phase = 0;
    obj_time.phase_name = "Manha";

    // Processamento diário
	// Primeiro processa o que aconteceu no dia anterior.
	// Depois os irrigadores preparam o novo dia.
	crops_process_next_day();

	sprinklers_process_next_day();
	power_process_next_day();

	feeders_process_next_day();
	livestock_process_next_day();
	ores_process_next_day();
	contract_process_next_day();
	reputation_process_next_day();

    // Cobranca mensal no começo do novo mes
    if (new_month_started) {
        debt_process_monthly_payment();
    }

    ui_message("Novo dia: " + string(obj_time.day), 2);
    show_debug_message("Novo dia processado.");
}