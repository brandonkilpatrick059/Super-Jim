extends MarginContainer

@onready var back_label = $CenterContainer/VBoxContainer/back_label
@onready var rebind_note = $CenterContainer/VBoxContainer/rebind_note
@onready var rebind_mode = $CenterContainer/VBoxContainer/rebind_mode
@onready var restore_default = $CenterContainer/VBoxContainer/restore_label

@onready var action1_1 = $CenterContainer/VBoxContainer/HBoxContainer/column_1/HBoxContainer/actions/action_1_1
@onready var action1_2 = $CenterContainer/VBoxContainer/HBoxContainer/column_1/HBoxContainer/actions/action_1_2
@onready var action1_3 = $CenterContainer/VBoxContainer/HBoxContainer/column_1/HBoxContainer/actions/action_1_3
@onready var action1_4 = $CenterContainer/VBoxContainer/HBoxContainer/column_1/HBoxContainer/actions/action_1_4
@onready var action1_5 = $CenterContainer/VBoxContainer/HBoxContainer/column_1/HBoxContainer/actions/action_1_5
@onready var action1_6 = $CenterContainer/VBoxContainer/HBoxContainer/column_1/HBoxContainer/actions/action_1_6
@onready var action1_7 = $CenterContainer/VBoxContainer/HBoxContainer/column_1/HBoxContainer/actions/action_1_7
@onready var action1_8 = $CenterContainer/VBoxContainer/HBoxContainer/column_1/HBoxContainer/actions/action_1_8

@onready var action2_1 = $CenterContainer/VBoxContainer/HBoxContainer/column_2/HBoxContainer/actions/action_2_1
@onready var action2_2 = $CenterContainer/VBoxContainer/HBoxContainer/column_2/HBoxContainer/actions/action_2_2
@onready var action2_3 = $CenterContainer/VBoxContainer/HBoxContainer/column_2/HBoxContainer/actions/action_2_3
@onready var action2_4 = $CenterContainer/VBoxContainer/HBoxContainer/column_2/HBoxContainer/actions/action_2_4
@onready var action2_5 = $CenterContainer/VBoxContainer/HBoxContainer/column_2/HBoxContainer/actions/action_2_5
@onready var action2_6 = $CenterContainer/VBoxContainer/HBoxContainer/column_2/HBoxContainer/actions/action_2_6
@onready var action2_7 = $CenterContainer/VBoxContainer/HBoxContainer/column_2/HBoxContainer/actions/action_2_7
@onready var action2_8 = $CenterContainer/VBoxContainer/HBoxContainer/column_2/HBoxContainer/actions/action_2_8
@onready var action2_9 = $CenterContainer/VBoxContainer/HBoxContainer/column_2/HBoxContainer/actions/action_2_9

@onready var input_map_manager

var action_column_1 : Array[Node] = []
var action_column_2 : Array[Node] = []

var modes : Array[String] = ["KEYBOARD", "CONTROLLER"]
var mode_index = 0

var listening_for_input : bool = false

var action_map_1: Array[String] = [
	"left",
	"right",
	"up",
	"down",
	"pan_left",
	"pan_right",
	"pan_up",
	"pan_down"
]

var action_map_2: Array[String] = [
	"interact",
	"throw",
	"dash",
	"use_item",
	"switch_item_right",
	"switch_item_left",
	"journal",
	"start",
	"transparency"
]

var menu_alpha = 1
var sound_player := AudioStreamPlayer.new()

var select_index = 0
var select_column = 1

var action_timer := Timer.new()

func advance_index():
	select_index += 1
	sound_player.stream = load("res://audio/soundFX/voice/low_sine_voice/1.wav")
	sound_player.play()
	
func reduce_index():
	select_index -= 1
	sound_player.stream = load("res://audio/soundFX/voice/low_sine_voice/1.wav")
	sound_player.play()

func advance_column():
	if(select_column == 1):
		select_column = 2
		if(select_index >= action_column_2.size()):
			select_index = action_column_2.size() - 1
		elif(select_index < 0):
			select_index = 0
		sound_player.stream = load("res://audio/soundFX/voice/low_sine_voice/1.wav")
		sound_player.play()
	elif(select_column == 2):
		sound_player.stream = load("res://audio/soundFX/bigCollide.wav")
		sound_player.play()

func reduce_column():
	if(select_column == 2):
		select_column = 1
		sound_player.stream = load("res://audio/soundFX/voice/low_sine_voice/1.wav")
		sound_player.play()
	elif(select_column == 1):
		sound_player.stream = load("res://audio/soundFX/bigCollide.wav")
		sound_player.play()

func advance_mode():
	get_parent().play_sound("res://audio/soundFX/maracca.ogg")
	if(mode_index < modes.size()-1):
		mode_index = mode_index + 1
	else:
		mode_index = 0

func update_glyphs():
	var mode_text = str("MODE: ",modes[mode_index])
	rebind_mode.parse_bbcode(mode_text)
	var rebind_text = "("
	var events : Array[InputEvent] =  InputMap.action_get_events("menu_select")
	var glyph_string = get_glyph_string(events[0])
	glyph_string = str(glyph_string,str(" / ",get_glyph_string(events[3])))
	rebind_text = str(str(rebind_text,glyph_string), " TO SELECT)")
	rebind_note.parse_bbcode(rebind_text)
	update_glyphs_column(action_column_1, action_map_1, 1)
	update_glyphs_column(action_column_2, action_map_2, 2)

func update_glyphs_column(column : Array[Node], action_map : Array[String], column_num : int):
	var index = 0
	for action in column:
		if(select_index == index && 
		select_column == column_num &&
		listening_for_input):
			var richTextLabel = action.get_child(1)
			richTextLabel.parse_bbcode("(NEW INPUT)")
		else:
			var event : InputEvent
			if(modes[mode_index] == "KEYBOARD"):
				var keyboard_mapping = input_map_manager.get_current_mapping().get_keyboard_mapping()
				event = keyboard_mapping.get_action_event(action_map[index])
			elif(modes[mode_index] == "CONTROLLER"):
				var controller_mapping = input_map_manager.get_current_mapping().get_controller_mapping()
				event = controller_mapping.get_action_event(action_map[index])
			var glyphs_string = get_glyph_string(event)
			var richTextLabel = action.get_child(1)
			richTextLabel.parse_bbcode(glyphs_string)
		index = index+1

func get_glyph_string(event : InputEvent) -> String:
	var glyph_string : String = ""
	if event is InputEventKey:
		glyph_string = input_map_manager.get_glyph_path_from_keycode(event.physical_keycode)
	elif event is InputEventJoypadButton:
		glyph_string = input_map_manager.get_glyph_path_from_joybutton(event.button_index)
	elif event is InputEventJoypadMotion:
		glyph_string = input_map_manager.get_glyph_path_from_joyaxis(event.axis, event.axis_value)
	return str("[img]",str(glyph_string,"[/img]"))

func concat_glyphs_string(glyphs_string : String, glyph_path : String) -> String:
	var new_glyph_string = ""
	var bbcode_path : String = str("[img]",str(glyph_path,"[/img]"))
	if(glyphs_string == ""):
		new_glyph_string = bbcode_path
	else:
		new_glyph_string = str(glyphs_string,str(" / ",bbcode_path))
	return new_glyph_string

func _input(event: InputEvent) -> void:
	if(listening_for_input &&
	action_timer.is_stopped()):
		var mapping = input_map_manager.get_current_mapping()
		var column = get_action_map(select_column)
		var action : StringName = column[select_index]
		if(modes[mode_index] == "KEYBOARD"):
			if(event is InputEventKey):
				input_map_manager.set_current_keyboard_action_event(action,event)
				get_parent().play_sound("res://audio/soundFX/maracca.ogg")
				listening_for_input = false
				action_timer.start(0.2)
		elif(modes[mode_index] == "CONTROLLER"):
			if(event is InputEventJoypadButton):
				input_map_manager.set_current_controller_action_event(action,event)
				get_parent().play_sound("res://audio/soundFX/maracca.ogg")
				listening_for_input = false
				action_timer.start(0.2)
			elif(event is InputEventJoypadMotion):
				if(absf(event.axis_value) > 0.5):
					if(event.axis_value < 0):
						event.axis_value = -1.0
					elif(event.axis_value > 0):
						event.axis_value = 1.0
					input_map_manager.set_current_controller_action_event(action,event)
					get_parent().play_sound("res://audio/soundFX/maracca.ogg")
					listening_for_input = false
					action_timer.start(0.2)

func block_index():
	sound_player.stream = load("res://audio/soundFX/bigCollide.wav")
	sound_player.play()

func set_labels_alpha(alpha):
	for action in action_column_1:
		var new_color = action.modulate
		new_color.a = alpha
		action.modulate = new_color
	for action in action_column_2:
		var new_color = action.modulate
		new_color.a = alpha
		action.modulate = new_color

func get_action_column(index : int) -> Array[Node]:
	match(index):
		1:
			return action_column_1
		2:
			return action_column_2
	return action_column_1

func get_action_map(index : int) -> Array[String]:
	match(index):
		1:
			return action_map_1
		2:
			return action_map_2
	return action_map_1

func update_selection():
	var iterator = 0
	while(iterator < action_column_1.size()):
		if(iterator == select_index && select_column == 1):
			action_column_1[iterator].get_child(0).modulate = Color(1,1,0,1)
		else:
			action_column_1[iterator].get_child(0).modulate = Color(1,1,1,1)
		iterator+=1
	iterator = 0
	while(iterator < action_column_2.size()):
		if(iterator == select_index && select_column == 2):
			action_column_2[iterator].get_child(0).modulate = Color(1,1,0,1)
		else:
			action_column_2[iterator].get_child(0).modulate = Color(1,1,1,1)
		iterator+=1
	if(select_index == -1 && select_column == 1):
		rebind_mode.modulate = Color(1,1,0,1)
	else:
		rebind_mode.modulate = Color(1,1,1,1)
	if(select_index == action_column_1.size() && select_column == 1):
		restore_default.modulate = Color(1,1,0,1)
	else:
		restore_default.modulate = Color(1,1,1,1)
	if(select_index == action_column_1.size() + 1 && select_column == 1):
		back_label.modulate = Color(1,1,0,1)
	else:
		back_label.modulate = Color(1,1,1,1)

func handle_selection():
	if(select_index == -1 && select_column == 1):
		advance_mode()
	elif(select_index == (action_column_1.size()) + 1) && select_column == 1:
		back_selected()
	elif(select_index == (action_column_1.size())) && select_column == 1:
		get_parent().play_sound("res://audio/soundFX/maracca.ogg")
		input_map_manager.restore_default_mapping()
	else:
		if(!listening_for_input):
			get_parent().play_sound("res://audio/soundFX/maracca.ogg")
			listening_for_input = true
			action_timer.start(0.2)

func play_sound(sound_path : String):
	sound_player.stream = load(sound_path)
	sound_player.play()

func back_selected():
	get_parent().play_sound("res://audio/soundFX/maracca.ogg")
	#save_settings()
	queue_free()

func handle_input():
	if(!listening_for_input && action_timer.is_stopped()):
		if Input.is_action_just_pressed("menu_up"):
			if(select_column == 1):
				if(select_index > -1):
					reduce_index()
				else:
					block_index()
			if(select_column == 2):
				if(select_index > 0):
					reduce_index()
				else:
					block_index()
		if Input.is_action_just_pressed("menu_down"):
			if(select_column == 1):
				if(select_index < action_column_1.size() + 1):
					advance_index()
				else:
					block_index()
			if(select_column == 2):
				if(select_index < action_column_2.size() - 1):
					advance_index()
				else:
					block_index()
		if Input.is_action_just_pressed("menu_right"):
			advance_column()
		if Input.is_action_just_pressed("menu_left"):
			reduce_column()
		if Input.is_action_just_pressed("menu_select"):
			handle_selection()
		if Input.is_action_just_pressed("menu_back"):
			back_selected()

# Called when the node enters the scene tree for the first time.
func _ready():
	sound_player.bus = "Effects"
	add_child(sound_player)
	action_column_1 = [action1_1,action1_2,action1_3,action1_4,
	action1_5,action1_6,action1_7,action1_8]
	action_column_2 = [action2_1,action2_2,action2_3,action2_4,
	action2_5,action2_6,action2_7,action2_8,action2_9]
	set_labels_alpha(menu_alpha)
	input_map_manager = get_tree().get_first_node_in_group("input_map_manager")
	action_timer.one_shot = true
	add_child(action_timer)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float):
	menu_alpha = 1
	set_labels_alpha(menu_alpha)
	handle_input()
	update_glyphs()
	update_selection()
