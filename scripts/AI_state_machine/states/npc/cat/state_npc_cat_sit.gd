class_name NPC_Cat_Sit_State
extends State

var timer := Timer.new()

signal play_animation(name : String)

var host_position
var face_right : bool = false
var sitting : bool = false
var loafing : bool = false
var sleeping : bool = false

func _ready() -> void:
	timer.one_shot = true
	add_child(timer)

func get_host_position():
	return ai_state_machine.get_perceptions().position

func physics_process(_delta: float) -> void:
	var player_ref = get_tree().get_first_node_in_group("player")
	if ((player_ref.global_position.distance_to(get_host_position()) < 64 &&
	player_ref.speed() > 4 && !sleeping) ||
	(sleeping && player_ref.global_position.distance_to(get_host_position()) < 16)):
		var msg_dict : Dictionary = {"flee_from": player_ref.global_position}
		ai_state_machine.transition_to("transit_flee",msg_dict)
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
	if(timer.is_stopped()):
		if(randi_range(0,1.0) > 0.5):
			advance_coziness()
		else:
			decrease_coziness()
		timer.start(randf_range(10.0,30.0))

func advance_coziness():
	if(sitting):
		if(face_right):
			play_animation.emit("loaf_right")
			face_right = true
		else:
			play_animation.emit("loaf_left")
			face_right = false
		sitting = false
		sleeping = false
		loafing = true
	elif(loafing):
		if(face_right):
			play_animation.emit("sleep_right")
			face_right = true
		else:
			play_animation.emit("sleep_left")
			face_right = false
		sitting = false
		loafing = false
		sleeping = true

func decrease_coziness():
	if(loafing):
		if(face_right):
			play_animation.emit("sit_right")
			face_right = true
		else:
			play_animation.emit("sit_left")
			face_right = false
		sitting = true
		sleeping = false
		loafing = false
	elif(sleeping):
		if(face_right):
			play_animation.emit("loaf_right")
			face_right = true
		else:
			play_animation.emit("loaf_left")
			face_right = false
		sitting = false
		loafing = true
		sleeping = false
	elif(sitting):
		ai_state_machine.transition_to("transit")

func enter(_msg := {}) -> void:
	ai_state_machine.get_parent().set_immobilized(true)
	if(randi_range(0,1.0) > 0.5):
		play_animation.emit("sit_right")
		face_right = true
	else:
		play_animation.emit("sit_left")
		face_right = false
	sitting = true
	timer.start(randf_range(10.0,30.0))

func exit() -> void:
	ai_state_machine.get_parent().set_immobilized(false)
	
