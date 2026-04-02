extends Control

@onready var tip_box = $tip_box
@onready var tip_arrow_left = $tip_box_arrow_left
@onready var tip_arrow_right = $tip_box_arrow_right
@onready var label = $RichTextLabel

var glyph_actions_1 : Array[String] = []
var glyph_actions_2 : Array[String] = []
var glyph_actions_3 : Array[String] = []
var actions_1_index : int = 0
var actions_2_index : int = 0
var actions_3_index : int = 0

var action_1 : String = "[action_1]"
var action_2 : String = "[action_2]"
var action_3 : String = "[action_3]"

var tip_text : String = ""

var timer : Timer = Timer.new()
var timer_index : Timer = Timer.new()
var alpha_step : float = 0.08
var fade_Step : float = 0.006

var tip_box_active : bool = false
var tip_arrow_left_active : bool = false
var tip_arrow_right_active : bool = false 

func _ready() -> void:
	timer.one_shot = true
	add_child(timer)
	timer_index.one_shot = true
	add_child(timer_index)
	tip_box.modulate = Color(1.0,1.0,1.0,0.0)
	tip_arrow_left.modulate = Color(1.0,1.0,1.0,0.0)
	tip_arrow_right.modulate = Color(1.0,1.0,1.0,0.0)
	label.modulate = Color(1.0,1.0,1.0,0.0)

func hide_tip():
	tip_box_active = false
	tip_arrow_left_active = false
	tip_arrow_right_active = false

func show_tip(text : String, 
arrow_left : bool = false, 
arrow_right : bool = false,
glyph_acts_1 : Array[String] = [],
glyph_acts_2 : Array[String] = [],
glyph_acts_3 : Array[String] = []):
	glyph_actions_1 = glyph_acts_1
	glyph_actions_2 = glyph_acts_2
	glyph_actions_3 = glyph_acts_3
	set_label_text(text)
	tip_box_active = true
	tip_arrow_left_active = arrow_left
	tip_arrow_right_active = arrow_right
	visible = true

func set_label_text(text : String):
	tip_text = text
	var final_text : String = insert_bbcode(tip_text)
	label.parse_bbcode(final_text)

func refresh_label_text():
	var final_text : String = insert_bbcode(tip_text)
	label.parse_bbcode(final_text)

func insert_bbcode(text : String) -> String:
	var act1_bbcode : String = ""
	var act2_bbcode : String = ""
	var act3_bbcode : String = ""
	if(glyph_actions_1.size() > 0):
		if(actions_1_index >= glyph_actions_1.size()):
			actions_1_index = 0
		var action : String = glyph_actions_1[actions_1_index]
		act1_bbcode = get_action_glyph_bbcode(action)
	if(glyph_actions_2.size() > 0):
		if(actions_2_index >= glyph_actions_2.size()):
			actions_2_index = 0
		var action : String = glyph_actions_2[actions_2_index]
		act2_bbcode = get_action_glyph_bbcode(action)
	if(glyph_actions_3.size() > 0):
		if(actions_3_index >= glyph_actions_3.size()):
			actions_3_index = 0
		var action : String = glyph_actions_3[actions_3_index]
		act3_bbcode = get_action_glyph_bbcode(action)
	
	text = text.replacen(action_1,act1_bbcode)
	text = text.replacen(action_2,act2_bbcode)
	text = text.replacen(action_3,act3_bbcode)
	
	return text

func get_action_glyph_bbcode(action : String):
	var input_map_manager = get_tree().get_first_node_in_group("input_map_manager")
	var path = input_map_manager.get_glyph_path_for_action(action)
	var bbcode : String = str(str("[img]",path),"[/img]")
	return bbcode

func handle_fading():
	var player = get_tree().get_first_node_in_group("player")
	
	if(timer.is_stopped()):
		if(tip_box_active && !player.control_is_frozen()):
			if(tip_box.modulate.a < 1.0):
				var new_alpha = tip_box.modulate.a + alpha_step
				tip_box.modulate = Color(1.0,1.0,1.0,new_alpha)
				label.modulate = Color(1.0,1.0,1.0,new_alpha)
		else:
			if(tip_box.modulate.a > 0.0):
				var new_alpha = tip_box.modulate.a - alpha_step
				tip_box.modulate = Color(1.0,1.0,1.0,new_alpha)
				label.modulate = Color(1.0,1.0,1.0,new_alpha)
		if(tip_arrow_left_active && !player.control_is_frozen()):
			if(tip_arrow_left.modulate.a < 1.0):
				var new_alpha = tip_arrow_left.modulate.a + alpha_step
				tip_arrow_left.modulate = Color(1.0,1.0,1.0,new_alpha)
		else:
			if(tip_arrow_left.modulate.a > 0.0):
				var new_alpha = tip_arrow_left.modulate.a - alpha_step
				tip_arrow_left.modulate = Color(1.0,1.0,1.0,new_alpha)
		if(tip_arrow_right_active && !player.control_is_frozen()):
			if(tip_arrow_right.modulate.a < 1.0):
				var new_alpha = tip_arrow_right.modulate.a + alpha_step
				tip_arrow_right.modulate = Color(1.0,1.0,1.0,new_alpha)
		else:
			if(tip_arrow_right.modulate.a > 0.0):
				var new_alpha = tip_arrow_right.modulate.a - alpha_step
				tip_arrow_right.modulate = Color(1.0,1.0,1.0,new_alpha)

func advance_indexes():
	actions_1_index = actions_1_index + 1
	actions_2_index = actions_2_index + 1
	actions_3_index = actions_3_index + 1

func _physics_process(delta: float) -> void:
	handle_fading()
	if(timer_index.is_stopped()):
		advance_indexes()
		timer_index.start(1.0)
		refresh_label_text()
