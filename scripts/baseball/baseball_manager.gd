extends Node2D

@export var deck_left : Node2D
@export var deck_right : Node2D
@onready var active_card_left = $active_card_left
@onready var card_left_2 = $left_2
@onready var card_left_3 = $left_3
@onready var active_card_right = $active_card_right
@onready var card_right_2 = $right_2
@onready var card_right_3 = $right_3
@onready var bat_arms_left = $bat_arms_left
@onready var bat_arms_right = $bat_arms_right
@onready var sound_player = $AudioStreamPlayer2D
@onready var sound_player2 = $AudioStreamPlayer2D2
@onready var sound_player3 = $AudioStreamPlayer2D2
@onready var back_ground = $back_ground
@onready var home_win = $home_win
@onready var away_win = $away_win

var left_index = 0
var right_index = 0

var max_lineup = 5

var begin_end_timer := Timer.new()
var shaking_timer := Timer.new()
var game_timer := Timer.new()
var killing_timer := Timer.new()
var turn_secs = 0.25

var declaring_victor = false
var flashing_timer := Timer.new()
var flashing_time = 0.5
var flashes = 6

var effects_phase = false

var right_is_going = true

var game_started = false
var game_is_over = false

var original_y = 0

var skip_turn_switch = false
var killing_card = false
var killing_right_card = false
var card_killing_y_step_start_val = 5
var card_killing_y_step = card_killing_y_step_start_val
var card_killing_y_step_accel = 2
var card_killing_rotation_step = 0.05
var killing_timer_step_secs = 0.006
var killing_time_in_secs = 1.5

var shaking = false
var shake_right = true
var shake_magnitude = 0
var starting_global_pos_x
var shaking_step = 0.1
var shake_x_step = 1

var queued_hp_buff_left = 0
var queued_stamina_buff_left = 0
var queued_damage_buff_left = 0

var queued_hp_buff_right = 0
var queued_stamina_buff_right = 0
var queued_damage_buff_right = 0

var starting = false
var ending = false
var back_ground_move_step = 16
var back_ground_move_step_time = 0.006

var random = RandomNumberGenerator.new()

var callback_node : Node

func _ready():
	bat_arms_left.visible = false
	bat_arms_right.visible = false
	active_card_left.get_child(0).queue_free()
	active_card_right.get_child(0).queue_free()
	card_left_2.get_child(0).queue_free()
	card_right_2.get_child(0).queue_free()
	card_left_3.get_child(0).queue_free()
	card_right_3.get_child(0).queue_free()
	game_timer.one_shot = true
	add_child(game_timer)
	killing_timer.one_shot = true
	add_child(killing_timer)
	game_timer.start(turn_secs)
	shaking_timer.one_shot = true
	add_child(shaking_timer)
	begin_end_timer.one_shot = true
	add_child(begin_end_timer)
	flashing_timer.one_shot = true
	add_child(flashing_timer)
	hide_cards()
	begin()

func set_callback_node(node : Node):
	callback_node = node

func hide_cards():
	active_card_right.visible = false
	card_right_2.visible = false
	card_right_3.visible = false
	
	active_card_left.visible = false
	card_left_2.visible = false
	card_left_3.visible = false
	
func show_cards():
	active_card_right.visible = true
	card_right_2.visible = true
	card_right_3.visible = true
	
	active_card_left.visible = true
	card_left_2.visible = true
	card_left_3.visible = true

func run_turn(attacking_card : Baseball_Card, defending_card : Baseball_Card):
	if(effects_phase):
		sound_player.stream = load("res://audio/soundFX/baseball/buff.wav")
		var buff = false
		if(right_is_going):
			if(queued_hp_buff_right > 0):
				card_right().set_hp(	card_right().get_hp() + queued_hp_buff_right)
				queued_hp_buff_right = 0
				buff = true
			if(queued_stamina_buff_right > 0):
				card_right().set_stamina(card_right().get_stamina() + queued_stamina_buff_right)
				queued_stamina_buff_right = 0
				buff = true
			if(queued_damage_buff_right > 0):
				card_right().set_damage(card_right().get_damage() + queued_damage_buff_right)
				queued_damage_buff_right = 0
				buff = true
		else:
			if(queued_hp_buff_left > 0):
				card_left().set_hp(card_left().get_hp() + queued_hp_buff_left)
				queued_hp_buff_left = 0
				buff = true
			if(queued_stamina_buff_left > 0):
				card_left().set_stamina(card_left().get_stamina() + queued_stamina_buff_left)
				queued_stamina_buff_left = 0
				buff = true
			if(queued_damage_buff_left > 0):
				card_left().set_damage(card_left().get_damage() + queued_damage_buff_left)
				queued_damage_buff_left = 0
				buff = true
		if(buff):
			sound_player.play()
			buff = false
		effects_phase = false
	else: #attack phase
		var card_killed = false
		#step 1: APPLY DAMAGE
		if(right_is_going):
			bat_arms_left.visible = false
			bat_arms_right.visible = true
			bat_arms_right.stop()
			bat_arms_right.play("default",2)
			right_is_going = false
		else:
			bat_arms_left.visible = true
			bat_arms_right.visible = false
			bat_arms_left.stop()
			bat_arms_left.play("default",2)
			right_is_going = true
					
		var damage_done = attacking_card.get_power()
		var defending_hp = defending_card.get_hp()
		var defending_hp_after_damage = defending_hp - damage_done
		if(defending_hp_after_damage <= 0):
			defending_hp_after_damage = 0
			card_killed = true
			sound_player2.stream = load("res://audio/soundFX/putdown.wav")
			sound_player2.play()
			
			if(attacking_card.buff_dmg_on_kill > 0):
				var buff_amt = attacking_card.buff_dmg_on_kill
				attacking_card.set_power(attacking_card.get_power() + buff_amt)
				sound_player3.stream = load("res://audio/soundFX/baseball/buff.wav")
				sound_player3.play() 
			if(attacking_card.buff_stamina_on_kill > 0):
				var buff_amt = attacking_card.buff_stamina_on_kill
				attacking_card.set_stamina(attacking_card.get_stamina() + buff_amt)
				sound_player3.stream = load("res://audio/soundFX/baseball/buff.wav")
				sound_player3.play() 
			if(attacking_card.buff_hp_on_kill > 0):
				var buff_amt = attacking_card.buff_hp_on_kill
				attacking_card.set_hp(attacking_card.get_hp() + buff_amt)
				sound_player3.stream = load("res://audio/soundFX/baseball/buff.wav")
				sound_player3.play() 
		if(damage_done <= 3):
			sound_player.stream = load("res://audio/soundFX/baseball/hit2.wav")
		elif(damage_done > 3 && damage_done <= 6):
			sound_player.stream = load("res://audio/soundFX/baseball/hit3.wav")
		elif(damage_done > 6):
			var added_shake = damage_done - 6
			shake_screen(4 + added_shake)
			handle_shake()
			sound_player.stream = load("res://audio/soundFX/baseball/hit3.wav")
		defending_card.set_hp(defending_hp_after_damage)
		sound_player.play()
		attacking_card.power_glow()
		#step 2: REDUCE STAMINA + POWER
		var attacking_stamina = attacking_card.get_stamina()
		if(attacking_stamina > 0):
			attacking_card.set_stamina(attacking_stamina - 1)
		elif(attacking_stamina == 0):
			var attacking_power = attacking_card.get_power()
			if(attacking_power > 1):
				attacking_card.set_power(attacking_power - 1)
		game_timer.start(turn_secs)
		effects_phase = true

func card_right(num : int = 1):
	if(num == 1):
		return active_card_right.get_child(0)
	elif(num == 2):
		return card_right_2.get_child(0)
	elif(num == 3):
		return card_right_3.get_child(0)
	
func card_left(num : int = 1):
	if(num == 1):
		return active_card_left.get_child(0)
	elif(num == 2):
		return card_left_2.get_child(0)
	elif(num == 3):
		return card_left_3.get_child(0)

func set_card_right(card : Node2D, num : int = 1):
	if(num == 1):
		active_card_right.add_child(card)
		card.global_position = active_card_right.global_position
	if(num == 2):
		card_right_2.add_child(card)
		card.global_position = card_right_2.global_position
	if(num == 3):
		card_right_3.add_child(card)
		card.global_position = card_right_3.global_position
	
func set_card_left(card : Node2D, num : int = 1):
	if(num == 1):
		active_card_left.add_child(card)
		card.global_position = active_card_left.global_position
	if(num == 2):
		card_left_2.add_child(card)
		card.global_position = card_left_2.global_position
	if(num == 3):
		card_left_3.add_child(card)
		card.global_position = card_left_3.global_position

func update_active_cards():
	enact_effects()
	if(card_right().get_hp() == 0):
		kill_card(true)
	if(card_left().get_hp() == 0):
		kill_card(false)

func enact_effects():
	var card_right = card_right()
	var card_left = card_left()
	
	#flat buffs next card
	if(card_right.get_hp() == 0):
		var flat_buff_hp = card_right.get_flat_buff_hp()
		var flat_buff_stamina = card_right.get_flat_buff_stamina()
		var flat_buff_damage = card_right.get_flat_buff_damage()
		if(flat_buff_hp > 0):
			queued_hp_buff_right = flat_buff_hp
		if(flat_buff_stamina > 0):
			queued_stamina_buff_right = flat_buff_stamina
		if(flat_buff_damage > 0):
			queued_damage_buff_right = flat_buff_damage
	if(card_left.get_hp() == 0):
		var flat_buff_hp = card_left.get_flat_buff_hp()
		var flat_buff_stamina = card_left.get_flat_buff_stamina()
		var flat_buff_damage = card_left.get_flat_buff_damage()
		if(flat_buff_hp > 0):
			queued_hp_buff_left = flat_buff_hp
		if(flat_buff_stamina > 0):
			queued_stamina_buff_left = flat_buff_stamina
		if(flat_buff_damage  > 0):
			queued_damage_buff_left = flat_buff_damage 
			
	##stat carries to next card
	if(card_right.get_hp() == 0):
		if(card_right.adds_hp_next):
			queued_hp_buff_right = card_right.get_hp()
		if(card_right.adds_stamina_next):
			queued_stamina_buff_right = card_right.get_stamina()
		if(card_right.adds_dmg_next):
			queued_damage_buff_right = card_right.get_damage()
	if(card_left.get_hp() == 0):
		if(card_left.adds_hp_next):
			queued_hp_buff_left = card_left.get_hp()
		if(card_left.adds_stamina_next):
			queued_stamina_buff_left = card_left.get_stamina()
		if(card_left.adds_dmg_next):
			queued_damage_buff_left = card_left.get_damage()
	
	#stat carries from previous card


func begin():
	starting = true
	ending = false
	game_started = false
	begin_end_timer.start(back_ground_move_step_time)

func end():
	starting = false
	ending = true
	hide_cards()
	begin_end_timer.start(back_ground_move_step_time)

func start_game():
	starting_global_pos_x = global_position.x
	game_started = true
	var left_card = deck_left.get_child(left_index).duplicate()
	set_card_left(left_card)
	if(left_index+1 < deck_right.get_children().size()):
		var left_card_2 = deck_left.get_child(left_index+1).duplicate()
		set_card_left(left_card_2,2)
	if(left_index+2 < deck_right.get_children().size()):
		var left_card_3 = deck_left.get_child(left_index+2).duplicate()
		set_card_left(left_card_3,3)
	var right_card = deck_right.get_child(right_index).duplicate()
	set_card_right(right_card)
	if(right_index+1 < deck_right.get_children().size()):
		var right_card_2 = deck_right.get_child(right_index+1).duplicate()
		set_card_right(right_card_2,2)
	if(right_index+2 < deck_right.get_children().size()):
		var right_card_3 = deck_right.get_child(right_index+2).duplicate()
		set_card_right(right_card_3,3)
	show_cards()
	sound_player.stream = load("res://audio/soundFX/baseball/baseball.wav")
	sound_player.play()
	game_timer.start(3)
	original_y = active_card_left.global_position.y

func handle_shake():
	if(shake_magnitude <= 0):
		shaking = false
	else:
		if(shake_right):
			global_position.x = starting_global_pos_x + shake_magnitude
		else:
			global_position.x = starting_global_pos_x - shake_magnitude
		shake_right = !shake_right
		shake_magnitude = shake_magnitude - shake_x_step
		shaking_timer.start(shaking_step)

func shake_screen(magnitude : int):
	shaking = true
	shake_magnitude = magnitude
	

func kill_card(kill_right_card : bool):
	bat_arms_left.visible = false
	bat_arms_right.visible = false
	card_killing_y_step = card_killing_y_step_start_val
	killing_card = true
	killing_right_card = kill_right_card
	game_timer.start(killing_time_in_secs)
	killing_timer.start(killing_timer_step_secs)
	sound_player.stream = load("res://audio/soundFX/pizza_lost.wav")
	sound_player.play()
	skip_turn_switch = true

func set_deck_left(deck : Node):
	deck_left = deck

func set_deck_right(deck : Node):
	deck_right = deck

func killing_card_process():
	var card = card_left()
	if(killing_right_card):
		card = card_right()
	if(!game_timer.is_stopped()):
		if(killing_timer.is_stopped()):
			card.global_position.y = card.global_position.y + card_killing_y_step
			card_killing_y_step = card_killing_y_step + card_killing_y_step_accel
			if(killing_right_card):
				card.rotation = card.rotation + card_killing_rotation_step
			else:
				card.rotation = card.rotation - card_killing_rotation_step
			killing_timer.start(killing_timer_step_secs)
	else:
		if(killing_right_card):
			#TODO: should smoothly float into position instead of what I'm abt to do
			card_right().queue_free()
			if(card_right(2)):
				card_right(2).queue_free()
			if(card_right(3)):
				card_right(3).queue_free()
			right_index = right_index + 1
			if(right_index < deck_right.get_children().size()):	
				var right_card = deck_right.get_child(right_index).duplicate()
				set_card_right(right_card)
				if(right_index + 1 < deck_right.get_children().size()):
					var right_card_2 = deck_right.get_child(right_index+1).duplicate()
					set_card_right(right_card_2,2)
				if(right_index + 2 < deck_right.get_children().size()):
					var right_card_3 = deck_right.get_child(right_index+2).duplicate()
					set_card_right(right_card_3,3)
				
			else:
				game_is_over = true
		else:
			card_left().queue_free()
			if(card_left(2)):
				card_left(2).queue_free()
			if(card_left(3)):
				card_left(3).queue_free()
			left_index = left_index + 1
			if(left_index < deck_left.get_children().size()):	
				var left_card = deck_left.get_child(left_index).duplicate()
				set_card_left(left_card)
				if(left_index + 1 < deck_left.get_children().size()):
					var left_card_2 = deck_left.get_child(left_index+1).duplicate()
					set_card_left(left_card_2,2)
				if(left_index + 2 < deck_left.get_children().size()):
					var left_card_3 = deck_left.get_child(left_index+2).duplicate()
					set_card_left(left_card_3,3)
			else:
				game_is_over = true
		killing_card = false

func set_decks_and_begin(deck_left : Node, deck_right : Node):
	set_deck_left(deck_left)
	set_deck_right(deck_right)
	begin()

func _physics_process(delta: float):	
	if(starting && begin_end_timer.is_stopped()):
		if(back_ground.position.y - back_ground_move_step < 0):
			back_ground.position.y = 0
			starting = false
			start_game()
		else:
			back_ground.position.y = back_ground.position.y - back_ground_move_step
			begin_end_timer.start(back_ground_move_step_time)
	elif(ending && begin_end_timer.is_stopped()):
		if(back_ground.position.y + back_ground_move_step >512):
			back_ground.position.y = 512
			if(left_index == deck_left.get_children().size()):
				callback_node.game_end(2)
			else:
				callback_node.game_end(1)
			queue_free()
		else:
			back_ground.position.y = back_ground.position.y + back_ground_move_step
			begin_end_timer.start(back_ground_move_step_time)
	if(game_started):
		if(shaking && shaking_timer.is_stopped()):
			handle_shake()
		if(declaring_victor && flashing_timer.is_stopped()):
			if(flashes > 0):
				var flashing_text
				left_index
				if(left_index == deck_left.get_children().size()):
					flashing_text = away_win
				else:
					flashing_text = home_win
				flashing_text.visible = !flashing_text.visible
				flashing_timer.start(flashing_time)
				flashes = flashes - 1
			else:
				declaring_victor = false
				end()
		if(killing_card):
			killing_card_process()
		elif(game_timer.is_stopped()):
			if(!game_is_over && !killing_card):
				update_active_cards()
				if(!killing_card):
					if(right_is_going):	
						run_turn(card_right(), card_left())
					else:
						run_turn(card_left(), card_right())
					game_timer.start(turn_secs)
			elif(game_is_over && !declaring_victor && !ending):
				declaring_victor = true
			
			
