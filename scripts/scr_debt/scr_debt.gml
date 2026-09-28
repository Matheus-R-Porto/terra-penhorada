function debt_init() {
    debt_total = 500;
    debt_payment_amount = 100;

    debt_overdue_amount = 0;
    debt_interest_rate = 0.10;

    debt_is_overdue = false;
    debt_missed_payments = 0;

    debt_last_event_text = "Nenhuma cobranca ainda.";
}

function debt_get_total_due_now() {
    if (!instance_exists(obj_time)) {
        return 0;
    }

    var current_payment = 0;

    if (obj_time.debt_total > 0) {
        current_payment = min(obj_time.debt_payment_amount, obj_time.debt_total);
    }

    return obj_time.debt_overdue_amount + current_payment;
}

function debt_process_monthly_payment() {
    if (!instance_exists(obj_time)) {
        return;
    }

    if (!instance_exists(obj_player)) {
        return;
    }

    var tc = obj_time;
    var player = obj_player;

    // Se ja quitou tudo
    if (tc.debt_total <= 0 && tc.debt_overdue_amount <= 0) {
        tc.debt_total = 0;
        tc.debt_overdue_amount = 0;
        tc.debt_is_overdue = false;
        tc.debt_missed_payments = 0;
        tc.debt_last_event_text = "Divida quitada.";

        ui_message("Divida quitada!", 2);
        show_debug_message("Divida quitada. Nada a cobrar.");
        return;
    }

    var current_payment = 0;

    if (tc.debt_total > 0) {
        current_payment = min(tc.debt_payment_amount, tc.debt_total);
    }

    var overdue_before = tc.debt_overdue_amount;
    var total_due_now = overdue_before + current_payment;

    // Tenta pagar tudo
	if (total_due_now > 0 && money_can_spend(total_due_now)) {
	    money_spend(total_due_now);

        // Paga atraso inteiro
        tc.debt_overdue_amount = 0;

        // Paga parcela atual
        if (current_payment > 0) {
            tc.debt_total -= current_payment;
            tc.debt_total = max(tc.debt_total, 0);
        }

        tc.debt_is_overdue = false;
        tc.debt_missed_payments = 0;

        if (tc.debt_total <= 0 && tc.debt_overdue_amount <= 0) {
            tc.debt_total = 0;
            tc.debt_last_event_text = "Divida quitada com pagamento de $" + string(total_due_now) + ".";
            ui_message("Divida quitada!", 3);
        }
        else {
            tc.debt_last_event_text = "Pagamento feito: $" + string(total_due_now) + ".";
            ui_message("Cobranca paga: -$" + string(total_due_now), 3);
        }

        show_debug_message("Pagamento da divida feito.");
        show_debug_message("Atraso pago: $" + string(overdue_before));
        show_debug_message("Parcela paga: $" + string(current_payment));
        show_debug_message("Total pago: $" + string(total_due_now));
        show_debug_message("Divida restante: $" + string(tc.debt_total));

        return;
    }

    // Nao conseguiu pagar
	// No Normal, atraso acumula de forma simples.
	// Juros ficam desligados por padrao e podem ser usados em dificuldade futura.
	if (tc.debt_overdue_amount > 0 && DEBT_USE_INTEREST) {
	    var old_interest = ceil(tc.debt_overdue_amount * tc.debt_interest_rate);
	    tc.debt_overdue_amount += old_interest;

	    show_debug_message("Juros sobre atraso antigo: $" + string(old_interest));
	}

	// Parcela atual vira atraso
	if (current_payment > 0) {
	    var current_interest = 0;

	    if (DEBT_USE_INTEREST) {
	        current_interest = ceil(current_payment * tc.debt_interest_rate);
	    }

	    var new_overdue = current_payment + current_interest;

	    tc.debt_total -= current_payment;
	    tc.debt_total = max(tc.debt_total, 0);

	    tc.debt_overdue_amount += new_overdue;

	    show_debug_message("Parcela atual virou atraso.");
	    show_debug_message("Parcela: $" + string(current_payment));

	    if (DEBT_USE_INTEREST) {
	        show_debug_message("Juros da parcela: $" + string(current_interest));
	    }

	    show_debug_message("Novo atraso adicionado: $" + string(new_overdue));
	}

    tc.debt_is_overdue = true;
    tc.debt_missed_payments += 1;

    tc.debt_last_event_text =
        "Pagamento falhou. Atraso acumulado: $" +
        string(tc.debt_overdue_amount) +
        ".";

    ui_message("Pagamento da divida falhou.", 3);

    show_debug_message("Pagamento da divida falhou.");
    show_debug_message("Total que deveria pagar agora: $" + string(total_due_now));
    show_debug_message("Dinheiro atual: $" + string(money_get()));
    show_debug_message("Atraso acumulado: $" + string(tc.debt_overdue_amount));
    show_debug_message("Divida restante: $" + string(tc.debt_total));
    show_debug_message("Parcelas atrasadas: " + string(tc.debt_missed_payments));
}