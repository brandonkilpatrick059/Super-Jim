extends Node2D

@onready var scroll_list = $scroll_list
@onready var lineup = $lineup
@onready var view_card = $view_card

var card_roster = null
var player_ref = null

var timer : Timer = Timer.new()
var input_wait_secs = 0.1

func _ready() -> void:
	timer.one_shot = true
	add_child(timer)

func handle_input():
	if(timer.is_stopped()):
		if Input.is_action_pressed(direction.up):
			scroll_list.decrement_selected()
		else: if Input.is_action_pressed(direction.down):
			scroll_list.increment_selected()
		timer.start(input_wait_secs)

func _process(delta: float) -> void:
	if(card_roster == null):
		card_roster = get_tree().get_first_node_in_group("card_roster")
	if(player_ref == null):
		player_ref = get_tree().get_first_node_in_group("player")
	handle_input()
