extends Node2D

@onready var frame = $frame

@onready var left_glyph = $frame/left_glyph
@onready var left_label = $frame/left_label
@onready var right_glyph = $frame/right_glyph
@onready var right_label = $frame/right_label
@onready var left_tab = $frame/journal_tab_left
@onready var right_tab = $frame/journal_tab_right

var timer := Timer.new()
var timer_step : float = 0.006

var rising : bool = false
var lowering : bool = false
var closing : bool = false
var opening : bool = false
var is_open : bool = false

var move_speed: float = 32.0

var audio_player := AudioStreamPlayer.new()

var player : Node = null

var tabs : Array[String] = []
var tab_index : int = 0

var child_ui_ref : Node2D = null

var binder_ui = preload("res://baseball/card_binder.tscn")
var quest_journal_ui = preload("res://interface/quest_journal_interface.tscn")
var map_ui = preload("res://interface/map_interface.tscn")

var tab_switching = false
var switching_right = false


func _ready() -> void:
	timer.one_shot = true
	add_child(timer)
	add_child(audio_player)
	audio_player.bus = "Effects"
	player = get_tree().get_first_node_in_group("player")
	hide_glyph_tabs()

func open(set_tabs : Array[String]):
	hide_glyph_tabs()
	tabs = set_tabs
	frame.play("closed")
	opening = true
	rising = true
	audio_player.stream = load("res://audio/soundFX/maracca.ogg")
	audio_player.play()

func close():
	if(!tab_switching):
		hide_glyph_tabs()
		frame.play("close")
		audio_player.stream = load("res://audio/soundFX/page_turn.wav")
		audio_player.play()
		opening = false
		rising = false
		closing = true
		is_open = false
		close_ui()

func switch(switch_right : bool):
	if(!closing && !tab_switching):
		tab_switching = true
		close_ui()
		frame.play("close")
		closing = true
		if(switch_right):
			tab_index = tab_index + 1
			if(tab_index >= tabs.size()):
				tab_index = 0
		else:
			tab_index = tab_index - 1
			if(tab_index < 0):
				tab_index = tabs.size() - 1
		audio_player.stream = load("res://audio/soundFX/page_turn.wav")
		audio_player.play()

func initialize_ui():
	var key = tabs[tab_index]
	match key:
		"card_binder":
			initialize_card_binder()
		"quest_journal":
			initialize_quest_journal()
		"map":
			initialize_map()

func initialize_map():
	child_ui_ref = map_ui.instantiate()
	add_child(child_ui_ref)

func close_ui():
	child_ui_ref.close()

func initialize_card_binder():
	child_ui_ref = binder_ui.instantiate()
	add_child(child_ui_ref)

func initialize_quest_journal():
	child_ui_ref = quest_journal_ui.instantiate()
	add_child(child_ui_ref)

func handle_opening():
	if(rising):
		if(frame.position.y > 0):
			frame.position = frame.position + Vector2(0,-move_speed)
		else:
			frame.position = Vector2(0,0)
			rising = false
			frame.play("open")
			audio_player.stream = load("res://audio/soundFX/page_turn.wav")
			audio_player.play()
	if(!rising):
		if(frame.frame == 2):
			frame.play("opened")
			initialize_ui()
			is_open = true
			opening = false

func return_control():
	var time_keeper = get_tree().get_first_node_in_group("time_keeper")
	time_keeper.unpause_parent_tree()
	player.set_ui_visible()
	player.set_control_frozen(false)

func handle_closing():
	if(lowering):
		if(frame.position.y < 512):
			frame.position = frame.position + Vector2(0,move_speed)
		else:
			frame.position = Vector2(0,512)
			lowering = false
			frame.play("close")
			return_control()
			queue_free()
	if(!lowering):
		if(frame.frame == 2):
			frame.play("closed")
			is_open = false
			lowering = true

func handle_tab_switching():
	hide_glyph_tabs()
	if(closing):
		if(frame.frame == 2):
			frame.play("open")
			closing = false
			opening = true
	if(opening):
		if(frame.frame == 2):
			opening = false
			frame.play("opened")
			initialize_ui()
			tab_switching = false

func handle_glyphs():
	if(tabs.size() > 1):
		left_glyph.visible = true
		right_glyph.visible = true
		left_tab.visible = true
		right_tab.visible = true
		left_glyph.get_glyph()
		right_glyph.get_glyph()
		var left_index = tab_index - 1
		var right_index = tab_index + 1
		if(left_index < 0):
			left_index = tabs.size() - 1
		if(right_index >= tabs.size()):
			right_index = 0
		var left_key = tabs[left_index]
		var right_key = tabs[right_index]
		left_label.text = get_tab_key_string(left_key)
		right_label.text = get_tab_key_string(right_key)
		left_tab.texture = load(get_tab_sprite_path(left_key))
		right_tab.texture = load(get_tab_sprite_path(right_key))
	else:
		hide_glyph_tabs()

func hide_glyph_tabs():
	left_glyph.visible = false
	right_glyph.visible = false
	left_label.text = ""
	right_label.text = ""
	left_tab.visible = false
	right_tab.visible = false

func get_tab_key_string(key : String) -> String:
	match key:
		"card_binder":
			return "Cards"
		"quest_journal":
			return "Log"
		"map":
			return "Map"
		_: return ""

func get_tab_sprite_path(key : String) -> String:
	match key:
		"card_binder":
			return "res://sprites/interface/journal_tab_purple.png"
		"quest_journal":
			return "res://sprites/interface/journal_tab_blue.png"
		"map":
			return "res://sprites/interface/journal_tab_brown.png"
		_: return ""

func _physics_process(delta: float) -> void:
	#global_position = player.get_camera_ref().get_screen_center_position()
	if(timer.is_stopped()):
		if(Input.is_action_just_pressed("journal")):
			if(is_open):
				close()
		if(Input.is_action_just_pressed("menu_journal_left")):
			if(is_open):
				var left = false
				switch(left)
		if(Input.is_action_just_pressed("menu_journal_right")):
			if(is_open):
				var right = true
				switch(right)
		if(!tab_switching):
			if(opening):
				handle_opening()
			if(closing):
				handle_closing()
			elif(is_open):
				handle_glyphs()
		if(tab_switching):
			handle_tab_switching()
		timer.start(timer_step)
