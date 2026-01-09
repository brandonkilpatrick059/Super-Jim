extends Node2D

@onready var scroll_list = $scroll_list
@onready var lineup = $lineup
@onready var view_card = $view_card
@onready var num_card = $num_card

var card_roster = null
var player_ref = null

var timer : Timer = Timer.new()
var exit_timer : Timer = Timer.new()
var input_wait_secs = 0.15
var exit_wait_time_secs = 1.0
var exiting = false

var deck_lineup : Array[int] = []
var used_cards = 0

var sound_player := AudioStreamPlayer.new()

func close_binder():
	player_ref.set_deck(deck_lineup)
	player_ref.set_control_frozen(false)
	player_ref.main_ui_visible()
	var time_keeper = get_tree().get_first_node_in_group("time_keeper")
	time_keeper.unlock_time()
	queue_free()

func _ready() -> void:
	card_roster = get_tree().get_first_node_in_group("card_roster")
	player_ref = get_tree().get_first_node_in_group("player")
	exit_timer.one_shot = true
	add_child(exit_timer)
	timer.one_shot = true
	add_child(timer)
	sound_player.bus = "Effects"
	add_child(sound_player)
	deck_lineup = player_ref.get_deck()
	lineup.set_lineup(deck_lineup)
	update_viewed_card()
	timer.start(1)
	var time_keeper = get_tree().get_first_node_in_group("time_keeper")
	time_keeper.lock_time()

func update_viewed_card():
	if(view_card.get_child_count() > 0):
		view_card.get_child(0).queue_free()
		
	var card = scroll_list.get_selected_card()
	if(card != null):
		var card_num = scroll_list.get_num_selected_card()
		card_num = card_num - deck_lineup.count(scroll_list.get_selected_index())
		view_card.add_child(card)
		card.position = Vector2(0,0)
		card.visible = true
		num_card.text = str("x",card_num)
	else:
		num_card.text = "x0"
		used_cards = 0

func handle_input():
	if(timer.is_stopped()):
		if Input.is_action_pressed(direction.up):
			scroll_list.decrement_selected()
			update_viewed_card()
			timer.start(input_wait_secs)
			sound_player.stream = load("res://audio/soundFX/click_2.ogg")
			sound_player.play()
		else: if Input.is_action_pressed(direction.down):
			scroll_list.increment_selected()
			update_viewed_card()
			timer.start(input_wait_secs)
			sound_player.stream = load("res://audio/soundFX/click_2.ogg")
			sound_player.play()
		else: if Input.is_action_pressed("interact"):
			if(scroll_list.get_num_selected_card() > 0):
				var indx = scroll_list.get_selected_index()
				var num_selected_card = scroll_list.get_num_selected_card()
				if(deck_lineup.size() + 1 <= 5 &&
				deck_lineup.count(indx) < num_selected_card):
					sound_player.stream = load("res://audio/soundFX/pickup.wav")
					sound_player.play()
					deck_lineup.append(indx) 
					lineup.add_card(indx)
					update_viewed_card()
				else:
					sound_player.stream = load("res://audio/soundFX/bigCollide.wav")
					sound_player.play()
			else:
				sound_player.stream = load("res://audio/soundFX/bigCollide.wav")
				sound_player.play()
			timer.start(input_wait_secs)
		else: if Input.is_action_just_released("use_item"):
			exiting = false
			if(deck_lineup.size() != 0):
				sound_player.stream = load("res://audio/soundFX/putdown.wav")
				sound_player.play()
				deck_lineup.remove_at(deck_lineup.size()-1)
				lineup.subtract_card()
				update_viewed_card()
			else:
				sound_player.stream = load("res://audio/soundFX/bigCollide.wav")
				sound_player.play()
			timer.start(input_wait_secs)
		else: if Input.is_action_just_pressed("use_item"):
			if(!exiting):
				exit_timer.start(exit_wait_time_secs)
				exiting = true

func _process(delta: float) -> void:
	handle_input()
	player_ref.stop()
	global_position = player_ref.get_camera_ref().get_screen_center_position()
	if(exiting && exit_timer.is_stopped()):
		close_binder()
