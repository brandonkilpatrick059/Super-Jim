extends Node2D

@export var test_mode = false

@onready var _animated_pack : AnimatedSprite2D = $animated_pack
@onready var _card_1 : Node2D = $card_1 #moves left
@onready var _card_2 : Node2D = $card_2 #does not move - stays in center
@onready var _card_3 : Node2D = $card_3 #moves right

var pack_skin : String = ""
var roster_min : int = 0
var roster_max : int = 0
var str_min : int = 0
var str_max : int = 0

var rise_up_timer : Timer = Timer.new()
var y_move_step = 6
var step_secs = 0.006
var spread_out_timer : Timer = Timer.new()
var x_move_step = 2
var x_spread_width = 128

var rising = false
var waiting_to_open = false
var opening = false
var lowering = false
var spreading = false
var done = false

var card_selection : Array[int]

var sound_player : AudioStreamPlayer = AudioStreamPlayer.new()

func _ready() -> void:
	rise_up_timer.one_shot = true
	spread_out_timer.one_shot = true
	add_child(rise_up_timer)
	add_child(spread_out_timer)
	add_child(sound_player)
	if(test_mode):
		open(0,18,"green")

func open(in_roster_min : int, in_roster_max : int, team_name : String = ""):
	if(team_name != ""):
		pack_skin = str("_",team_name)
	_animated_pack.play(str("default",pack_skin))
	roster_min = in_roster_min
	roster_max = in_roster_max
	get_cards()
	if(rising == false):
		rising = true

func close():
	var player_ref = get_tree().get_first_node_in_group("player")
	for card in card_selection:
		player_ref.add_owned_card(card)
	queue_free()

func get_cards():
	var card_roster = get_tree().get_first_node_in_group("card_roster")
	
	var index = randi_range(roster_min,roster_max)
	var card1 = card_roster.get_card(index).duplicate()
	card_selection.append(index)
	_card_1.add_child(card1)
	card1.global_position = _card_1.global_position
	_card_1.visible = false
	card1.visible = true

	
	index = randi_range(roster_min,roster_max)
	var card2 = card_roster.get_card(index).duplicate()
	card_selection.append(index)
	_card_2.add_child(card2)
	card2.global_position = _card_2.global_position
	_card_2.visible = false
	card2.visible = true

	
	index = randi_range(roster_min,roster_max)
	var card3 = card_roster.get_card(index).duplicate()
	card_selection.append(index)
	_card_3.add_child(card3)
	card3.global_position = _card_3.global_position
	_card_3.visible = false
	card3.visible = true


func _physics_process(delta: float) -> void:
	if(rising && rise_up_timer.is_stopped()):
		if(_animated_pack.position.y <= 0):
			if(!waiting_to_open):
				waiting_to_open = true
				rise_up_timer.start(0.2)
			else:
				_card_1.visible = true
				_card_2.visible = true
				_card_3.visible = true
				rising = false
				opening = true
				_animated_pack.play(str("opening",pack_skin))
				sound_player.stream = load("res://audio/soundFX/dash.wav")
				sound_player.play()
		else:
			_animated_pack.position = Vector2(0,_animated_pack.position.y - y_move_step)
			rise_up_timer.start(step_secs)
	if(opening && _animated_pack.frame == _animated_pack.sprite_frames.get_frame_count(str("opening",pack_skin)) - 1):
		_animated_pack.play(str("opened",pack_skin))
		opening = false
		lowering = true
		spreading = true
		spread_out_timer.start(0.25)
	if(lowering && rise_up_timer.is_stopped()):
		if(_animated_pack.position.y < 512):
			_animated_pack.position = Vector2(0,_animated_pack.position.y + y_move_step) 
			rise_up_timer.start(step_secs)
		else:
			lowering = false
	if(spreading && spread_out_timer.is_stopped()):
		if(_card_3.position.x < x_spread_width):
			_card_1.position = Vector2(_card_1.position.x - x_move_step, _card_1.position.y)
			_card_3.position = Vector2(_card_3.position.x + x_move_step, _card_3.position.y)
			spread_out_timer.start(step_secs)
		else:
			spreading = false
	if(Input.is_action_just_pressed("interact")):
		close()
