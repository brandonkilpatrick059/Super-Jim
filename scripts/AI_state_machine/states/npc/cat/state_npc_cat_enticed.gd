class_name NPC_Cat_Enticed_State
extends State

signal set_nav_target(pos : Vector2)
signal advance_navigation(speed : int)

@export var speed : float = 125000

var food_node : Node = null

func get_host_position():
	return ai_state_machine.get_perceptions().position

func get_host_nav_target_reached():
	return ai_state_machine.get_perceptions().nav_target_reached

#func get_stage_mark():
	#current_stage_mark = ai_state_machine.get_perceptions().current_stage_mark
	#if(current_stage_mark != null):
		#set_nav_target.emit(current_stage_mark.position)

func physics_process(_delta: float) -> void:
	var nav_target_reached = get_host_nav_target_reached()
	if(!nav_target_reached):
		advance_navigation.emit(speed)
	else:
		var cat_foods = get_tree().get_nodes_in_group("cat_food")
		var food_found = false
		for food in cat_foods:
			if(!food.is_picked_up() &&
			get_host_position().distance_to(food.global_position) <= 16):
				var face_right : bool = true
				if(food.global_position.x < get_host_position().x):
					face_right = false
				var msg_dict : Dictionary = {
				"face_right": face_right, 
				"food_node": food_node}
				ai_state_machine.transition_to("eating",msg_dict)
				food_found = true
		if(!food_found):
			ai_state_machine.transition_to("transit")

func enter(_msg := {}) -> void:
	food_node = _msg.get("food_node")
	set_nav_target.emit(food_node.global_position)

func exit() -> void:
	pass
	
