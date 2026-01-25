class_name Chaser_Transit_State
extends State

signal set_nav_target(pos : Vector2)
signal advance_navigation(speed : int)
var nav_target_reached = false
var host_position
var current_stage_mark : Node = null

const distance_to_break_current_point = 128

var player_ref = null

func get_host_position():
	return ai_state_machine.get_perceptions().position

func get_host_nav_target_reached():
	return ai_state_machine.get_perceptions().nav_target_reached

func physics_process(_delta: float) -> void:
	nav_target_reached = get_host_nav_target_reached()
	if(!nav_target_reached):
		advance_navigation.emit(600000)
	else:
		pass
		#player_ref.wake_up()
	set_nav_target.emit(player_ref.global_position)

func enter(_msg := {}) -> void:
	player_ref = get_tree().get_first_node_in_group("player")
	if(current_stage_mark != null):
		set_nav_target.emit(player_ref.global_position)

func exit() -> void:
	pass
	
