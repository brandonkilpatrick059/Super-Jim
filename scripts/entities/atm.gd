extends Node2D

var ui = preload("res://interface/atm_interface.tscn")

var balance = 0
var max_balance = 999999
var decimals = 6

var transaction_num = 0

var is_withdrawal = false

var ui_ref = null

var ui_active = false

var transacting = false

var increment_timer : Timer = Timer.new()
var increment_timer_step : float = 0.1

var player_ref = null

func _ready() -> void:
	increment_timer.one_shot = true
	add_child(increment_timer)

func set_up_ui():
	if(player_ref != null):
		balance = player_ref.get_banked_money()
		ui_ref.set_balance_num(get_balance_string())
		var type_str = get_type_string()
		ui_ref.set_transaction_type(type_str)
		transaction_num = 0
		var transaction_num_str = get_transaction_num_str()
		ui_ref.set_transaction_num(transaction_num_str)

func get_balance_string():
	var balance_str = get_number_as_string(balance)
	balance_str = str("$",balance_str)
	return balance_str

func get_transaction_num_str():
	var transaction_num_str = get_number_as_string(transaction_num)
	transaction_num_str = str("$",transaction_num_str)
	return transaction_num_str

#returns an integer with leading zeros based on var decimals
func get_number_as_string(num : int) -> String:
	var string_int : String = str(num)
	var leading_zeros = decimals - string_int.length()
	var ret_string = ""
	while(leading_zeros > 0):
		ret_string = str(ret_string,"0")
		leading_zeros = leading_zeros - 1
	ret_string = str(ret_string, num)
	return ret_string

func get_type_string() -> String:
	if(is_withdrawal):
		return "<WITHDRAW>"
	else:
		return "<DEPOSIT>"

func interact():
	player_ref = get_tree().get_first_node_in_group("player")
	ui_ref = ui.instantiate()
	player_ref.set_control_frozen(true)
	player_ref.add_scene_to_ui_tree(ui_ref)
	set_up_ui()
	ui_active = true

func handle_input():
	pass

func exit_ui():
	player_ref.set_banked_money(balance)
	ui_active = false
	transacting = false
	ui_ref.queue_free()
	player_ref.set_control_frozen(false)

func toggle_type():
	is_withdrawal = !is_withdrawal
	set_transaction_num(0)
	var type_str = get_type_string()
	ui_ref.set_transaction_type(type_str)

func adjust_balance_num(num : int):
	balance = balance + num
	var balance_num_str = get_balance_string()
	ui_ref.set_balance_num(balance_num_str)

func adjust_transaction_num(num : int):
	var new_num = transaction_num + num
	if(is_withdrawal):
		if(new_num > -1 &&
		new_num <= balance):
			transaction_num = transaction_num + num
			var transaction_num_str = get_transaction_num_str()
			ui_ref.set_transaction_num(transaction_num_str)
	else:
		if(new_num > -1 &&
		new_num <= player_ref.get_money()):
			transaction_num = transaction_num + num
			var transaction_num_str = get_transaction_num_str()
			ui_ref.set_transaction_num(transaction_num_str)

func set_transaction_num(num : int):
	transaction_num = num
	var transaction_num_str = get_transaction_num_str()
	ui_ref.set_transaction_num(transaction_num_str)

func commit_transaction():
	if(is_withdrawal):
		if(transaction_num <= balance):
			transacting = true
		else:
			exit_ui() #make a sad little sound
	else:
		if(transaction_num <= player_ref.get_money()):
			transacting = true
		else:
			exit_ui() #make a sad little sound

func _physics_process(delta: float) -> void:
	if(ui_active):
		if(transacting):
			if(increment_timer.is_stopped()):
				if(is_withdrawal):
					if(transaction_num > 0):
						adjust_transaction_num(-1)
						adjust_balance_num(-1)
						player_ref._on_add_money(1)
						increment_timer.start(increment_timer_step)
					else:
						exit_ui()
				else:
					if(transaction_num > 0):
						adjust_transaction_num(-1)
						adjust_balance_num(1)
						player_ref._on_add_money(-1)
						increment_timer.start(increment_timer_step)
					else:
						exit_ui()
		else:
			if Input.is_action_just_pressed(direction.right):
				toggle_type()
			else: if Input.is_action_just_pressed(direction.left):
				toggle_type()
			else: if Input.is_action_pressed(direction.up):
				if(increment_timer.is_stopped()):
					adjust_transaction_num(1)
					increment_timer.start(increment_timer_step)
			else: if Input.is_action_pressed(direction.down):
				if(increment_timer.is_stopped()):
					adjust_transaction_num(-1)
					increment_timer.start(increment_timer_step)
			else: if Input.is_action_just_pressed("interact"):
				commit_transaction()
