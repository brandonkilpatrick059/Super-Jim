extends Node2D

@onready var active_card_left = $active_card_left
@onready var card_left_2 = $left_2
@onready var card_left_3 = $left_3
@onready var card_left_spawn = $left_spawn
@onready var active_card_right = $active_card_right
@onready var card_right_2 = $right_2
@onready var card_right_3 = $right_3
@onready var card_right_spawn = $right_spawn
@onready var bat_arms_left = $bat_arms_left
@onready var bat_arms_right = $bat_arms_right
@onready var sound_player = $AudioStreamPlayer2D
@onready var sound_player2 = $AudioStreamPlayer2D2
@onready var sound_player3 = $AudioStreamPlayer2D3
@onready var sound_player4 = $AudioStreamPlayer2D4
@onready var sound_player5 = $AudioStreamPlayer2D5
@onready var back_ground = $back_ground
@onready var home_win = $home_win
@onready var away_win = $away_win
@onready var get_ready = $get_ready
@onready var fight = $fight
@onready var catch_notification = $catch_notification

@onready var left_thrown_power = $left_thrown_power
@onready var left_thrown_shield = $left_thrown_shield
@onready var left_thrown_hp = $left_thrown_hp
@onready var right_thrown_power = $right_thrown_power
@onready var right_thrown_shield = $right_thrown_shield
@onready var right_thrown_hp = $right_thrown_hp
var left_catching : bool = false
var right_catching : bool = false

var sound_players : Array[AudioStreamPlayer2D] = []

var deck_left : Node2D
var deck_right : Node2D
var catch_chances : Array[float] = []
var current_right_index : int = 0
var current_catch_index : int = 0

var left_index = 0
var right_index = 0

var max_lineup = 5

var begin_end_timer := Timer.new()
var shaking_timer := Timer.new()
var game_timer := Timer.new()
var killing_timer := Timer.new()
var cycling_timer := Timer.new()
var turn_secs = 0.25
var rotating_timer := Timer.new()

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
var card_killing_y_step_start_val = 1
var card_killing_y_step = card_killing_y_step_start_val
var card_killing_y_step_accel = 0.25
var card_killing_rotation_step = 0.006
var killing_timer_step_secs = 0.006
var killing_time_in_secs = 1.5

var cycling_cards = false
var cycling_right_cards = false
var card_cycle_x_step = 4
var card_cycle_timer_step_secs = 0.006

var shaking = false
var shake_right = true
var shake_magnitude = 0
var starting_global_pos_x
var shaking_step = 0.1
var shake_x_step = 1

var queued_hp_buff_left = 0
var queued_shield_buff_left = 0
var queued_damage_buff_left = 0

var queued_hp_buff_right = 0
var queued_shield_buff_right = 0
var queued_damage_buff_right = 0

var starting = false
var start_pausing = false
var ending = false
var back_ground_move_step = 12
var back_ground_move_step_time = 0.006

var random = RandomNumberGenerator.new()

var callback_node : Node

var left_cards_killed : int = 0
var right_cards_killed : int = 0

var right_team_won = false
var left_team_won = false

var show_fight = true
var show_get_ready = false

func _ready():
	bat_arms_left.visible = false
	bat_arms_right.visible = false
	active_card_left.get_child(0).queue_free()
	active_card_right.get_child(0).queue_free()
	card_left_2.get_child(0).queue_free()
	card_right_2.get_child(0).queue_free()
	card_left_3.get_child(0).queue_free()
	card_right_3.get_child(0).queue_free()
	card_left_spawn.get_child(0).queue_free()
	card_right_spawn.get_child(0).queue_free()
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
	cycling_timer.one_shot = true
	add_child(cycling_timer)
	rotating_timer.one_shot = true
	add_child(rotating_timer)
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

func play_buff_sound(magnitude : int):
	if(magnitude > 0 && magnitude < 4):
		play_sound("res://audio/soundFX/baseball/buff.wav")
	elif(magnitude > 3 && magnitude < 7):
		play_sound("res://audio/soundFX/baseball/buff2.wav")
	elif(magnitude > 6 && magnitude < 8):
		play_sound("res://audio/soundFX/baseball/buff3.wav")
	elif(magnitude > 7 && magnitude < 9):
		play_sound("res://audio/soundFX/baseball/buff4.wav")
	elif(magnitude == 9):
		play_sound("res://audio/soundFX/baseball/buff5.wav")

func play_sound(path : String):
	if(sound_players.size() == 0):
		sound_players = [sound_player, sound_player2, sound_player3, 
						sound_player4, sound_player5]
	for sound_player in sound_players:
		if(!sound_player.playing):
			var stream = load(path)
			sound_player.stream = stream
			sound_player.play()
			return

func show_attack_sprite():
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

func run_effects_phase(run_for_right : bool):
	var buff = false
	var final_stat = 0
	if(run_for_right):
		if(queued_hp_buff_right > 0):
			card_right().set_hp(card_right().get_hp() + queued_hp_buff_right)
			final_stat = card_right().get_hp()
			queued_hp_buff_right = 0
			buff = true
		if(queued_shield_buff_right > 0):
			card_right().set_shield(card_right().get_shield() + queued_shield_buff_right)
			final_stat = card_right().get_shield()
			queued_shield_buff_right = 0
			buff = true
		if(queued_damage_buff_right > 0):
			card_right().set_power(card_right().get_power() + queued_damage_buff_right)
			final_stat = card_right().get_power()
			queued_damage_buff_right = 0
			buff = true
	else:
		if(queued_hp_buff_left > 0):
			card_left().set_hp(card_left().get_hp() + queued_hp_buff_left)
			final_stat = card_left().get_hp()
			queued_hp_buff_left = 0
			buff = true
		if(queued_shield_buff_left > 0):
			card_left().set_shield(card_left().get_shield() + queued_shield_buff_left)
			final_stat = card_left().get_shield()
			queued_shield_buff_left = 0
			buff = true
		if(queued_damage_buff_left > 0):
			card_left().set_power(card_left().get_power() + queued_damage_buff_left)
			final_stat = card_left().get_power()
			queued_damage_buff_left = 0
			buff = true
	if(buff):
		play_buff_sound(final_stat)
		buff = false
	effects_phase = false
	game_timer.start(turn_secs)

func handle_right_catch():
	if(current_catch_index != current_right_index):
		if(!killing_card &&
		!cycling_cards &&
		!left_catching &&
		right_has_ready_catch()):
			var roll_success : bool = false
			var roll : float = randf_range(0.0,1.0)
			var catch_chance : float = 0.0
			if(catch_chances.size() == deck_right.get_children().size()):
				catch_chances[current_right_index]
			else:
				if(current_right_index != deck_right.get_children().size()-1):
					catch_chance = 0.25
				else:
					catch_chance = 1.0
			roll_success = roll <= catch_chance
			right_catching = roll_success
			current_catch_index = current_right_index

func run_attack_phase(attacking_card : Baseball_Card, defending_card : Baseball_Card):
	var card_killed = false
	#step 1: APPLY DAMAGE
	show_attack_sprite()
	
	handle_right_catch()
	
	var damage_done = attacking_card.get_power()
	if(defending_card.get_shield() == 0):
		if(attacking_card.get_buff_dmg_against_team() > 0 && 
		defending_card.get_card_team() == attacking_card.get_buff_dmg_target_team()):
			damage_done = damage_done + attacking_card.get_buff_dmg_against_team()
		if(defending_card.get_debuff_dmg_from_team() > 0 &&
		attacking_card.get_card_team() == defending_card.get_debuff_dmg_target_team()):
			damage_done = damage_done - defending_card.get_debuff_dmg_from_team()
		#to prevent a game from stalling out if both cards are doing no damage,
		#if damage is debuffed to 0, there's still a 50% chance it will do 1 damage
		if(damage_done <= 0):
			if(randf_range(0.0,1.0) > 0.5):
				damage_done = 1
			else:
				damage_done = 0
	else: #blocked by shield
		damage_done = 0
		var defending_current_shield = defending_card.get_shield()
		defending_card.set_shield(defending_current_shield - 1)
		var particle = load("res://baseball/stat_particle.tscn").instantiate()
		attacking_card.add_child(particle)
		particle.global_position = Vector2(attacking_card.global_position.x,attacking_card.global_position.y)
		particle.set_and_fire_str("BLOCKED")
	var defending_hp = defending_card.get_hp()
	var defending_hp_after_damage = defending_hp - damage_done
	if(defending_hp_after_damage <= 0):
		defending_hp_after_damage = 0
		card_killed = true
		play_sound("res://audio/soundFX/baseball/drum.wav")
		
		var final_buff_amt : int = 0
		if(attacking_card.get_buff_damage_on_kill() > 0):
			var buff_amt = attacking_card.get_buff_damage_on_kill()
			attacking_card.set_power(attacking_card.get_power() + buff_amt)
			final_buff_amt = attacking_card.get_power()
		if(attacking_card.get_buff_shield_on_kill() > 0):
			var buff_amt = attacking_card.get_buff_shield_on_kill()
			attacking_card.set_shield(attacking_card.get_shield() + buff_amt)
			if(attacking_card.get_shield() > final_buff_amt):
				final_buff_amt = attacking_card.get_shield()
		if(attacking_card.get_buff_hp_on_kill() > 0):
			var buff_amt = attacking_card.get_buff_hp_on_kill()
			attacking_card.set_hp(attacking_card.get_hp() + buff_amt)
			if(attacking_card.get_hp() > final_buff_amt):
				final_buff_amt = attacking_card.get_hp()
		play_buff_sound(final_buff_amt)
	if(damage_done == 0):
		play_sound("res://audio/soundFX/maracca.ogg")
	elif(damage_done <= 3):
		play_sound("res://audio/soundFX/baseball/hit2.wav")
		Input.start_joy_vibration(0,0.25,0.0,0.25)
	elif(damage_done > 3 && damage_done <= 6):
		play_sound("res://audio/soundFX/baseball/hit3.wav")
		Input.start_joy_vibration(0,0.5,0.5,0.25)
	elif(damage_done > 6):
		var added_shake = damage_done - 6
		Input.start_joy_vibration(0,0.0,1.0,0.5)
		shake_screen(4 + added_shake)
		handle_shake()
		play_sound("res://audio/soundFX/baseball/hit3.wav")
	if(!right_is_going): #TODO: why is this reversed from what it should be? 
		card_left().rotation = card_left().rotation - (float(damage_done) / 15)
	else:
		card_right().rotation = card_right().rotation + (float(damage_done) / 15)
	defending_card.set_hp(defending_hp_after_damage)
	attacking_card.power_glow()
	#step 2: REDUCE POWER
	var attacking_power = attacking_card.get_power()
	if(attacking_power > 1):
		attacking_card.set_power(attacking_power - 1)
	game_timer.start(turn_secs)
	effects_phase = true

func run_turn(attacking_card : Baseball_Card, defending_card : Baseball_Card):
	if(effects_phase):
		var run_for_right = true
		var run_for_left = false
		run_effects_phase(run_for_right)
		run_effects_phase(run_for_left)
	else: #attack phase
		run_attack_phase(attacking_card,defending_card)

func card_right(num : int = 1):
	if(num == 1):
		return active_card_right.get_child(0)
	elif(num == 2):
		return card_right_2.get_child(0)
	elif(num == 3):
		return card_right_3.get_child(0)
	elif(num == 4):
		return card_right_spawn.get_child(0)
	
func card_left(num : int = 1):
	if(num == 1):
		return active_card_left.get_child(0)
	elif(num == 2):
		return card_left_2.get_child(0)
	elif(num == 3):
		return card_left_3.get_child(0)
	elif(num == 4):
		return card_left_spawn.get_child(0)

func set_card_right(card : Node2D, num : int = 1):
	card.visible = true
	if(num == 1):
		active_card_right.add_child(card)
	if(num == 2):
		card_right_2.add_child(card)
	if(num == 3):
		card_right_3.add_child(card)
	if(num == 4):
		card_right_spawn.add_child(card)
	
func set_card_left(card : Node2D, num : int = 1):
	card.visible = true
	if(num == 1):
		active_card_left.add_child(card)
	if(num == 2):
		card_left_2.add_child(card)
	if(num == 3):
		card_left_3.add_child(card)
	if(num == 4):
		card_left_spawn.add_child(card)

func update_active_cards():
	enact_effects()
	if(card_right().get_hp() == 0):
		kill_card(true)
		current_right_index = current_right_index + 1
	if(card_left().get_hp() == 0):
		kill_card(false)

func enact_effects():
	var card_right = card_right()
	var card_left = card_left()
	
	#flat buffs next card
	if(card_right.get_hp() == 0):
		var flat_buff_hp = card_right.get_flat_buff_hp()
		var flat_buff_shield = card_right.get_flat_buff_shield()
		var flat_buff_damage = card_right.get_flat_buff_damage()
		if(flat_buff_hp > 0):
			queued_hp_buff_right = flat_buff_hp
		if(flat_buff_shield > 0):
			queued_shield_buff_right = flat_buff_shield
		if(flat_buff_damage > 0):
			queued_damage_buff_right = flat_buff_damage
	if(card_left.get_hp() == 0):
		var flat_buff_hp = card_left.get_flat_buff_hp()
		var flat_buff_shield = card_left.get_flat_buff_shield()
		var flat_buff_damage = card_left.get_flat_buff_damage()
		if(flat_buff_hp > 0):
			queued_hp_buff_left = flat_buff_hp
		if(flat_buff_shield > 0):
			queued_shield_buff_left = flat_buff_shield
		if(flat_buff_damage  > 0):
			queued_damage_buff_left = flat_buff_damage 
			
	##stat carries to next card
	if(card_right.get_hp() == 0):
		if(card_right.adds_shield_next):
			queued_shield_buff_right = card_right.get_shield()
		if(card_right.adds_dmg_next):
			queued_damage_buff_right = card_right.get_power()
	if(card_left.get_hp() == 0):
		if(card_left.adds_shield_next):
			queued_shield_buff_left = card_left.get_shield()
		if(card_left.adds_dmg_next):
			queued_damage_buff_left = card_left.get_power()

	##throwing stats
	var stat_thrown = false
	if(card_right.get_hp() == 0):
		if(card_right.get_throws_hp() > 0):
			right_thrown_hp.throw_stat(card_right.get_throws_hp())
			stat_thrown = true
		if(card_right.get_throws_power() > 0):
			right_thrown_power.throw_stat(card_right.get_throws_power())
			stat_thrown = true
		if(card_right.get_throws_shield() > 0):
			right_thrown_shield.throw_stat(card_right.get_throws_shield())
			stat_thrown = true
	if(card_left.get_hp() == 0):
		if(card_left.get_throws_hp() > 0):
			left_thrown_hp.throw_stat(card_left.get_throws_hp())
			stat_thrown = true
		if(card_left.get_throws_power() > 0):
			left_thrown_power.throw_stat(card_left.get_throws_power())
			stat_thrown = true
		if(card_left.get_throws_shield() > 0):
			left_thrown_shield.throw_stat(card_left.get_throws_shield())
			stat_thrown = true
	if(stat_thrown):
		play_sound("res://audio/soundFX/dash_regen.wav")
	
	#CATCHING STATS
	var catch_wait_pause = 0.1
	if(left_catching):
		var catch_wait = 0.0
		var highest_stat = 0
		if left_thrown_hp.is_ready_to_catch():
			var buff = left_thrown_hp.catch(catch_wait)
			card_left().set_hp(card_left().get_hp() + buff)
			catch_wait = catch_wait + catch_wait_pause
			highest_stat = card_left.get_hp()
		
		if left_thrown_power.is_ready_to_catch():
			var buff = left_thrown_power.catch(catch_wait)
			card_left().set_power(card_left().get_power() + buff)
			catch_wait = catch_wait + catch_wait_pause
			if(card_left.get_power() > highest_stat):
				highest_stat = card_left.get_power()
		
		if left_thrown_shield.is_ready_to_catch():
			var buff = left_thrown_shield.catch(catch_wait)
			card_left().set_shield(card_left().get_shield() + buff)
			catch_wait = catch_wait + catch_wait_pause
			if(card_left.get_shield() > highest_stat):
				highest_stat = card_left.get_shield()
		play_buff_sound(highest_stat)
		
		left_catching = false
	if(right_catching):
		var catch_wait = 0.0
		var highest_stat = 0
		if right_thrown_hp.is_ready_to_catch():
			var buff = right_thrown_hp.catch(catch_wait)
			card_right().set_hp(card_right().get_hp() + buff)
			catch_wait = catch_wait + catch_wait_pause
			highest_stat = card_right.get_hp()
		
		if right_thrown_power.is_ready_to_catch():
			var buff = right_thrown_power.catch(catch_wait)
			card_right().set_power(card_right().get_power() + buff)
			catch_wait = catch_wait + catch_wait_pause
			if(card_right.get_power() > highest_stat):
				highest_stat = card_right.get_power()
		
		if right_thrown_shield.is_ready_to_catch():
			var buff = right_thrown_shield.catch(catch_wait)
			card_right().set_shield(card_right().get_shield() + buff)
			catch_wait = catch_wait + catch_wait_pause
			if(card_right.get_power() > highest_stat):
				highest_stat = card_right.get_power()
			play_buff_sound(highest_stat)
			
		right_catching = false

func handle_input():
	if(!killing_card &&
	!cycling_cards &&
	!left_catching &&
	left_has_ready_catch()):
		if(Input.is_action_pressed("interact")):
			left_catching = true
			play_sound("res://audio/soundFX/dash.wav")
		catch_notification.make_active()
	else:
		catch_notification.make_inactive()
		

func left_has_ready_catch():
	var ready = false
	ready = ready || left_thrown_hp.is_ready_to_catch()
	ready = ready || left_thrown_shield.is_ready_to_catch()
	ready = ready || left_thrown_power.is_ready_to_catch()
	return ready

func right_has_ready_catch():
	var ready = false
	ready = ready || right_thrown_hp.is_ready_to_catch()
	ready = ready || right_thrown_shield.is_ready_to_catch()
	ready = ready || right_thrown_power.is_ready_to_catch()
	return ready

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

func set_starting_cards():
	var left_card = deck_left.get_child(left_index).duplicate()
	set_card_left(left_card,1)
	left_card.global_position = card_left_spawn.global_position
	if(left_index+1 < deck_left.get_children().size()):
		left_index = left_index + 1
		var left_card_2 = deck_left.get_child(left_index).duplicate()
		set_card_left(left_card_2,2)
		left_card_2.global_position = card_left_spawn.global_position
	if(left_index+1 < deck_left.get_children().size()):
		left_index = left_index + 1
		var left_card_3 = deck_left.get_child(left_index).duplicate()
		set_card_left(left_card_3,3)
		left_card_3.global_position = card_left_spawn.global_position

	var right_card = deck_right.get_child(right_index).duplicate()
	set_card_right(right_card,1)
	right_card.global_position = card_right_spawn.global_position
	if(right_index+1 < deck_right.get_children().size()):
		right_index = right_index + 1
		var right_card_2 = deck_right.get_child(right_index).duplicate()
		set_card_right(right_card_2,2)
		right_card_2.global_position = card_right_spawn.global_position
	if(right_index+1 < deck_right.get_children().size()):
		right_index = right_index + 1
		var right_card_3 = deck_right.get_child(right_index).duplicate()
		set_card_right(right_card_3,3)
		right_card_3.global_position = card_right_spawn.global_position

func start_game():
	show_cards()
	starting_global_pos_x = global_position.x
	game_started = true
	set_starting_cards()
	play_sound("res://audio/soundFX/baseball/baseball.wav")
	game_timer.start(3)
	original_y = active_card_left.global_position.y
	show_get_ready = true

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
	#var amt : float = float(magnitude) / 9.0
	#Input.start_joy_vibration(0,0.0,amt,1.0)

func kill_card(kill_right_card : bool):
	bat_arms_left.visible = false
	bat_arms_right.visible = false
	card_killing_y_step = card_killing_y_step_start_val
	killing_card = true
	killing_right_card = kill_right_card
	if(kill_right_card):
		left_cards_killed = left_cards_killed + 1
		right_cards_killed = 0
	else:
		right_cards_killed = right_cards_killed + 1
		left_cards_killed = 0
	
	if(right_cards_killed > 1):
		var particle = load("res://baseball/stat_particle.tscn").instantiate()
		card_left().add_child(particle)
		particle.global_position = Vector2(card_left().global_position.x,card_left().global_position.y)
		if(right_cards_killed == 2):
			particle.set_and_fire_str("DOUBLE KILL")
		elif(right_cards_killed == 3):
			particle.set_and_fire_str("TRIPLE KILL")
		elif(right_cards_killed > 3):
			particle.set_and_fire_str("KILLING SPREE")
	
	if(left_cards_killed > 1):
		var particle = load("res://baseball/stat_particle.tscn").instantiate()
		card_right().add_child(particle)
		particle.global_position = Vector2(card_right().global_position.x,card_right().global_position.y)
		if(left_cards_killed == 2):
			particle.set_and_fire_str("DOUBLE KILL")
		elif(left_cards_killed == 3):
			particle.set_and_fire_str("TRIPLE KILL")
		elif(left_cards_killed > 3):
			particle.set_and_fire_str("KILLING SPREE")
	
	game_timer.start(killing_time_in_secs)
	killing_timer.start(killing_timer_step_secs)
	skip_turn_switch = true

func set_deck_left(deck : Node2D):
	deck_left = deck
	add_child(deck_left)

func set_deck_right(deck : Node2D):
	deck_right = deck
	add_child(deck_right)

func remaining_cards_leave():
	#make them shuffle off screen (to the spawn) "to fight another day"
	var _card_left : Array[Node2D] = [active_card_left,card_left_2,card_left_3]
	var _card_right : Array[Node2D] = [active_card_right,card_right_2,card_right_3]
	var transfrm = Vector2(card_cycle_x_step,0)
	if(right_team_won): #player lost
		var index = 0
		while(index < 4):
			if(card_right(index) != null):
				if(card_right(index).global_position.x < card_right_spawn.global_position.x):
					var pos = card_right(index).global_position
					card_right(index).global_position = pos  + transfrm
			index = index + 1
	elif(left_team_won):
		var index = 0
		while(index < 4):
			if(card_left(index) != null):
				if(card_left(index).global_position.x > card_left_spawn.global_position.x):
					var pos = card_left(index).global_position
					card_left(index).global_position = pos  - transfrm
			index = index + 1
		

func correct_rotation():
	if(card_left() != null && card_left().rotation != 0):
		card_left().rotation = card_left().rotation + 0.01
		if (card_left().rotation - 0.005 > 0):
			card_left().rotation = 0
	if(card_right() != null && card_right().rotation != 0):
		card_right().rotation = card_right().rotation - 0.01
		if (card_right().rotation + 0.005 <  0):
			card_right().rotation = 0

func need_card_cycling():
	var need_card_cycle = false
	var index = 1
	var _card_left : Array[Node2D] = [active_card_left,card_left_2,card_left_3]
	var _card_right : Array[Node2D] = [active_card_right,card_right_2,card_right_3]
	while(index < 4):
		if(card_left(index) != null):
			if(_card_left[index-1].global_position != card_left(index).global_position):
				need_card_cycle = true
				break
		if(card_right(index) != null):
			if(_card_right[index-1].global_position != card_right(index).global_position):
				need_card_cycle = true
				break
		index = index + 1
	return need_card_cycle

func cycle_card_process():
	if(cycling_timer.is_stopped()):
		var transfrm = Vector2(card_cycle_x_step,0)
		var index = 1
		var _card_left : Array[Node2D] = [active_card_left,card_left_2,card_left_3]
		var _card_right : Array[Node2D] = [active_card_right,card_right_2,card_right_3]
		while(index < 4):
			if(card_left(index) != null):
				if(_card_left[index-1].global_position > card_left(index).global_position):
					var pos = card_left(index).global_position
					card_left(index).global_position = pos  + transfrm
				elif(_card_left[index-1].global_position < card_left(index).global_position):
					card_left(index).global_position = _card_left[index-1].global_position
			if(card_right(index) != null):
				if(_card_right[index-1].global_position < card_right(index).global_position):
					var pos = card_right(index).global_position
					card_right(index).global_position = pos  - transfrm
				elif(_card_right[index-1].global_position > card_right(index).global_position):
					card_right(index).global_position = _card_right[index-1].global_position
			index = index + 1
	cycling_timer.start(card_cycle_timer_step_secs)

func killing_card_process():
	var card = card_left()
	if(killing_right_card):
		card = card_right()
	if(!game_timer.is_stopped()): #drop dead card from screen
		if(killing_timer.is_stopped()):
			card.global_position.y = card.global_position.y + card_killing_y_step
			card_killing_y_step = card_killing_y_step + card_killing_y_step_accel
			if(killing_right_card):
				card.rotation = card.rotation + card_killing_rotation_step
			else:
				card.rotation = card.rotation - card_killing_rotation_step
			killing_timer.start(killing_timer_step_secs)
	else: #dead card has dropped from the screen
		if(killing_right_card):
			card.queue_free()
			if(card_right(2) != null):	
				var card_right2 = card_right(2)
				card_right_2.remove_child(card_right2)
				set_card_right(card_right2,1)
				card_right2.global_position = card_right_2.global_position
				if(card_right(3) != null):
					var card_right3 = card_right(3)
					card_right_3.remove_child(card_right3)
					set_card_right(card_right3,2)
					card_right3.global_position = card_right_3.global_position
					if(right_index + 1 < deck_right.get_children().size()):
						right_index = right_index + 1
						var new_card_right = deck_right.get_child(right_index).duplicate()
						set_card_right(new_card_right,3)
						new_card_right.global_position = card_right_spawn.global_position
		else:
			card.queue_free()
			if(card_left(2) != null):	
				var card_left2 = card_left(2)
				card_left_2.remove_child(card_left2)
				set_card_left(card_left2,1)
				card_left2.global_position = card_left_2.global_position
				if(card_left(3) != null):
					var card_left3 = card_left(3)
					card_left_3.remove_child(card_left3)
					set_card_left(card_left3,2)
					card_left3.global_position = card_left_3.global_position
					if(left_index + 1 < deck_left.get_children().size()):
						left_index = left_index + 1
						var new_card_left = deck_left.get_child(left_index).duplicate()
						set_card_left(new_card_left,3)
						new_card_left.global_position = card_left_spawn.global_position
		killing_card = false

func initiate_card_game(deck_left : Array[int], deck_right : Array[int], new_catch_chances : Array[float] = []):
	var node_deck_left : Node2D = Node2D.new()
	var node_deck_right: Node2D = Node2D.new()
	var card_roster = get_tree().get_first_node_in_group("card_roster")
	for num in deck_left:
		var card = card_roster.get_card(num).duplicate()
		node_deck_left.add_child(card)
	for num in deck_right:
		var card = card_roster.get_card(num).duplicate()
		node_deck_right.add_child(card)
	set_decks_and_begin(node_deck_left, node_deck_right)
	if(new_catch_chances != []):
		catch_chances = new_catch_chances

func set_decks_and_begin(deck_left : Node, deck_right : Node):
	set_deck_left(deck_left)
	set_deck_right(deck_right)
	begin()

func check_game_over():
	if(active_card_left.get_child_count() == 0):
		game_is_over = true
		right_team_won = true
	elif(active_card_right.get_child_count() == 0):
		game_is_over = true
		left_team_won = true
	if(game_is_over):
		left_thrown_hp.visible = false
		left_thrown_power.visible = false
		left_thrown_shield.visible = false
		right_thrown_hp.visible = false
		right_thrown_power.visible = false
		right_thrown_shield.visible = false
		catch_notification.visible = false


func _physics_process(delta: float):
	if(starting && begin_end_timer.is_stopped()):
		if(start_pausing): #end of slight pause
			starting = false
			start_pausing = false
			start_game()
		elif(back_ground.position.y - back_ground_move_step <= 0):
			back_ground.position.y = 0
			start_pausing = true
			begin_end_timer.start(0.25) #slight pause to avoid graphics jitter
		else:
			back_ground.position.y = back_ground.position.y - back_ground_move_step
			begin_end_timer.start(back_ground_move_step_time)
	elif(ending && begin_end_timer.is_stopped()):
		if(back_ground.position.y + back_ground_move_step >512):
			back_ground.position.y = 512
			if(right_team_won):
				callback_node.game_end(2)
			elif(left_team_won):
				callback_node.game_end(1)
			queue_free()
		else:
			back_ground.position.y = back_ground.position.y + back_ground_move_step
			begin_end_timer.start(back_ground_move_step_time)
	if(game_started):
		handle_input()
		check_game_over()
		if(show_get_ready  && flashing_timer.is_stopped()):
			get_ready.visible = !get_ready.visible
			flashing_timer.start(flashing_time)
		if(shaking && shaking_timer.is_stopped()):
			handle_shake()
		if(declaring_victor && flashing_timer.is_stopped()):
			if(flashes > 0):
				var flashing_text
				left_index
				if(right_team_won): #player lost
					flashing_text = away_win
				elif(left_team_won): #opponent won
					flashing_text = home_win
				flashing_text.visible = !flashing_text.visible
				flashing_timer.start(flashing_time)
				flashes = flashes - 1
			else:
				declaring_victor = false
				end()
		if(!killing_card):
			if(rotating_timer.is_stopped()):
				correct_rotation()
				rotating_timer.start(0.006)
		if(killing_card):
			killing_card_process()
		elif(!game_is_over && need_card_cycling()):
			cycle_card_process()
		elif(game_timer.is_stopped()):
			if(show_get_ready):
				show_get_ready = false
				get_ready.visible = false
				fight.visible = true
				play_sound("res://audio/soundFX/baseball/bell.wav")
			elif(fight.visible):
				fight.visible = false
			if(!game_is_over && !killing_card):
				check_game_over()
				update_active_cards()
				if(!killing_card):
					if(right_is_going):	
						run_turn(card_right(), card_left())
					else:
						run_turn(card_left(), card_right())
					game_timer.start(turn_secs)
			elif(game_is_over):
				if(!declaring_victor && !ending):
					declaring_victor = true
					if(left_team_won):
						play_sound("res://audio/soundFX/baseball/win.wav")
					else:
						play_sound("res://audio/soundFX/pizza_lost.wav")
				else:
					remaining_cards_leave()
					
