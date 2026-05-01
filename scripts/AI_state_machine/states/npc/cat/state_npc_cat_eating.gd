class_name NPC_Cat_Eating_State
extends State

var timer := Timer.new()

signal play_animation(name : String)

var host_position

var food_node : Node = null

func _ready() -> void:
	timer.one_shot = true
	add_child(timer)

func get_host_position():
	return ai_state_machine.get_perceptions().position

func is_outdoors() -> bool:
	return ai_state_machine.get_parent().get_parent().is_in_group("daylight_affected_ysort")

func physics_process(_delta: float) -> void:
	#var player_ref = get_tree().get_first_node_in_group("player")
	#if ((player_ref.global_position.distance_to(get_host_position()) < 64 &&
	#player_ref.speed() > 4 && !sleeping) ||
	#(sleeping && player_ref.global_position.distance_to(get_host_position()) < 16)):
		#if(is_outdoors()):
			#var msg_dict : Dictionary = {"flee_from": player_ref.global_position}
			#ai_state_machine.transition_to("transit_flee",msg_dict)
	if(is_outdoors()):
		for commotion in ai_state_machine.get_perceptions().nodes_in_hearing:
			if(commotion != null):
				if(get_host_position().distance_to(commotion.global_position) < 128):
					var msg_dict : Dictionary = {"flee_from": commotion.global_position}
					ai_state_machine.transition_to("transit_flee",msg_dict)
					break
		var bullet_sparks = get_tree().get_nodes_in_group("bullet_spark")
		for spark in bullet_sparks:
			if(spark != null):
				if(get_host_position().distance_to(spark.global_position) < 128):
					var msg_dict : Dictionary = {"flee_from": spark.global_position}
					ai_state_machine.transition_to("transit_flee",msg_dict)
					break
	if(food_node != null && 
	(food_node.is_picked_up() || get_host_position().distance_to(food_node.global_position) > 16)):
		ai_state_machine.transition_to("transit")
	if(timer.is_stopped()):
		if(food_node != null):
			food_node.reduce_food()
			timer.start(randf_range(3.0,5.0))
		else:
			ai_state_machine.transition_to("transit")


func enter(_msg := {}) -> void:
	ai_state_machine.get_parent().set_immobilized(true)
	food_node = _msg.get("food_node")
	var face_right = bool(_msg.get("face_right"))
	if(face_right):
		play_animation.emit("eat_right")
	else:
		play_animation.emit("eat_left")
	timer.start(randf_range(3.0,5.0))

func exit() -> void:
	ai_state_machine.get_parent().set_immobilized(false)
	
