extends Node2D

@onready var hat_arrows = $hat_arrows
@onready var top_arrows = $top_arrows
@onready var bottom_arrows = $bottom_arrows
@onready var character_base = $character_base

var base_material = preload("res://entities/characters/player/die_material.tres")

var player_ref

#0 = hat, 1 = top, 2 = bottom
var arrows_index = 0

var hat_index : int = 0
var top_index : int = 0
var bottom_index : int = 0

var hats : Array[String] = []
var tops : Array[String] = []
var bottoms : Array[String] = []

var timer_input := Timer.new()

var animation_dirs : Array[String] = ["down", "left", "up", "right"]
var animation_index = 0
var timer_animation := Timer.new()
var animation_change_secs = 2.0

var changed : bool = true

func _ready() -> void:
	player_ref = get_tree().get_first_node_in_group("player")
	hat_index = player_ref.get_hats_index()
	top_index = player_ref.get_tops_index()
	bottom_index = player_ref.get_bottoms_index()
	hats = player_ref.get_owned_hats()
	tops  = player_ref.get_owned_tops()
	bottoms = player_ref.get_owned_bottoms()
	timer_input.one_shot = true
	add_child(timer_input)
	timer_input.start(1)
	timer_animation.one_shot = true
	add_child(timer_animation)
	player_ref.set_control_frozen(true)
	player_ref.main_ui_invisible()

func update_character_base():
	if(changed):
		var hat : String = hats[hat_index]
		var top : String = tops[top_index]
		var bottom : String = bottoms[bottom_index]
		character_base.load_and_set_spriteframes(player_ref.get_base(),hat,top,bottom)
		character_base.set_all_materials(base_material)
		character_base.stand_dir("down")
		character_base.set_speed_scales(0.5)
		changed = false

func update_arrows():
	if(hats.size() > 1):
		if(arrows_index == 0):
			hat_arrows.set_active()
		else:
			hat_arrows.set_inactive()
	else:
		hat_arrows.set_off()
	if(tops.size() > 1):
		if(arrows_index == 1):
			top_arrows.set_active()
		else:
			top_arrows.set_inactive()
	else:
		top_arrows.set_off()
	if(bottoms.size() > 1):
		if(arrows_index == 2):
			bottom_arrows.set_active()
		else:
			bottom_arrows.set_inactive()
	else:
		bottom_arrows.set_off()

func decrement_selection():
	changed = true
	timer_animation.start(animation_change_secs)
	match arrows_index:
		0:
			if(hat_index == 0):
				hat_index = hats.size() - 1
			else: hat_index = hat_index - 1
		1:
			if(top_index == 0):
				top_index = tops.size() - 1
			else: top_index = top_index - 1
		2:
			if(bottom_index == 0):
				bottom_index = bottoms.size() - 1
			else: bottom_index = bottom_index - 1

func increment_selection():
	changed = true
	timer_animation.start(animation_change_secs)
	match arrows_index:
		0:
			if(hat_index == hats.size() - 1):
				hat_index = 0
			else: hat_index = hat_index + 1
		1:
			if(top_index == tops.size() - 1):
				top_index = 0
			else: top_index = top_index + 1
		2:
			if(bottom_index == bottoms.size() - 1):
				bottom_index = 0
			else: bottom_index = bottom_index + 1

func close(keep_changes : bool):
	if(keep_changes):
		player_ref.set_and_update_cloths(hat_index,top_index,bottom_index)
	player_ref.set_control_frozen(false)
	player_ref.main_ui_visible()
	queue_free()

func handle_input():
	if(timer_input.is_stopped()):
		if(Input.is_action_just_pressed("up")):
			if(arrows_index == 0):
				arrows_index = 2
			else:
				arrows_index = arrows_index - 1
		elif(Input.is_action_just_pressed("down")):
			if(arrows_index == 2):
				arrows_index = 0
			else:
				arrows_index = arrows_index + 1
		elif(Input.is_action_just_pressed("left")):
			decrement_selection()
		elif(Input.is_action_just_pressed("right")):
			increment_selection()
		elif(Input.is_action_just_pressed("interact")):
			var keep_changes = true
			close(keep_changes)
		elif(Input.is_action_just_pressed("use_item")):
			var do_not_keep_changes = false
			close(do_not_keep_changes)

func update_animation():
	if(timer_animation.is_stopped()):
		if(animation_index == 3):
			animation_index = 0
		else:
			animation_index = animation_index + 1
		character_base.walk_dir(animation_dirs[animation_index])
		character_base.set_speed_scales(0.5)
		timer_animation.start(animation_change_secs)

func _process(delta: float) -> void:
	player_ref.stop()
	global_position = Vector2(player_ref.global_position.x,player_ref.global_position.y - 3)
	update_arrows()
	update_character_base()
	update_animation()
	handle_input()
	
	
	
