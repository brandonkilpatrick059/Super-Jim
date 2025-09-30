extends Node2D

@export var deck_left : Node2D
@export var deck_right : Node2D
@onready var active_card_left = $active_card_left
@onready var active_card_right = $active_card_right
@onready var bat_arms_left = $bat_arms_left
@onready var bat_arms_right = $bat_arms_right
@onready var sound_player = $AudioStreamPlayer2D
@onready var sound_player2 = $AudioStreamPlayer2D2

var left_index = 0
var right_index = 0

var max_lineup = 10

var game_timer := Timer.new()
var killing_timer := Timer.new()
var turn_secs = 0.5

var right_is_going = true

var game_started = false
var game_is_over = false

var original_y = 0

var skip_turn_switch = false
var killing_card = false
var killing_right_card = false
var card_killing_y_step_start_val = 5
var card_killing_y_step = card_killing_y_step_start_val
var card_killing_y_step_accel = 15
var card_killing_rotation_step = 0.05
var killing_timer_step_secs = 0.1
var killing_time_in_secs = 1.5

func _ready():
	bat_arms_left.visible = false
	bat_arms_right.visible = false
	active_card_left.get_child(0).queue_free()
	active_card_right.get_child(0).queue_free()
	game_timer.one_shot = true
	add_child(game_timer)
	killing_timer.one_shot = true
	add_child(killing_timer)
	game_timer.start(turn_secs)

func run_turn(attacking_card : Baseball_Card, defending_card : Baseball_Card) -> bool:
	var card_killed = false
	#step 1: APPLY DAMAGE
	var damage_done = attacking_card.get_power()
	var defending_hp = defending_card.get_hp()
	var defending_hp_after_damage = defending_hp - damage_done
	if(defending_hp_after_damage <= 0):
		defending_hp_after_damage = 0
		card_killed = true
		sound_player2.stream = load("res://audio/soundFX/putdown.wav")
		sound_player2.play()
	defending_card.set_hp(defending_hp_after_damage)
	sound_player.stream = load("res://audio/soundFX/baseball/hit2.wav")
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
	#step 3: EFFECTS
	#todo: make effects work
	game_timer.start(turn_secs)
	return card_killed

func card_right():
	return active_card_right.get_child(0)
	
func card_left():
	return active_card_left.get_child(0)

func set_card_right(card : Node2D):
	active_card_right.add_child(card)
	card.global_position = active_card_right.global_position
	
func set_card_left(card : Node2D):
	active_card_left.add_child(card)
	card.global_position = active_card_left.global_position

func update_active_cards():
	if(card_right().get_hp() == 0):
		kill_card(true)
	if(card_left().get_hp() == 0):
		kill_card(false)

func start_game():
	game_started = true
	var left_card = deck_left.get_child(left_index).duplicate()
	set_card_left(left_card)
	var right_card = deck_right.get_child(right_index).duplicate()
	set_card_right(right_card)
	sound_player.stream = load("res://audio/soundFX/baseball/baseball.wav")
	sound_player.play()
	game_timer.start(3)
	original_y = active_card_left.global_position.y

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
			card_right().queue_free()
			right_index = right_index + 1
			if(right_index < deck_right.get_children().size()):	
				var right_card = deck_right.get_child(right_index).duplicate()
				set_card_right(right_card)
			else:
				game_is_over = true
		else:
			card_left().queue_free()
			left_index = left_index + 1
			if(left_index < deck_left.get_children().size()):	
				var left_card = deck_left.get_child(left_index).duplicate()
				set_card_left(left_card)
			else:
				game_is_over = true
		killing_card = false
		
		

func _physics_process(delta: float):	
	if(game_started == false):
		start_game()
	else:
		if(game_timer.is_stopped() && !game_is_over && !killing_card):
			update_active_cards()
			if(!killing_card):
				if(right_is_going):
					active_card_left.global_position.y = original_y
					active_card_right.global_position.y  = original_y  - 16
					bat_arms_left.visible = false
					bat_arms_right.visible = true
					var card_killed = run_turn(card_right(), card_left())
					right_is_going = false
				else:
					active_card_left.global_position.y  = original_y - 16
					active_card_right.global_position.y  = original_y
					bat_arms_left.visible = true
					bat_arms_right.visible = false
					var card_killed = run_turn(card_left(), card_right())
					right_is_going = true
				game_timer.start(turn_secs)
		elif(killing_card):
			killing_card_process()
			
