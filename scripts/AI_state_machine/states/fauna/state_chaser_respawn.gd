class_name Chaser_Respawn_State
extends State

signal set_nav_target(pos : Vector2)
signal advance_navigation(speed : int)
var nav_target_reached = false
var host_position
var current_stage_mark : Node = null

const distance_to_break_current_point = 128

var player_ref = null

var timer := Timer.new()

func ready():
	timer.one_shot = true
	add_child(timer)

func physics_process(_delta: float) -> void:
	if(timer.is_stopped()):
		var chaser = ai_state_machine.get_parent()
		if(chaser.modulate.a > 0.0):
			chaser.modulate.a = chaser.modulate.a - 0.05
		else:
			var spawns = get_tree().get_nodes_in_group("dream_chaser_spawn")
			var viable_spawns : Array[Node] = []
			var chosen_spawn = null
			for spawn in spawns:
				if(spawn.global_position.distance_to(chaser.global_position) > 500):
					viable_spawns.append(spawn)
			if(viable_spawns.size() == 0):
				chosen_spawn = spawns[0]
			else:
				chosen_spawn = viable_spawns[randi_range(0,viable_spawns.size()-1)]
			chaser.global_position = chosen_spawn.global_position
			chaser.modulate.a = 1.0
			chaser.transition_ai_state("transit")
		timer.start(0.006)

func enter(_msg := {}) -> void:
	pass

func exit() -> void:
	pass
	
