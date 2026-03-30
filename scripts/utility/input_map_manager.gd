extends Node

enum controller_type {XBOX, PLAYSTATION}

var current_controller : controller_type = controller_type.XBOX

var default_mapping : control_actions_mapping
var current_mapping : control_actions_mapping

var mode_controller : String = "CONTROLLER"
var mode_keyboard : String = "KEYBOARD"
var input_mode : String = ""

var mappable_keys : Array[Key] = [
	KEY_Q,
	KEY_W,
	KEY_E,
	KEY_R,
	KEY_T,
	KEY_Y,
	KEY_U,
	KEY_I,
	KEY_O,
	KEY_P,
	KEY_A,
	KEY_S,
	KEY_D,
	KEY_F,
	KEY_G,
	KEY_H,
	KEY_J,
	KEY_K,
	KEY_L,
	KEY_Z,
	KEY_X,
	KEY_C,
	KEY_V,
	KEY_B,
	KEY_N,
	KEY_M,
	KEY_0,
	KEY_1,
	KEY_2,
	KEY_3,
	KEY_4,
	KEY_5,
	KEY_6,
	KEY_7,
	KEY_8,
	KEY_9,
	KEY_UP,
	KEY_DOWN,
	KEY_LEFT,
	KEY_RIGHT,
	KEY_CTRL,
	KEY_SHIFT,
	KEY_CAPSLOCK,
	KEY_TAB,
	KEY_ASCIITILDE,
	KEY_BACKSLASH,
	KEY_BRACELEFT,
	KEY_BRACERIGHT,
	KEY_QUESTION,
	KEY_QUOTEDBL,
	KEY_SEMICOLON,
	KEY_GREATER,
	KEY_LESS,
	KEY_ESCAPE,
	KEY_BACKSPACE,
	KEY_SPACE,
	KEY_PLUS,
	KEY_MINUS,
	KEY_ENTER
]

var key_glyph_path : Array[String] = [
	"res://sprites/interface/glyphs/keyboard/q_key.png",
	"res://sprites/interface/glyphs/keyboard/w_key.png",
	"res://sprites/interface/glyphs/keyboard/e_key.png",
	"res://sprites/interface/glyphs/keyboard/r_key.png",
	"res://sprites/interface/glyphs/keyboard/t_key.png",
	"res://sprites/interface/glyphs/keyboard/y_key.png",
	"res://sprites/interface/glyphs/keyboard/u_key.png",
	"res://sprites/interface/glyphs/keyboard/i_key.png",
	"res://sprites/interface/glyphs/keyboard/o_key.png",
	"res://sprites/interface/glyphs/keyboard/p_key.png",
	"res://sprites/interface/glyphs/keyboard/a_key.png",
	"res://sprites/interface/glyphs/keyboard/s_key.png",
	"res://sprites/interface/glyphs/keyboard/d_key.png",
	"res://sprites/interface/glyphs/keyboard/f_key.png",
	"res://sprites/interface/glyphs/keyboard/g_key.png",
	"res://sprites/interface/glyphs/keyboard/h_key.png",
	"res://sprites/interface/glyphs/keyboard/j_key.png",
	"res://sprites/interface/glyphs/keyboard/k_key.png",
	"res://sprites/interface/glyphs/keyboard/l_key.png",
	"res://sprites/interface/glyphs/keyboard/z_key.png",
	"res://sprites/interface/glyphs/keyboard/x_key.png",
	"res://sprites/interface/glyphs/keyboard/c_key.png",
	"res://sprites/interface/glyphs/keyboard/v_key.png",
	"res://sprites/interface/glyphs/keyboard/b_key.png",
	"res://sprites/interface/glyphs/keyboard/n_key.png",
	"res://sprites/interface/glyphs/keyboard/m_key.png",
	"res://sprites/interface/glyphs/keyboard/0_key.png",
	"res://sprites/interface/glyphs/keyboard/1_key.png",
	"res://sprites/interface/glyphs/keyboard/2_key.png",
	"res://sprites/interface/glyphs/keyboard/3_key.png",
	"res://sprites/interface/glyphs/keyboard/4_key.png",
	"res://sprites/interface/glyphs/keyboard/5_key.png",
	"res://sprites/interface/glyphs/keyboard/6_key.png",
	"res://sprites/interface/glyphs/keyboard/7_key.png",
	"res://sprites/interface/glyphs/keyboard/8_key.png",
	"res://sprites/interface/glyphs/keyboard/9_key.png",
	"res://sprites/interface/glyphs/keyboard/up_key.png",
	"res://sprites/interface/glyphs/keyboard/down_key.png",
	"res://sprites/interface/glyphs/keyboard/left_key.png",
	"res://sprites/interface/glyphs/keyboard/right_key.png",
	"res://sprites/interface/glyphs/keyboard/ctrl_key.png",
	"res://sprites/interface/glyphs/keyboard/shift_key.png",
	"res://sprites/interface/glyphs/keyboard/capslk_key.png",
	"res://sprites/interface/glyphs/keyboard/tab_key.png",
	"res://sprites/interface/glyphs/keyboard/tilde_key.png",
	"res://sprites/interface/glyphs/keyboard/backslash_key.png",
	"res://sprites/interface/glyphs/keyboard/left_bracket_key.png",
	"res://sprites/interface/glyphs/keyboard/right_bracket_key.png",
	"res://sprites/interface/glyphs/keyboard/question_key.png",
	"res://sprites/interface/glyphs/keyboard/quote_key.png",
	"res://sprites/interface/glyphs/keyboard/semicolon_key.png",
	"res://sprites/interface/glyphs/keyboard/greater_key.png",
	"res://sprites/interface/glyphs/keyboard/less_key.png",
	"res://sprites/interface/glyphs/keyboard/esc_key.png",
	"res://sprites/interface/glyphs/keyboard/back_key.png",
	"res://sprites/interface/glyphs/keyboard/space_key.png",
	"res://sprites/interface/glyphs/keyboard/plus_key.png",
	"res://sprites/interface/glyphs/keyboard/minus_key.png",
	"res://sprites/interface/glyphs/keyboard/enter_key.png"
]

var mappable_joypad : Array[JoyButton] = [
	JOY_BUTTON_A,
	JOY_BUTTON_B,
	JOY_BUTTON_X,
	JOY_BUTTON_Y,
	JOY_BUTTON_BACK,
	JOY_BUTTON_START,
	JOY_BUTTON_LEFT_STICK,
	JOY_BUTTON_RIGHT_STICK,
	JOY_BUTTON_DPAD_UP,
	JOY_BUTTON_DPAD_DOWN,
	JOY_BUTTON_DPAD_LEFT,
	JOY_BUTTON_DPAD_RIGHT,
	JOY_BUTTON_RIGHT_SHOULDER,
	JOY_BUTTON_LEFT_SHOULDER
]

var joybutton_glyph_path_xbox : Array[String] = [
	"res://sprites/interface/glyphs/controller/xbox/a_button_xb.png",
	"res://sprites/interface/glyphs/controller/xbox/b_button_xb.png",
	"res://sprites/interface/glyphs/controller/xbox/x_button_xb.png",
	"res://sprites/interface/glyphs/controller/xbox/y_button_xb.png",
	"res://sprites/interface/glyphs/controller/xbox/select_button_xb.png",
	"res://sprites/interface/glyphs/controller/xbox/start_button_xb.png",
	"res://sprites/interface/glyphs/controller/L_stick_button.png",
	"res://sprites/interface/glyphs/controller/R_stick_button.png",
	"res://sprites/interface/glyphs/controller/pad_up.png",
	"res://sprites/interface/glyphs/controller/pad_down.png",
	"res://sprites/interface/glyphs/controller/pad_left.png",
	"res://sprites/interface/glyphs/controller/pad_right.png",
	"res://sprites/interface/glyphs/controller/right_bumper.png",
	"res://sprites/interface/glyphs/controller/left_bumper.png"
]

var mappable_joy_axis : Array[JoyAxis] = [
	JOY_AXIS_LEFT_X,
	JOY_AXIS_LEFT_Y,
	JOY_AXIS_RIGHT_X,
	JOY_AXIS_RIGHT_Y,
	JOY_AXIS_TRIGGER_LEFT,
	JOY_AXIS_TRIGGER_RIGHT
]

var pos_axis_glyph_path : Array[String] = [
	"res://sprites/interface/glyphs/controller/L_stick_right.png",
	"res://sprites/interface/glyphs/controller/L_stick_down.png",
	"res://sprites/interface/glyphs/controller/R_stick_right.png",
	"res://sprites/interface/glyphs/controller/R_stick_down.png",
	"res://sprites/interface/glyphs/controller/L_trigger.png",
	"res://sprites/interface/glyphs/controller/R_trigger.png",
]

var neg_axis_glyph_path : Array[String] = [
	"res://sprites/interface/glyphs/controller/L_stick_left.png",
	"res://sprites/interface/glyphs/controller/L_stick_up.png",
	"res://sprites/interface/glyphs/controller/R_stick_left.png",
	"res://sprites/interface/glyphs/controller/R_stick_up.png",
	"res://sprites/interface/glyphs/controller/L_trigger.png",
	"res://sprites/interface/glyphs/controller/R_trigger.png",
]

func _ready():
	default_mapping = get_inputmap_as_control_actions_mapping()
	current_mapping = get_inputmap_as_control_actions_mapping()
	input_mode = mode_controller

func get_current_mapping() -> control_actions_mapping:
	return current_mapping

func _input(event: InputEvent) -> void:
	if(event is InputEventJoypadButton ||
	event is InputEventJoypadMotion):
		input_mode = mode_controller
	elif(event is InputEventKey):
		input_mode = mode_keyboard

func get_inputmap_as_control_actions_mapping() -> control_actions_mapping:
	var inputmap_mapping : control_actions_mapping = control_actions_mapping.new()
	var keyboard_mapping : actions_mapping = actions_mapping.new()
	var controller_mapping : actions_mapping = actions_mapping.new()
	var actions : Array[StringName] = keyboard_mapping.get_actions()
	
	for action in actions:
		if (keyboard_mapping.actions.find(action) >= 0):
			var events = InputMap.action_get_events(action)
			for event in events:
				if(event is InputEventKey):
					keyboard_mapping.set_action_event(action,event)
				else:
					controller_mapping.set_action_event(action,event)
	
	inputmap_mapping.set_keyboard_mapping(keyboard_mapping)
	inputmap_mapping.set_controller_mapping(controller_mapping)
	
	return inputmap_mapping

#gets a path to the glyph for the input mapped to the given action
#in the current input mode (controller or keyboard)
func get_glyph_path_for_action(action : StringName) -> String:
	var glyph_path : String = ""
	if(input_mode == mode_controller):
		var controller_mapping = current_mapping.get_controller_mapping()
		var event : InputEvent = controller_mapping.get_action_event(action)
		glyph_path = get_glyph_path_from_inputevent(event)
	elif(input_mode == mode_keyboard):
		var keyboard_mapping = current_mapping.get_keyboard_mapping()
		var event : InputEvent = keyboard_mapping.get_action_event(action)
		glyph_path = get_glyph_path_from_inputevent(event)
	return glyph_path

func get_glyph_path_from_inputevent(inputEvent : InputEvent):
	var event_string : String = ""
	if(inputEvent is InputEventKey):
		var inputEventKey : InputEventKey = inputEvent
		event_string = get_glyph_path_from_keycode(inputEventKey.keycode)
	if(inputEvent is InputEventJoypadButton):
		var inputEventJoyButton : InputEventJoypadButton = inputEvent
		event_string = get_glyph_path_from_joybutton(inputEventJoyButton.button_index)
	if(inputEvent is InputEventJoypadMotion):
		var inputEventJoypadMotion : InputEventJoypadMotion = inputEvent
		var axis = inputEventJoypadMotion.axis
		var value = inputEventJoypadMotion.value
		event_string = get_glyph_path_from_joyaxis(axis,value)
	return event_string

func get_glyph_path_from_keycode(key : Key) -> String:
	var index = mappable_keys.find(key)
	return key_glyph_path[index]

func get_glyph_path_from_joybutton(button : JoyButton) -> String:
	var index = mappable_joypad.find(button)
	if(current_controller == controller_type.XBOX):
		return joybutton_glyph_path_xbox[index]
	else:
		return ""

func get_glyph_path_from_joyaxis(axis : JoyAxis, value: float):
	var index = mappable_joy_axis.find(axis)
	if(value >= 0):
		return pos_axis_glyph_path[index]
	else:
		return neg_axis_glyph_path[index]

func clear_input_map():
	var act_map = actions_mapping.new()
	var actions : Array[StringName] = act_map.get_actions()
	for action in actions:
		InputMap.action_erase_events(action)

func restore_default_mapping():
	apply_control_actions_mapping(default_mapping)

func apply_control_actions_mapping(mapping: control_actions_mapping):
	clear_input_map()
	apply_action_mapping(mapping.keyboard)
	apply_action_mapping(mapping.controller)
	current_mapping = mapping.duplicate()

func apply_new_mapping_from_dictionaries(keyboard_dict : Dictionary, controller_dict : Dictionary):
	var keyboard_mapping : actions_mapping = actions_mapping.new()
	var controller_mapping : actions_mapping = actions_mapping.new()
	keyboard_mapping.load_from_dictionary(keyboard_dict)
	controller_mapping.load_from_dictionary(controller_dict)
	apply_new_mapping(keyboard_mapping,controller_mapping)

func apply_new_mapping(keyboard_mapping : actions_mapping, controller_mapping : actions_mapping):
	var new_mapping : control_actions_mapping = control_actions_mapping.new()
	new_mapping.set_keyboard_mapping(keyboard_mapping)
	new_mapping.set_controller_mapping(controller_mapping)
	apply_control_actions_mapping(new_mapping)

func apply_action_mapping(mapping : actions_mapping):
	var actions : Array[StringName] = InputMap.get_actions()
	for action in actions:
		var event = mapping.get_action_event(action)
		if(event != null):
			InputMap.action_add_event(action,event)

func set_current_keyboard_action_event(action: StringName, event : InputEvent):
	current_mapping.set_keyboard_action_event(action, event)
	apply_control_actions_mapping(current_mapping)

func set_current_controller_action_event(action: StringName, event : InputEvent):
	current_mapping.set_controller_action_event(action, event)
	apply_control_actions_mapping(current_mapping)

#class representing a complete, loadable control scheme
#for in-game actions
class control_actions_mapping:
	var keyboard : actions_mapping
	var controller : actions_mapping
	
	func set_keyboard_action_event(action: StringName, event : InputEvent):
		var keyboard_check_action = keyboard.has_event(event)
		if(keyboard_check_action != ""):
			keyboard.unbind_action_event(keyboard_check_action)
		keyboard.set_action_event(action, event)
	
	func set_controller_action_event(action: StringName, event : InputEvent):
		var controller_check_action = controller.has_event(event)
		if(controller_check_action != ""):
			controller.unbind_action_event(controller_check_action)
		controller.set_action_event(action, event)
	
	func get_keyboard_mapping() -> actions_mapping:
		return keyboard
	
	func get_controller_mapping() -> actions_mapping:
		return controller
	
	func set_keyboard_mapping(mapping : actions_mapping):
		keyboard = mapping
	
	func set_controller_mapping(mapping : actions_mapping):
		controller = mapping
	
	func get_keyboard_dictionary() -> Dictionary:
		return keyboard.get_dictionary()

	func get_controller_dictionary() -> Dictionary:
		return controller.get_dictionary()
	
	func duplicate() -> control_actions_mapping:
		var new_control_actions_mapping = control_actions_mapping.new()
		var new_controller_mapping = controller.duplicate()
		var new_keyboard_mapping = keyboard.duplicate()
		new_control_actions_mapping.set_controller_mapping(new_controller_mapping)
		new_control_actions_mapping.set_keyboard_mapping(new_keyboard_mapping)
		return new_control_actions_mapping

#class for representing a 1:1 mapping of in-game input actions and InputEvents
#where each action corresponds to exactly one event
class actions_mapping:
	var actions : Array[StringName]
	var events : Array[InputEvent]
	
	func _init():
		var inMap = InputMap.get_actions()
		#actions_mapping only has mappable actions in it
		#IE no menu or dev-only actions are included
		for action in inMap:
			if(is_mappable_action(action)):
				actions.append(action)
		for action in actions:
			events.append(null)
	
	func get_actions() -> Array[StringName]:
		return actions
	
	func is_mappable_action(action : StringName):
		var is_mappable = true
		if(action.contains("dev")):
			is_mappable = false
		if(action.contains("menu")):
			is_mappable = false
		if(action.contains("ui")):
			is_mappable = false
		return is_mappable
	
	func get_action_event(action : StringName) -> InputEvent:
		var index = actions.find(action)
		if(index >= 0):
			return events[index]
		else:
			return null
	
	func duplicate() -> actions_mapping:
		var new_mapping = actions_mapping.new()
		var index = 0
		for action in actions:
			new_mapping.set_action_event(action,get_action_event(action))
			index = index + 1
		return new_mapping
	
	func set_action_event(action: StringName, event : InputEvent):
		var index = actions.find(action)
		if(index >= 0):
			events[index] = event
	
	func unbind_action_event(action : StringName):
		var index = actions.find(action)
		if(index >= 0):
			events[index] = null
	
	#if an event is present in the mapping, return the associated action.
	#otherwise return an empty string
	func has_event(event : InputEvent) -> String:
		var ret_action : String = ""
		
		for action in actions:
			var action_event = get_action_event(action)
			if (event_check_equivalent(action_event,event)):
				ret_action = action
				break
		return ret_action
	
	func get_dictionary() -> Dictionary:
		var mapping_dictionary : Dictionary
		
		for action in actions:
			var event = get_action_event(action)
			var event_string :String
			if(event is InputEventKey):
				event_string = get_key_as_string(event)
			if(event is InputEventJoypadButton):
				event_string = get_joybutton_as_string(event)
			if(event is InputEventJoypadMotion):
				event_string = get_joymotion_as_string(event)
			mapping_dictionary.set(action,event_string)
		
		return mapping_dictionary
	
	func load_from_dictionary(load_dictionary : Dictionary):
		for action in actions:
			var event_string = load_dictionary.get(action)
			var type = event_string.get_slice("_",0)
			var event : InputEvent 
			if(type == "JoyMotion"):
				event = get_joymotion_from_string(event_string)
			elif(type == "JoyButton"):
				event = get_joybutton_from_string(event_string)
			elif(type == "Key"):
				event = get_key_from_string(event_string)
			set_action_event(action,event)
	
	func get_joymotion_as_string(event : InputEventJoypadMotion) -> String:
		var output_string = "JoyMotion_"
		if(event.axis_value > 0):
			output_string = str(output_string,str(event.axis,"_+"))
		elif(event.axis_value < 0):
			output_string = str(output_string,str(event.axis,"_-"))
		return output_string
	
	func get_joymotion_from_string(string : String) -> InputEventJoypadMotion:
		var motion : InputEventJoypadMotion = InputEventJoypadMotion.new()
		var axis : String = string.get_slice("_",1)
		var value_key : String = string.get_slice("_",2)
		var axis_value : float = 0.0
		if(value_key == "+"):
			axis_value = 1.0
		elif(value_key == "-"):
			axis_value = -1.0
		motion.axis = int(axis)
		motion.axis_value = axis_value
		return motion
	
	func get_joybutton_as_string(event : InputEventJoypadButton) -> String:
		var output_string = "JoyButton"
		output_string = str(str(output_string,"_"),event.button_index)
		return output_string
	
	func get_joybutton_from_string(string : String) -> InputEventJoypadButton:
		var button : InputEventJoypadButton = InputEventJoypadButton.new()
		var button_index : String = string.get_slice("_",1)
		button.button_index = int(button_index)
		return button
	
	func get_key_as_string(event : InputEventKey) -> String:
		var output_string = "Key"
		output_string = str(str(output_string,"_"),event.physical_keycode)
		return output_string
	
	func get_key_from_string(string: String) -> InputEventKey:
		var key : InputEventKey = InputEventKey.new()
		var physical_keycode : String = string.get_slice("_",1)
		key.physical_keycode = int(physical_keycode)
		return key
	
	func event_check_equivalent(event1 : InputEvent, event2: InputEvent):
		var equivalent = false
		if(event1 is InputEventKey &&
		event2 is InputEventKey):
			equivalent = event1.physical_keycode == event2.physical_keycode
		elif(event1 is InputEventJoypadButton &&
		event2 is InputEventJoypadButton):
			equivalent = event1.button_index == event2.button_index
		elif(event1 is InputEventJoypadMotion &&
		event2 is InputEventJoypadMotion):
			equivalent = event1.axis == event2.axis
			equivalent = equivalent && (event1.axis_value == event2.axis_value)
		return equivalent
