extends MarginContainer

@onready var back_label = $CenterContainer/VBoxContainer/back_label
@onready var rebind_note = $CenterContainer/VBoxContainer/rebind_note

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

@onready var input_map_manager = $input_map_manager

var action_column_1 : Array[Node] = []
var action_column_2 : Array[Node] = []

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
		sound_player.stream = load("res://audio/soundFX/voice/low_sine_voice/1.wav")
		sound_player.play()
	elif(select_column == 2):
		sound_player.stream = load("res://audio/soundFX/bigCollide.wav")
		sound_player.play()

func update_glyphs():
	var rebind_text = "("
	var events : Array[InputEvent] =  InputMap.action_get_events("interact")
	var glyphs_string = get_glyphs_string(events)
	rebind_text = str(str(rebind_text,glyphs_string), " TO REBIND)")
	rebind_note.parse_bbcode(rebind_text)
	update_glyphs_column(action_column_1, action_map_1)
	update_glyphs_column(action_column_2, action_map_2)

func update_glyphs_column(column : Array[Node], action_map : Array[String]):
	var index = 0
	for action in column:
		var events : Array[InputEvent] = InputMap.action_get_events(action_map[index])
		var glyphs_string = get_glyphs_string(events)
		var richTextLabel = action.get_child(1)
		richTextLabel.parse_bbcode(glyphs_string)
		index = index+1

func get_glyphs_string(events : Array[InputEvent]) -> String:
	var glyphs_string : String = ""
	for event in events:
		if event is InputEventKey:
			var glyph_path = input_map_manager.get_glyph_path_from_keycode(event.physical_keycode)
			glyphs_string = concat_glyphs_string(glyphs_string,glyph_path)
		elif event is InputEventJoypadButton:
			var glyph_path = input_map_manager.get_glyph_path_from_joybutton(event.button_index)
			glyphs_string = concat_glyphs_string(glyphs_string,glyph_path)
		elif event is InputEventJoypadMotion:
			var glyph_path = input_map_manager.get_glyph_path_from_joyaxis(event.axis, event.axis_value)
			glyphs_string = concat_glyphs_string(glyphs_string,glyph_path)
	return glyphs_string

func concat_glyphs_string(glyphs_string : String, glyph_path : String) -> String:
	var new_glyph_string = ""
	var bbcode_path : String = str("[img]",str(glyph_path,"[/img]"))
	if(glyphs_string == ""):
		new_glyph_string = bbcode_path
	else:
		new_glyph_string = str(glyphs_string,str(" / ",bbcode_path))
	return new_glyph_string

func reduce_column():
	if(select_column == 2):
		select_column = 1
		sound_player.stream = load("res://audio/soundFX/voice/low_sine_voice/1.wav")
		sound_player.play()
	elif(select_column == 1):
		sound_player.stream = load("res://audio/soundFX/bigCollide.wav")
		sound_player.play()

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
	if(select_index == action_column_1.size() && select_column == 1):
		back_label.modulate = Color(1,1,0,1)
	else:
		back_label.modulate = Color(1,1,1,1)

#func get_settings_dictionary() -> Dictionary:
	#var settings_dictionary = {
		#"lighting_index" = SettingsVariables.lighting_index,
		#"resolution_index" = SettingsVariables.resolution_index,
		#"full_screen" = SettingsVariables.full_screen
	#}
	#return settings_dictionary

#func save_settings():
	#var settings : Dictionary = get_settings_dictionary()
	#var settings_file : FileAccess = FileAccess.open("user://settings.save", FileAccess.WRITE)
	#settings_file.store_line(JSON.stringify(settings))
	#settings_file.close()

func handle_selection():
	if(select_index == action_column_1.size()) && select_column == 1:
		back_selected()
	#sound_player.stream = load("res://audio/soundFX/maracca.ogg")
	#sound_player.play()
	#match select_index:
		#0: #audio
			#var child_settings_menu = audio_settings_menu.instantiate()
			#active_child_menu = child_settings_menu
			#get_parent().add_child(child_settings_menu)
		#1: #video
			#var child_settings_menu = video_settings_menu.instantiate()
			#active_child_menu = child_settings_menu
			#get_parent().add_child(child_settings_menu)
		#2: #controls
			#pass #TODO: implement
		#3: #back 
			#back_selected()

func play_sound(sound_path : String):
	sound_player.stream = load(sound_path)
	sound_player.play()

func back_selected():
	get_parent().play_sound("res://audio/soundFX/maracca.ogg")
	#save_settings()
	queue_free()

func handle_input():
	if Input.is_action_just_pressed(direction.up):
		if(select_index > 0):
			reduce_index()
		else:
			block_index()
	if Input.is_action_just_pressed(direction.down):
		if(select_index < action_column_1.size()):
			advance_index()
		else:
			block_index()
	if Input.is_action_just_pressed(direction.right):
		advance_column()
	if Input.is_action_just_pressed(direction.left):
		reduce_column()
	if Input.is_action_just_pressed("interact"):
		handle_selection()
	if Input.is_action_just_pressed("back"):
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float):
	menu_alpha = 1
	set_labels_alpha(menu_alpha)
	handle_input()
	update_selection()
	update_glyphs()
