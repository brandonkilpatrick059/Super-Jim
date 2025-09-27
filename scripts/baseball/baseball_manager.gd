extends Node2D

#@export var deck_left : Array[Baseball_Card]
#@export var deck_right : Array[Baseball_Card]

@export var deck_left : Node2D
@export var deck_right : Node2D
@onready var active_card_left = $active_card_left
@onready var active_card_right = $active_card_right

var left_index = 0
var right_index = 0

var max_lineup = 10

var game_timer := Timer.new()
var turn_secs = 2

var right_is_going = true

var game_started = false
var game_is_over = false

var original_y = 0

func _ready():
	active_card_left.get_child(0).queue_free()
	active_card_right.get_child(0).queue_free()
	game_timer.one_shot = true
	add_child(game_timer)
	game_timer.start(turn_secs)

func run_turn(attacking_card : Baseball_Card, defending_card : Baseball_Card):
	#step 1: APPLY DAMAGE
	var damage_done = attacking_card.get_power()
	var defending_hp = defending_card.get_hp()
	var defending_hp_after_damage = defending_hp - damage_done
	if(defending_hp_after_damage < 0):
		defending_hp_after_damage = 0
	defending_card.set_hp(defending_hp_after_damage)
	#step 2: REDUCE STAMINA + POWER
	var attacking_stamina = attacking_card.get_stamina()
	if(attacking_stamina == 0):
		var attacking_power = attacking_card.get_power()
		if(attacking_power > 1):
			attacking_card.set_power(attacking_power - 1)
	else:
		attacking_card.set_stamina(attacking_stamina - 1)
	#step 3: EFFECTS
	#todo: make effects work
	#step 4: SWITCH TURNS
	right_is_going = !right_is_going

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
		card_right().queue_free()
		right_index = right_index + 1	
		if(right_index < deck_right.get_children().size()):	
			var right_card = deck_right.get_child(right_index).duplicate()
			set_card_right(right_card)
		else:
			game_is_over = true
	if(card_left().get_hp() == 0):
		card_left().queue_free()
		left_index = left_index + 1
		if(left_index < deck_left.get_children().size()):	
			var left_card = deck_left.get_child(left_index).duplicate()
			set_card_left(left_card)
		else:
			game_is_over = true

func start_game():
	game_started = true
	var left_card = deck_left.get_child(left_index).duplicate()
	set_card_left(left_card)
	var right_card = deck_right.get_child(right_index).duplicate()
	set_card_right(right_card)
	game_timer.start(turn_secs)
	
	original_y = active_card_left.global_position.y

func _physics_process(delta: float):	
	if(game_started == false):
		start_game()
	else:
		if(game_timer.is_stopped() && !game_is_over):
			update_active_cards()
			if(right_is_going):
				active_card_left.global_position.y = original_y
				active_card_right.global_position.y  = original_y  + 32
				run_turn(card_right(), card_left())
			else:
				active_card_left.global_position.y  = original_y + 32
				active_card_right.global_position.y  = original_y
				run_turn(card_left(), card_right())
			game_timer.start(turn_secs)
